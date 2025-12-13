//
//  ProfileView.swift
//  Raptiye
//
//  Created on 17 Ekim 2025.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var localization = LocalizationManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var bio: String = ""
    @State private var isEditMode: Bool = false
    @State private var showImagePicker: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.title3)
                                .foregroundColor(themeManager.textColor)
                                .frame(width: 36, height: 36)
                                .background(themeManager.cardBackground)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        Text(localization.localizedString("ProfileInformation"))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(themeManager.textColor)
                        
                        Spacer()
                        
                        Button(action: {
                            if isEditMode {
                                saveProfile()
                            }
                            isEditMode.toggle()
                        }) {
                            Text(isEditMode ? localization.localizedString("Save") : localization.localizedString("Edit"))
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    
                    // Content
                    ScrollView {
                        VStack(spacing: 24) {
                            // Avatar Section
                            VStack(spacing: 16) {
                                Button(action: {
                                    if isEditMode {
                                        showImagePicker = true
                                    }
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.blue.opacity(0.2))
                                            .frame(width: 120, height: 120)
                                        
                                        if let user = authViewModel.userSession {
                                            Text(user.displayName?.prefix(1).uppercased() ?? "U")
                                                .font(.system(size: 48, weight: .bold))
                                                .foregroundColor(.blue)
                                        }
                                        
                                        if isEditMode {
                                            VStack {
                                                Spacer()
                                                HStack {
                                                    Spacer()
                                                    Image(systemName: "camera.fill")
                                                        .font(.system(size: 16))
                                                        .foregroundColor(.white)
                                                        .frame(width: 32, height: 32)
                                                        .background(Color.blue)
                                                        .clipShape(Circle())
                                                        .offset(x: -8, y: -8)
                                                }
                                            }
                                            .frame(width: 120, height: 120)
                                        }
                                    }
                                }
                                .disabled(!isEditMode)
                                
                                if !isEditMode, let user = authViewModel.userSession {
                                    Text(user.displayName ?? localization.localizedString("User"))
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(themeManager.textColor)
                                    
                                    Text(user.email ?? "")
                                        .font(.subheadline)
                                        .foregroundColor(themeManager.secondaryTextColor)
                                }
                            }
                            .padding(.top, 24)
                            
                            // Profile Information Fields
                            VStack(spacing: 20) {
                                // Full Name Field
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(localization.localizedString("FullName"))
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(themeManager.secondaryTextColor)
                                    
                                    if isEditMode {
                                        TextField(localization.localizedString("FullName"), text: $fullName)
                                            .font(.body)
                                            .foregroundColor(themeManager.textColor)
                                            .padding(16)
                                            .background(themeManager.searchBackground)
                                            .cornerRadius(12)
                                    } else {
                                        Text(fullName.isEmpty ? "-" : fullName)
                                            .font(.body)
                                            .foregroundColor(themeManager.textColor)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(16)
                                            .background(themeManager.cardBackground)
                                            .cornerRadius(12)
                                    }
                                }
                                
                                // Email Field
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(localization.localizedString("Email"))
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(themeManager.secondaryTextColor)
                                    
                                    Text(email.isEmpty ? "-" : email)
                                        .font(.body)
                                        .foregroundColor(themeManager.textColor)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(16)
                                        .background(themeManager.cardBackground)
                                        .cornerRadius(12)
                                }
                                
                                // Bio Field
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(localization.localizedString("Bio"))
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(themeManager.secondaryTextColor)
                                    
                                    if isEditMode {
                                        TextEditor(text: $bio)
                                            .font(.body)
                                            .foregroundColor(themeManager.textColor)
                                            .frame(minHeight: 100)
                                            .padding(12)
                                            .background(themeManager.searchBackground)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                            )
                                    } else {
                                        Text(bio.isEmpty ? "-" : bio)
                                            .font(.body)
                                            .foregroundColor(themeManager.textColor)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(16)
                                            .background(themeManager.cardBackground)
                                            .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Account Actions
                            VStack(spacing: 12) {
                                Button(action: {
                                    // Change password action
                                }) {
                                    HStack {
                                        Image(systemName: "lock.rotation")
                                            .font(.title3)
                                            .foregroundColor(.blue)
                                        
                                        Text(localization.localizedString("ChangePassword"))
                                            .font(.body)
                                            .fontWeight(.medium)
                                            .foregroundColor(themeManager.textColor)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(themeManager.secondaryTextColor)
                                    }
                                    .padding(16)
                                    .background(themeManager.cardBackground)
                                    .cornerRadius(12)
                                }
                                
                                Button(action: {
                                    // Delete account action
                                }) {
                                    HStack {
                                        Image(systemName: "trash")
                                            .font(.title3)
                                            .foregroundColor(.red)
                                        
                                        Text(localization.localizedString("DeleteAccount"))
                                            .font(.body)
                                            .fontWeight(.medium)
                                            .foregroundColor(.red)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(themeManager.secondaryTextColor)
                                    }
                                    .padding(16)
                                    .background(themeManager.cardBackground)
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadProfile()
        }
    }
    
    private func loadProfile() {
        if let user = authViewModel.userSession {
            fullName = user.displayName ?? ""
            email = user.email ?? ""
            // Bio would be loaded from user profile if available
            bio = ""
        }
    }
    
    private func saveProfile() {
        // Save profile changes to backend
        // For now, just mock save
        print("Profile saved: \(fullName)")
    }
}

// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel())
            .environmentObject(ThemeManager.shared)
            .preferredColorScheme(.dark)
        
        ProfileView()
            .environmentObject(AuthViewModel())
            .environmentObject(ThemeManager.shared)
            .preferredColorScheme(.light)
    }
}
