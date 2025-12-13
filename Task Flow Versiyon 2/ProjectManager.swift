//
//  ProjectManager.swift
//  Task Flow Versiyon 2
//
//  Created on 4 Kasım 2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
class ProjectManager: ObservableObject {
    @Published var projects: [Project] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    init() {
        // Listener'ı init'te başlatma - kullanıcı giriş yaptıktan sonra başlatılacak
    }
    
    // MARK: - Real-time Listener
    
    func setupListener() {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        // Eski listener varsa kaldır
        listener?.remove()
        
        // Loading başlat
        isLoading = true
        
        // Root seviyedeki projects koleksiyonunu dinle
        listener = db.collection("projects")
            .whereFilter(Filter.orFilter([
                Filter.whereField("ownerId", isEqualTo: userId),
                Filter.whereField("teamMemberIds", arrayContains: userId)
            ]))
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                        self.isLoading = false
                    }
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                    return
                }
                
                // Parse işlemini arka planda yap
                let parsedProjects = documents.compactMap { doc -> Project? in
                    try? doc.data(as: Project.self)
                }
                
                // UI güncellemesini main thread'de yap
                DispatchQueue.main.async {
                    self.projects = parsedProjects
                    self.isLoading = false
                }
            }
    }
    
    // MARK: - Fetch Projects
    
    func fetchProjects() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "Kullanıcı oturum açmamış"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Root seviyedeki projects koleksiyonundan fetch et
            let snapshot = try await db.collection("projects")
                .whereFilter(Filter.orFilter([
                    Filter.whereField("ownerId", isEqualTo: userId),
                    Filter.whereField("teamMemberIds", arrayContains: userId)
                ]))
                .getDocuments()
            
            self.projects = snapshot.documents.compactMap { doc -> Project? in
                try? doc.data(as: Project.self)
            }
            
            print("✅ \(self.projects.count) proje yüklendi")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Proje yükleme hatası: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Create Project
    
    func createProject(_ project: Project) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oturum açmamış"])
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Root seviyedeki projects koleksiyonuna ekle
            var projectToSave = project
            projectToSave.ownerId = userId
            
            // Proje sahibini teamMemberIds'e de ekle
            if !projectToSave.teamMemberIds.contains(userId) {
                projectToSave.teamMemberIds.append(userId)
            }
            
            // Proje sahibini teamMembers array'ine User objesi olarak ekle
            if let currentUser = Auth.auth().currentUser {
                let ownerUser = User(
                    uid: currentUser.uid,
                    displayName: currentUser.displayName ?? "Kullanıcı",
                    email: currentUser.email,
                    photoUrl: nil,
                    createdAt: Date()
                )
                
                // Zaten listede yoksa ekle
                if !projectToSave.teamMembers.contains(where: { $0.uid == ownerUser.uid }) {
                    projectToSave.teamMembers.append(ownerUser)
                    print("👤 Proje sahibi team members'a eklendi: \(ownerUser.displayName ?? "")")
                }
            }
            
            let projectRef = db.collection("projects")
                .document(project.id.uuidString)
            
            try projectRef.setData(from: projectToSave)
            
            print("✅ Proje oluşturuldu: \(project.title)")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Proje oluşturma hatası: \(error)")
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - Update Project
    
    func updateProject(_ project: Project) async throws {
        guard Auth.auth().currentUser != nil else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oturum açmamış"])
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Root seviyedeki projects koleksiyonunu güncelle
            let projectRef = db.collection("projects")
                .document(project.id.uuidString)
            
            try projectRef.setData(from: project, merge: true)
            
            // Proje güncelleme bildirimi gönder
            await NotificationManager.shared.sendProjectUpdate(
                projectId: project.id.uuidString,
                projectTitle: project.title,
                updateMessage: "Proje bilgileri güncellendi",
                teamMemberIds: project.teamMemberIds
            )
            
            print("✅ Proje güncellendi: \(project.title)")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Proje güncelleme hatası: \(error)")
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - Delete Project
    
    func deleteProject(_ project: Project) async throws {
        guard Auth.auth().currentUser != nil else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oturum açmamış"])
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Root seviyedeki projects koleksiyonundan sil
            try await db.collection("projects")
                .document(project.id.uuidString)
                .delete()
            
            print("✅ Proje silindi: \(project.title)")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Proje silme hatası: \(error)")
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - Add Task to Project
    
    func addTask(_ task: ProjectTask, to projectId: UUID) async throws {
        guard Auth.auth().currentUser?.uid != nil else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oturum açmamış"])
        }
        
        guard let projectIndex = projects.firstIndex(where: { $0.id == projectId }) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Proje bulunamadı"])
        }
        
        var project = projects[projectIndex]
        project.tasks.append(task)
        
        try await updateProject(project)
        
        print("✅ Görev eklendi: \(task.title)")
    }
    
    // MARK: - Update Task
    
    func updateTask(_ task: ProjectTask, in projectId: UUID) async throws {
        guard let projectIndex = projects.firstIndex(where: { $0.id == projectId }) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Proje bulunamadı"])
        }
        
        var project = projects[projectIndex]
        
        if let taskIndex = project.tasks.firstIndex(where: { $0.id == task.id }) {
            project.tasks[taskIndex] = task
            try await updateProject(project)
            print("✅ Görev güncellendi: \(task.title)")
        }
    }
    
    // MARK: - Delete Task
    
    func deleteTask(_ taskId: UUID, from projectId: UUID) async throws {
        guard let projectIndex = projects.firstIndex(where: { $0.id == projectId }) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Proje bulunamadı"])
        }
        
        var project = projects[projectIndex]
        project.tasks.removeAll { $0.id == taskId }
        
        try await updateProject(project)
        
        print("✅ Görev silindi")
    }
    
    // MARK: - Toggle Task Completion
    
    func toggleTaskCompletion(_ taskId: UUID, in projectId: UUID) async throws {
        guard let projectIndex = projects.firstIndex(where: { $0.id == projectId }) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Proje bulunamadı"])
        }
        
        var project = projects[projectIndex]
        
        if let taskIndex = project.tasks.firstIndex(where: { $0.id == taskId }) {
            project.tasks[taskIndex].isCompleted.toggle()
            try await updateProject(project)
            print("✅ Görev durumu değiştirildi")
        }
    }
    
    // MARK: - Team Management
    
    /// Email ile kullanıcı ara
    func searchUserByEmail(_ email: String) async throws -> User? {
        print("🔍 Firestore'da kullanıcı aranıyor: \(email.lowercased())")
        
        let snapshot = try await db.collection("users")
            .whereField("email", isEqualTo: email.lowercased())
            .limit(to: 1)
            .getDocuments()
        
        print("📊 Bulunan döküman sayısı: \(snapshot.documents.count)")
        
        guard let document = snapshot.documents.first else {
            print("⚠️ Firestore'da kullanıcı bulunamadı")
            return nil
        }
        
        print("✅ Firestore'da kullanıcı bulundu: \(document.documentID)")
        
        let user = try? document.data(as: User.self)
        if let user = user {
            print("✅ User decode başarılı: \(user.displayName ?? "İsimsiz")")
        } else {
            print("❌ User decode başarısız")
        }
        
        return user
    }
    
    /// Projeye ekip üyesi ekle
    func addTeamMember(userId: String, to projectId: UUID) async throws {
        guard Auth.auth().currentUser != nil else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oturum açmamış"])
        }
        
        guard let projectIndex = projects.firstIndex(where: { $0.id == projectId }) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Proje bulunamadı"])
        }
        
        var project = projects[projectIndex]
        
        print("🔍 Ekleme denemesi - Proje: \(project.title), Eklenecek User ID: \(userId)")
        print("📋 Mevcut ekip üyeleri: \(project.teamMembers.map { $0.uid })")
        
        // Kullanıcı zaten ekip üyesi mi?
        if project.teamMembers.contains(where: { $0.uid == userId }) {
            print("⚠️ Kullanıcı zaten ekip üyesi")
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı zaten ekip üyesi"])
        }
        
        // Kullanıcı proje lideri mi?
        if project.teamLeader?.uid == userId {
            print("⚠️ Kullanıcı zaten proje lideri")
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı zaten proje lideri"])
        }
        
        // Kullanıcı bilgisini al
        print("📡 Firestore'dan kullanıcı bilgisi alınıyor: \(userId)")
        let userDoc = try await db.collection("users").document(userId).getDocument()
        
        if !userDoc.exists {
            print("❌ Döküman Firestore'da yok!")
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Bu kullanıcı sistemde kayıtlı değil. Lütfen kullanıcının uygulamaya giriş yapması gerekiyor."])
        }
        
        print("📄 Döküman bulundu, data: \(userDoc.data() ?? [:])")
        
        guard let user = try? userDoc.data(as: User.self) else {
            print("❌ User decode hatası!")
            if let data = userDoc.data() {
                print("📋 Raw data: \(data)")
            }
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı bilgisi okunamadı"])
        }
        
        print("✅ Kullanıcı bulundu ve decode edildi: \(user.displayName ?? user.email ?? "Unknown")")
        
        // Zaten teamMemberIds'de var mı kontrol et
        if project.teamMemberIds.contains(userId) {
            print("⚠️ Kullanıcı zaten ekip üyesi (teamMemberIds)")
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı zaten ekip üyesi"])
        }
        
        // Projeye ekle (hem User objesini hem de ID'yi)
        project.teamMembers.append(user)
        project.teamMemberIds.append(userId)
        
        // Firebase'e kaydet (root-level projects koleksiyonuna)
        try await updateProject(project)
        
        print("✅ Ekip üyesi başarıyla eklendi: \(user.displayName ?? user.email ?? "Unknown")")
    }
    
    /// Projeden ekip üyesi çıkar
    func removeTeamMember(userId: String, from projectId: UUID) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oturum açmamış"])
        }
        
        guard let projectIndex = projects.firstIndex(where: { $0.id == projectId }) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Proje bulunamadı"])
        }
        
        var project = projects[projectIndex]
        
        // Proje sahibi mi kontrol et
        if project.teamLeader?.uid != currentUserId {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Sadece proje sahibi ekip üyesi çıkarabilir"])
        }
        
        // Ekip üyesini çıkar (hem User objesinden hem de ID array'inden)
        project.teamMembers.removeAll { $0.uid == userId }
        project.teamMemberIds.removeAll { $0 == userId }
        
        // Firebase'e kaydet
        try await updateProject(project)
        
        // Kullanıcının projeler listesinden çıkar
        try await db.collection("users")
            .document(userId)
            .updateData([
                "projects": FieldValue.arrayRemove([projectId.uuidString])
            ])
        
        print("✅ Ekip üyesi çıkarıldı")
    }
    
    // MARK: - Get Current User ID
    
    func getCurrentUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    // MARK: - Cleanup
    
    deinit {
        listener?.remove()
    }
}
