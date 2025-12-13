import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine
import UserNotifications

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
    
    private init() {
        requestNotificationPermission()
    }
    
    // MARK: - Local Notifications
    
    func requestNotificationPermission() {
        Task {
            do {
                let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
                if granted {
                    print("✅ Bildirim izni verildi")
                    registerForRemoteNotifications()
                } else {
                    print("⚠️ Bildirim izni reddedildi")
                }
            } catch {
                print("❌ Bildirim izni hatası: \(error)")
            }
        }
    }
    
    @MainActor
    func registerForRemoteNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func sendLocalNotification(title: String, body: String, identifier: String = UUID().uuidString, category: String? = nil) {
        Task {
            // Kullanıcının bildirim ayarlarını kontrol et
            guard await shouldSendLocalNotification() else { return }
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            
            if let category = category {
                content.categoryIdentifier = category
            }
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            do {
                try await UNUserNotificationCenter.current().add(request)
                print("✅ Local bildirim gönderildi: \(title)")
            } catch {
                print("❌ Local bildirim gönderilemedi: \(error)")
            }
        }
    }
    
    private func shouldSendLocalNotification() async -> Bool {
        let pushEnabled = UserDefaults.standard.bool(forKey: "pushNotifications")
        return pushEnabled != false // Varsayılan true
    }
    
    // MARK: - Setup Listeners
    
    func setupListeners() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("⚠️ setupListeners: Kullanıcı oturum açmamış")
            return
        }
        
        // Önce mevcut listener'ları kaldır (çift listener önlemek için)
        removeListeners()
        
        print("🔔 Listener'lar başlatılıyor - UserID: \(userId)")
        
        // Listen for notifications (index gerektirmeyecek basit sorgu)
        notificationsListener = db.collection("notifications")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Bildirim dinleme hatası: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                Task { @MainActor in
                    let oldCount = self.notifications.count
                    var loadedNotifications = documents.compactMap { doc -> AppNotification? in
                        try? doc.data(as: AppNotification.self)
                    }
                    // Client-side sıralama
                    loadedNotifications.sort { $0.createdAt > $1.createdAt }
                    self.notifications = Array(loadedNotifications.prefix(50))
                    
                    // Yeni bildirim varsa local notification gönder
                    if !self.notifications.isEmpty && self.notifications.count > oldCount {
                        let newNotification = self.notifications.first!
                        self.sendLocalNotification(
                            title: newNotification.title,
                            body: newNotification.message,
                            identifier: newNotification.id
                        )
                    }
                    
                    self.unreadCount = self.notifications.filter { !$0.isRead }.count
                    print("🔔 \(self.notifications.count) bildirim yüklendi, \(self.unreadCount) okunmamış")
                }
            }
        
        // Listen for pending invitations (index gerektirmeyecek basit sorgu)
        invitationsListener = db.collection("invitations")
            .whereField("receiverId", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Davet dinleme hatası: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                Task { @MainActor in
                    var loadedInvitations = documents.compactMap { doc -> ProjectInvitation? in
                        try? doc.data(as: ProjectInvitation.self)
                    }
                    // Client-side filtreleme ve sıralama
                    loadedInvitations = loadedInvitations.filter { $0.status == .pending }
                    loadedInvitations.sort { $0.createdAt > $1.createdAt }
                    self.pendingInvitations = loadedInvitations
                    
                    print("📨 \(self.pendingInvitations.count) bekleyen davet")
                }
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
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            // Find receiver by email
            print("🔍 Kullanıcı aranıyor: \(receiverEmail.lowercased())")
            let usersSnapshot = try await db.collection("users")
                .whereField("email", isEqualTo: receiverEmail.lowercased())
                .getDocuments()
            
            print("📄 Bulunan döküman sayısı: \(usersSnapshot.documents.count)")
            
            guard let receiverDoc = usersSnapshot.documents.first else {
                await MainActor.run { isLoading = false }
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı"])
            }
            
            let receiverId = receiverDoc.documentID
            print("👤 Alıcı ID: \(receiverId)")
            
            // Check if already invited
            let existingInvitation = try await db.collection("invitations")
                .whereField("projectId", isEqualTo: projectId)
                .whereField("receiverId", isEqualTo: receiverId)
                .whereField("status", isEqualTo: InvitationStatus.pending.rawValue)
                .getDocuments()
            
            if !existingInvitation.documents.isEmpty {
                await MainActor.run { isLoading = false }
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Bu kullanıcıya zaten davet gönderilmiş"])
            }
            
            // Check if user is already a member
            let projectDoc = try await db.collection("projects").document(projectId).getDocument()
            if let projectData = projectDoc.data(),
               let teamMemberIds = projectData["teamMemberIds"] as? [String],
               teamMemberIds.contains(receiverId) {
                await MainActor.run { isLoading = false }
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
            
            print("📨 Davet oluşturuluyor: \(invitation.id)")
            try await db.collection("invitations").document(invitation.id).setData(from: invitation)
            print("✅ Davet kaydedildi")
            
            // Create notification for receiver
            let notification = AppNotification(
                userId: receiverId,
                type: .projectInvitation,
                title: "Proje Daveti",
                message: "\(currentUser.displayName ?? "Bir kullanıcı") sizi '\(projectTitle)' projesine davet etti.",
                relatedId: invitation.id
            )
            
            print("🔔 Bildirim oluşturuluyor: \(notification.id)")
            try await db.collection("notifications").document(notification.id).setData(from: notification)
            print("✅ Bildirim kaydedildi")
            
            print("✅ Davet başarıyla gönderildi: \(receiverEmail)")
            
            await MainActor.run { isLoading = false }
            
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
            print("❌ Davet gönderme hatası: \(error)")
            throw error
        }
    }
    
    // MARK: - Respond to Invitation
    
    func respondToInvitation(_ invitation: ProjectInvitation, accept: Bool) async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oturum açmamış"])
        }
        
        guard invitation.receiverId == currentUser.uid else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Bu daveti yanıtlama yetkiniz yok"])
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
                
                // Önce projeyi al
                let projectDoc = try await projectRef.getDocument()
                guard projectDoc.exists else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Proje bulunamadı"])
                }
                
                // teamMemberIds'e ekle
                try await projectRef.updateData([
                    "teamMemberIds": FieldValue.arrayUnion([currentUser.uid])
                ])
                
                // Kullanıcı bilgilerini al ve teamMembers array'ine ekle
                let userDoc = try await db.collection("users").document(currentUser.uid).getDocument()
                
                let displayName = userDoc.data()?["displayName"] as? String ?? currentUser.displayName ?? "Kullanıcı"
                let photoUrl = userDoc.data()?["photoUrl"] as? String ?? ""
                
                let teamMember: [String: Any] = [
                    "uid": currentUser.uid,
                    "displayName": displayName,
                    "email": currentUser.email ?? "",
                    "photoUrl": photoUrl,
                    "joinedAt": Timestamp(date: Date())
                ]
                
                // teamMembers array'ini güncelle veya oluştur
                let currentData = projectDoc.data()
                var teamMembers = currentData?["teamMembers"] as? [[String: Any]] ?? []
                
                // Kullanıcı zaten teamMembers'da var mı kontrol et
                if !teamMembers.contains(where: { ($0["uid"] as? String) == currentUser.uid }) {
                    teamMembers.append(teamMember)
                    try await projectRef.updateData([
                        "teamMembers": teamMembers
                    ])
                }
                
                print("✅ Davet kabul edildi, projeye eklendi: \(invitation.projectTitle)")
            } else {
                print("✅ Davet reddedildi: \(invitation.projectTitle)")
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
            print("✅ Gönderene bildirim gönderildi")
            
            // Daveti pending listesinden kaldırmak için siliyoruz
            try await db.collection("invitations").document(invitation.id).delete()
            print("🗑️ Davet silindi (pending listesinden kaldırıldı)")
            
            // UI'dan hemen kaldır (listener'ın güncellenmesini beklemeden)
            await MainActor.run {
                self.pendingInvitations.removeAll { $0.id == invitation.id }
                print("✅ Davet UI'dan kaldırıldı, kalan: \(self.pendingInvitations.count)")
            }
            
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Davet yanıtlama hatası: \(error.localizedDescription)")
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
    
    // MARK: - Notification Settings
    
    func saveNotificationSettings(_ settings: [String: Any]) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            try await db.collection("users").document(userId).updateData([
                "notificationSettings": settings
            ])
            print("✅ Bildirim ayarları kaydedildi")
        } catch {
            print("❌ Bildirim ayarları kaydetme hatası: \(error)")
        }
    }
    
    func loadNotificationSettings(completion: @escaping ([String: Any]?) -> Void) async {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }
        
        do {
            let doc = try await db.collection("users").document(userId).getDocument()
            let settings = doc.data()?["notificationSettings"] as? [String: Any]
            await MainActor.run {
                completion(settings)
            }
        } catch {
            print("❌ Bildirim ayarları yükleme hatası: \(error)")
            await MainActor.run {
                completion(nil)
            }
        }
    }
    
    func requestEmailNotificationPermission() async {
        guard let userId = Auth.auth().currentUser?.uid,
              let userEmail = Auth.auth().currentUser?.email else { return }
        
        // E-posta bildirim tercihini Firebase'e kaydet
        do {
            try await db.collection("emailNotificationQueue").addDocument(data: [
                "userId": userId,
                "email": userEmail,
                "type": "preference_update",
                "enabled": true,
                "createdAt": Timestamp(date: Date())
            ])
            print("✅ E-posta bildirim tercihi kaydedildi")
        } catch {
            print("❌ E-posta bildirim tercihi kaydetme hatası: \(error)")
        }
    }
    
    // Check notification settings before sending
    func shouldSendNotification(type: String, userId: String) async -> Bool {
        do {
            let doc = try await db.collection("users").document(userId).getDocument()
            guard let settings = doc.data()?["notificationSettings"] as? [String: Any] else {
                return true // Varsayılan olarak gönder
            }
            
            switch type {
            case "taskReminder":
                return settings["taskReminders"] as? Bool ?? true
            case "projectUpdate":
                return settings["projectUpdates"] as? Bool ?? true
            case "teamActivity":
                return settings["teamActivity"] as? Bool ?? false
            default:
                return settings["pushNotifications"] as? Bool ?? true
            }
        } catch {
            return true // Hata durumunda gönder
        }
    }
    
    // MARK: - Notification Triggers
    
    // Görev hatırlatıcısı gönder
    func sendTaskReminder(taskTitle: String, dueDate: Date, projectTitle: String, assignedUserId: String) async {
        guard await shouldSendNotification(type: "taskReminder", userId: assignedUserId) else { return }
        
        let notification = AppNotification(
            userId: assignedUserId,
            type: .taskDeadline,
            title: "Görev Hatırlatıcısı",
            message: "'\(taskTitle)' görevi yaklaşıyor. Proje: \(projectTitle)",
            relatedId: assignedUserId
        )
        
        do {
            try db.collection("notifications").document(notification.id).setData(from: notification)
            
            // Local notification
            sendLocalNotification(
                title: "Görev Hatırlatıcısı",
                body: notification.message,
                identifier: notification.id,
                category: "TASK_REMINDER"
            )
            
            print("✅ Görev hatırlatıcısı gönderildi")
        } catch {
            print("❌ Görev hatırlatıcısı hatası: \(error)")
        }
    }
    
    // Proje güncellemesi bildir
    func sendProjectUpdate(projectId: String, projectTitle: String, updateMessage: String, teamMemberIds: [String]) async {
        for userId in teamMemberIds {
            guard await shouldSendNotification(type: "projectUpdate", userId: userId) else { continue }
            
            let notification = AppNotification(
                userId: userId,
                type: .projectInvitation,
                title: "Proje Güncellendi",
                message: "'\(projectTitle)': \(updateMessage)",
                relatedId: projectId
            )
            
            do {
                try db.collection("notifications").document(notification.id).setData(from: notification)
                
                sendLocalNotification(
                    title: "Proje Güncellendi",
                    body: notification.message,
                    identifier: notification.id,
                    category: "PROJECT_UPDATE"
                )
            } catch {
                print("❌ Proje güncelleme bildirimi hatası: \(error)")
            }
        }
        print("✅ Proje güncelleme bildirimleri gönderildi")
    }
    
    // Ekip aktivitesi bildir
    func sendTeamActivity(actorName: String, action: String, projectTitle: String, teamMemberIds: [String], actorId: String) async {
        for userId in teamMemberIds where userId != actorId {
            guard await shouldSendNotification(type: "teamActivity", userId: userId) else { continue }
            
            let notification = AppNotification(
                userId: userId,
                type: .teamActivity,
                title: "Ekip Aktivitesi",
                message: "\(actorName) \(action) - \(projectTitle)",
                relatedId: actorId
            )
            
            do {
                try db.collection("notifications").document(notification.id).setData(from: notification)
                
                sendLocalNotification(
                    title: "Ekip Aktivitesi",
                    body: notification.message,
                    identifier: notification.id,
                    category: "TEAM_ACTIVITY"
                )
            } catch {
                print("❌ Ekip aktivitesi bildirimi hatası: \(error)")
            }
        }
        print("✅ Ekip aktivitesi bildirimleri gönderildi")
    }
    
    // E-posta bildirimi kuyruğa ekle
    func queueEmailNotification(userId: String, email: String, subject: String, body: String, type: String) async {
        guard let userDoc = try? await db.collection("users").document(userId).getDocument(),
              let settings = userDoc.data()?["notificationSettings"] as? [String: Any],
              settings["emailNotifications"] as? Bool == true else {
            return
        }
        
        do {
            try await db.collection("emailNotificationQueue").addDocument(data: [
                "userId": userId,
                "email": email,
                "subject": subject,
                "body": body,
                "type": type,
                "status": "pending",
                "createdAt": Timestamp(date: Date())
            ])
            print("✅ E-posta bildirimi kuyruğa eklendi")
        } catch {
            print("❌ E-posta kuyruğa ekleme hatası: \(error)")
        }
    }
}
