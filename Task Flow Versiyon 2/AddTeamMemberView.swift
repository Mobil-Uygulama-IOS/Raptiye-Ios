//
//  AddTeamMemberView.swift
//  Raptiye
//
//  Created on 2 Aralık 2025.
//

import SwiftUI

struct AddTeamMemberView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var projectManager: ProjectManager
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var localization = LocalizationManager.shared
    
    let project: Project
    
    @State private var searchEmail = ""
    @State private var isSearching = false
    @State private var searchResult: User?
    @State private var errorMessage: String?
    @State private var showSuccess = false
    @State private var successMessage = ""
    @State private var pendingInvitations: [ProjectInvitation] = []
    @FocusState private var isSearchFieldFocused: Bool
    
    let greenAccent = Color(red: 0.40, green: 0.84, blue: 0.55)
    
    // Kullanıcının proje sahibi mi, ekip lideri mi, yoksa sadece üye mi olduğunu kontrol et
    private var isProjectOwner: Bool {
        project.ownerId == projectManager.getCurrentUserId()
    }
    
    private var isTeamLeader: Bool {
        project.teamLeader?.uid == projectManager.getCurrentUserId()
    }
    
    // Proje sahibi ve ekip lideri tüm işlemleri yapabilir
    private var canAddMembers: Bool {
        isProjectOwner || isTeamLeader
    }
    
    // Proje sahibi ve ekip lideri üye çıkarabilir
    private var canRemoveMembers: Bool {
        isProjectOwner || isTeamLeader
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.11, green: 0.13, blue: 0.16)
                    .ignoresSafeArea()
                    .onTapGesture {
                        hideKeyboard()
                    }
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Yetki kontrol mesajı (sadece normal üyeler için)
                        if !canAddMembers {
                            VStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 40))
                                    .foregroundColor(.orange)
                                
                                Text("Yönetim yetkiniz yok")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("Sadece proje sahibi ve ekip lideri ekip yönetimi yapabilir")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.orange.opacity(0.1))
                            )
                        } else {
                            // Search Section (proje sahibi ve ekip lideri görebilir)
                            searchSection
                            
                            // Search Result
                            if let user = searchResult {
                                userResultCard(user)
                            }
                        }
                        
                        // Current Team Members (herkes görebilir)
                        currentTeamSection
                        
                        Spacer(minLength: 40)
                    }
                    .padding()
                }
            }
            .navigationTitle(localization.localizedString("AddTeamMember"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localization.localizedString("Close")) {
                        dismiss()
                    }
                    .foregroundColor(greenAccent)
                }
            }
            .alert(localization.localizedString("Error"), isPresented: .constant(errorMessage != nil)) {
                Button(localization.localizedString("OK")) {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "")
            }
            .alert(localization.localizedString("Success"), isPresented: $showSuccess) {
                Button(localization.localizedString("OK")) {
                    searchEmail = ""
                    searchResult = nil
                }
            } message: {
                Text(successMessage)
            }
            .task {
                await loadPendingInvitations()
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.2.badge.gearshape")
                .font(.system(size: 50))
                .foregroundColor(greenAccent)
            
            Text(localization.localizedString("AddTeamMemberToProject"))
                .font(.title3.bold())
                .foregroundColor(.white)
            
            Text(localization.localizedString("SearchByEmail"))
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical)
    }
    
    // MARK: - Search Section
    private var searchSection: some View {
        VStack(spacing: 16) {
            // Search Field
            HStack(spacing: 12) {
                Image(systemName: "envelope")
                    .foregroundColor(.gray)
                
                TextField(localization.localizedString("EmailAddress"), text: $searchEmail)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .foregroundColor(.white)
                    .focused($isSearchFieldFocused)
                    .submitLabel(.search)
                    .onSubmit {
                        searchUser()
                    }
                
                if !searchEmail.isEmpty {
                    Button(action: { searchEmail = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
            )
            
            // Search Button
            Button(action: searchUser) {
                HStack {
                    if isSearching {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "magnifyingglass")
                        Text(localization.localizedString("SearchUser"))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(greenAccent)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(searchEmail.isEmpty || isSearching)
            .opacity(searchEmail.isEmpty ? 0.6 : 1.0)
        }
    }
    
    // MARK: - User Result Card
    private func userResultCard(_ user: User) -> some View {
        VStack(spacing: 16) {
            HStack {
                // Avatar
                Circle()
                    .fill(greenAccent.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text(user.initials)
                            .font(.title2.bold())
                            .foregroundColor(greenAccent)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.displayName ?? localization.localizedString("User"))
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(user.email ?? "")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            // Check if user already has pending invitation
            if let invitation = pendingInvitations.first(where: { $0.receiverEmail == user.email?.lowercased() }) {
                // Show invitation status
                HStack {
                    Image(systemName: invitation.status == .pending ? "clock" : invitation.status == .accepted ? "checkmark.circle" : "xmark.circle")
                    Text(invitation.status == .pending ? "Davet Gönderildi" : invitation.status == .accepted ? "Kabul Edildi" : "Reddedildi")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(invitation.status == .pending ? Color.orange.opacity(0.2) : invitation.status == .accepted ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                )
                .foregroundColor(invitation.status == .pending ? .orange : invitation.status == .accepted ? .green : .red)
            } else {
                // Send Invitation Button
                Button(action: { 
                    Task {
                        await sendInvitation(to: user)
                    }
                }) {
                    HStack {
                        if notificationManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "paperplane.fill")
                            Text("Davet Gönder")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(greenAccent)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(notificationManager.isLoading)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    // MARK: - Current Team Section
    private var currentTeamSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(localization.localizedString("CurrentTeamMembers"))
                .font(.headline)
                .foregroundColor(.white)
            
            if project.teamMembers.isEmpty && project.teamLeader == nil && pendingInvitations.isEmpty {
                Text(localization.localizedString("NoTeamMembers"))
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    // Team Leader
                    if let leader = project.teamLeader {
                        teamMemberRow(leader, isLeader: true)
                    }
                    
                    // Team Members
                    ForEach(project.teamMembers) { member in
                        teamMemberRow(member, isLeader: false)
                    }
                    
                    // Pending Invitations
                    ForEach(pendingInvitations.filter { $0.status == .pending }) { invitation in
                        pendingInvitationRow(invitation)
                    }
                    
                    // Rejected Invitations
                    ForEach(pendingInvitations.filter { $0.status == .rejected }) { invitation in
                        rejectedInvitationRow(invitation)
                    }
                }
            }
        }
    }
    
    // MARK: - Pending Invitation Row
    private func pendingInvitationRow(_ invitation: ProjectInvitation) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.orange.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "clock")
                        .font(.callout)
                        .foregroundColor(.orange)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(invitation.receiverEmail)
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Text("Davet gönderildi")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("Kabul Bekliyor")
                .font(.caption.bold())
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.2))
                .foregroundColor(.orange)
                .cornerRadius(8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    // MARK: - Rejected Invitation Row
    private func rejectedInvitationRow(_ invitation: ProjectInvitation) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.red.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "xmark")
                        .font(.callout)
                        .foregroundColor(.red)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(invitation.receiverEmail)
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Text("Davet reddedildi")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("Reddetti")
                .font(.caption.bold())
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.2))
                .foregroundColor(.red)
                .cornerRadius(8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    // MARK: - Team Member Row
    private func teamMemberRow(_ user: User, isLeader: Bool) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(greenAccent.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(user.initials)
                        .font(.callout.bold())
                        .foregroundColor(greenAccent)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(user.displayName ?? localization.localizedString("User"))
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Text(user.email ?? "")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if isLeader {
                Text(localization.localizedString("Leader"))
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(greenAccent.opacity(0.2))
                    .foregroundColor(greenAccent)
                    .cornerRadius(8)
            } else {
                // Üye çıkarma butonu (sadece proje sahibi çıkarabilir, ekip lideri çıkaramaz)
                if canRemoveMembers {
                    Button(action: {
                        Task {
                            await removeTeamMember(user)
                        }
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .frame(width: 32, height: 32)
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    // MARK: - Functions
    
    private func loadPendingInvitations() async {
        pendingInvitations = await notificationManager.getInvitationsForProject(project.id.uuidString)
    }
    
    private func searchUser() {
        hideKeyboard()
        
        guard !searchEmail.isEmpty else { return }
        
        // Trim whitespace and convert to lowercase
        let cleanEmail = searchEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        guard !cleanEmail.isEmpty else { return }
        
        isSearching = true
        searchResult = nil
        errorMessage = nil
        
        print("🔍 Kullanıcı aranıyor: \(cleanEmail)")
        
        Task {
            do {
                if let user = try await projectManager.searchUserByEmail(cleanEmail) {
                    print("✅ Kullanıcı bulundu: \(user.displayName ?? "İsimsiz") - \(user.email ?? "")")
                    await MainActor.run {
                        searchResult = user
                        isSearching = false
                    }
                } else {
                    print("⚠️ Kullanıcı bulunamadı: \(searchEmail)")
                    await MainActor.run {
                        errorMessage = localization.localizedString("UserNotFound")
                        isSearching = false
                    }
                }
            } catch {
                print("❌ Arama hatası: \(error.localizedDescription)")
                await MainActor.run {
                    errorMessage = "\(localization.localizedString("SearchError")): \(error.localizedDescription)"
                    isSearching = false
                }
            }
        }
    }
    
    // MARK: - Remove Team Member
    private func removeTeamMember(_ user: User) async {
        do {
            try await projectManager.removeTeamMember(userId: user.uid, from: project.id)
            await MainActor.run {
                successMessage = "\(user.displayName ?? "Kullanıcı") projeden çıkarıldı."
                showSuccess = true
            }
        } catch {
            print("❌ Üye çıkarma hatası: \(error.localizedDescription)")
            await MainActor.run {
                errorMessage = "Üye çıkarılamadı: \(error.localizedDescription)"
            }
        }
    }
    
    private func sendInvitation(to user: User) async {
        guard let email = user.email else { return }
        
        do {
            try await notificationManager.sendInvitation(
                to: email,
                projectId: project.id.uuidString,
                projectTitle: project.title
            )
            await MainActor.run {
                successMessage = "Davet başarıyla gönderildi! Kullanıcı daveti kabul ederse projeye eklenecek."
                showSuccess = true
            }
            // Refresh invitations list
            await loadPendingInvitations()
        } catch {
            print("❌ Davet gönderme hatası: \(error.localizedDescription)")
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func hideKeyboard() {
        isSearchFieldFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Preview
#Preview {
    AddTeamMemberView(project: Project.sampleProjects[0])
        .environmentObject(ProjectManager())
}
