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
    @StateObject private var localization = LocalizationManager.shared
    
    let project: Project
    
    @State private var searchEmail = ""
    @State private var isSearching = false
    @State private var searchResult: User?
    @State private var errorMessage: String?
    @State private var showSuccess = false
    @FocusState private var isSearchFieldFocused: Bool
    
    let greenAccent = Color(red: 0.40, green: 0.84, blue: 0.55)
    
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
                        
                        // Search Section
                        searchSection
                        
                        // Search Result
                        if let user = searchResult {
                            userResultCard(user)
                        }
                        
                        // Current Team Members
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
                Text(localization.localizedString("TeamMemberAddedSuccess"))
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
            
            // Add Button
            Button(action: { 
                Task {
                    await addTeamMember(user)
                }
            }) {
                HStack {
                    Image(systemName: "person.badge.plus")
                    Text(localization.localizedString("AddToProject"))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(greenAccent)
                .foregroundColor(.white)
                .cornerRadius(12)
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
            
            if project.teamMembers.isEmpty && project.teamLeader == nil {
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
                }
            }
        }
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
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    // MARK: - Functions
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
    
    private func addTeamMember(_ user: User) async {
        do {
            print("🎯 Eklenecek kullanıcı: \(user.displayName ?? "N/A") - UID: \(user.uid)")
            try await projectManager.addTeamMember(userId: user.uid, to: project.id)
            await MainActor.run {
                showSuccess = true
            }
        } catch {
            print("❌ Ekleme hatası: \(error.localizedDescription)")
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
