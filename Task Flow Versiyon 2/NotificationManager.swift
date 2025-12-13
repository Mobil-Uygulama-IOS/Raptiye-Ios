import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

// MARK: - Notification Manager
@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var notifications: [AppNotification] = []
    @Published var pendingInvitations: [ProjectInvitation] = []
    @Published var unreadCount: Int = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var notificationsListener: ListenerRegistration?
    private var invitationsListener: ListenerRegistration?
    
    private init() {}
    
    // MARK: - Setup Listeners
    
    func setupListeners() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // Listen for notifications
        notificationsListener = db.collection("notifications")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .limit(to: 50)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Bildirim dinleme hatası: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.notifications = documents.compactMap { doc -> AppNotification? in
                    try? doc.data(as: AppNotification.self)
                }
                
                self.unreadCount = self.notifications.filter { !$0.isRead }.count
                print("🔔 \(self.notifications.count) bildirim yüklendi, \(self.unreadCount) okunmamış")
            }
        
        // Listen for pending invitations
        invitationsListener = db.collection("invitations")
            .whereField("receiverId", isEqualTo: userId)
            .whereField("status", isEqualTo: InvitationStatus.pending.rawValue)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Davet dinleme hatası: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.pendingInvitations = documents.compactMap { doc -> ProjectInvitation? in
                    try? doc.data(as: ProjectInvitation.self)
                }
                
                print("📨 \(self.pendingInvitations.count) bekleyen davet")
            }
    }
    
    func removeListeners() {
        notificationsListener?.remove()
        invitationsListener?.remove()
    }
    
    // MARK: - Send Invitation
    
    func sendInvitation(
        to receiverEmail: String,
        projectId: String,
        projectTitle: String
    ) async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oturum açmamış"])
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Find receiver by email
            let usersSnapshot = try await db.collection("users")
                .whereField("email", isEqualTo: receiverEmail.lowercased())
                .getDocuments()
            
            guard let receiverDoc = usersSnapshot.documents.first else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı"])
            }
            
            let receiverId = receiverDoc.documentID
            
            // Check if already invited
            let existingInvitation = try await db.collection("invitations")
                .whereField("projectId", isEqualTo: projectId)
                .whereField("receiverId", isEqualTo: receiverId)
                .whereField("status", isEqualTo: InvitationStatus.pending.rawValue)
                .getDocuments()
            
            if !existingInvitation.documents.isEmpty {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Bu kullanıcıya zaten davet gönderilmiş"])
            }
            
            // Check if user is already a member
            let projectDoc = try await db.collection("projects").document(projectId).getDocument()
            if let projectData = projectDoc.data(),
               let teamMemberIds = projectData["teamMemberIds"] as? [String],
               teamMemberIds.contains(receiverId) {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Bu kullanıcı zaten projenin üyesi"])
            }
            
            // Create invitation
            let invitation = ProjectInvitation(
                projectId: projectId,
                projectTitle: projectTitle,
                senderId: currentUser.uid,
                senderName: currentUser.displayName ?? "Kullanıcı",
                senderEmail: currentUser.email ?? "",
                receiverId: receiverId,
                receiverEmail: receiverEmail.lowercased()
            )
            
            try db.collection("invitations").document(invitation.id).setData(from: invitation)
            
            // Create notification for receiver
            let notification = AppNotification(
                userId: receiverId,
                type: .projectInvitation,
                title: "Proje Daveti",
                message: "\(currentUser.displayName ?? "Bir kullanıcı") sizi '\(projectTitle)' projesine davet etti.",
                relatedId: invitation.id
            )
            
            try db.collection("notifications").document(notification.id).setData(from: notification)
            
            print("✅ Davet gönderildi: \(receiverEmail)")
            
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Davet gönderme hatası: \(error)")
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - Respond to Invitation
    
    func respondToInvitation(_ invitation: ProjectInvitation, accept: Bool) async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oturum açmamış"])
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let newStatus: InvitationStatus = accept ? .accepted : .rejected
            
            // Update invitation status
            try await db.collection("invitations").document(invitation.id).updateData([
                "status": newStatus.rawValue,
                "respondedAt": Timestamp(date: Date())
            ])
            
            if accept {
                // Add user to project team
                let projectRef = db.collection("projects").document(invitation.projectId)
                
                try await projectRef.updateData([
                    "teamMemberIds": FieldValue.arrayUnion([currentUser.uid])
                ])
                
                // Add user object to teamMembers
                let userDoc = try await db.collection("users").document(currentUser.uid).getDocument()
                if let userData = userDoc.data() {
                    let userToAdd: [String: Any] = [
                        "uid": currentUser.uid,
                        "displayName": userData["displayName"] as? String ?? currentUser.displayName ?? "Kullanıcı",
                        "email": currentUser.email ?? "",
                        "photoUrl": userData["photoUrl"] as? String ?? "",
                        "createdAt": Timestamp(date: Date())
                    ]
                    
                    try await projectRef.updateData([
                        "teamMembers": FieldValue.arrayUnion([userToAdd])
                    ])
                }
                
                print("✅ Davet kabul edildi, projeye eklendi")
            } else {
                print("✅ Davet reddedildi")
            }
            
            // Notify sender
            let notificationTitle = accept ? "Davet Kabul Edildi" : "Davet Reddedildi"
            let notificationMessage = accept
                ? "\(currentUser.displayName ?? "Kullanıcı") '\(invitation.projectTitle)' projesine katıldı."
                : "\(currentUser.displayName ?? "Kullanıcı") '\(invitation.projectTitle)' projesine katılma davetini reddetti."
            
            let notification = AppNotification(
                userId: invitation.senderId,
                type: accept ? .invitationAccepted : .invitationRejected,
                title: notificationTitle,
                message: notificationMessage,
                relatedId: invitation.projectId
            )
            
            try db.collection("notifications").document(notification.id).setData(from: notification)
            
            // Kabul edildiyse daveti sil
            if accept {
                try await db.collection("invitations").document(invitation.id).delete()
                print("🗑️ Kabul edilen davet silindi")
            }
            
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Davet yanıtlama hatası: \(error)")
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - Mark Notification as Read
    
    func markAsRead(_ notification: AppNotification) async {
        guard !notification.isRead else { return }
        
        do {
            try await db.collection("notifications").document(notification.id).updateData([
                "isRead": true
            ])
        } catch {
            print("❌ Bildirim okundu işaretleme hatası: \(error)")
        }
    }
    
    func markAllAsRead() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let batch = db.batch()
        
        do {
            let unreadDocs = try await db.collection("notifications")
                .whereField("userId", isEqualTo: userId)
                .whereField("isRead", isEqualTo: false)
                .getDocuments()
            
            for doc in unreadDocs.documents {
                batch.updateData(["isRead": true], forDocument: doc.reference)
            }
            
            try await batch.commit()
            print("✅ Tüm bildirimler okundu olarak işaretlendi")
        } catch {
            print("❌ Toplu okundu işaretleme hatası: \(error)")
        }
    }
    
    // MARK: - Delete Notification
    
    func deleteNotification(_ notification: AppNotification) async {
        do {
            try await db.collection("notifications").document(notification.id).delete()
            print("✅ Bildirim silindi")
        } catch {
            print("❌ Bildirim silme hatası: \(error)")
        }
    }
    
    // MARK: - Get Invitations for Project
    
    func getInvitationsForProject(_ projectId: String) async -> [ProjectInvitation] {
        do {
            let snapshot = try await db.collection("invitations")
                .whereField("projectId", isEqualTo: projectId)
                .getDocuments()
            
            return snapshot.documents.compactMap { doc -> ProjectInvitation? in
                try? doc.data(as: ProjectInvitation.self)
            }
        } catch {
            print("❌ Proje davetleri yükleme hatası: \(error)")
            return []
        }
    }
}
