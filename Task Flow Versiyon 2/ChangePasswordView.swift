import SwiftUI
import FirebaseAuth

struct ChangePasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isSuccess = false
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case currentPassword, newPassword, confirmPassword
    }
    
    var body: some View {
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
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Text("Şifre Değiştir")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(themeManager.textColor)
                    
                    Spacer()
                    
                    // Balance spacer
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 16)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Lock Icon
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "lock.rotation")
                                .font(.system(size: 36))
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 20)
                        
                        Text("Güvenliğiniz için şifrenizi düzenli olarak değiştirin")
                            .font(.system(size: 14))
                            .foregroundColor(themeManager.secondaryTextColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        // Form Fields
                        VStack(spacing: 20) {
                            // Current Password
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Mevcut Şifre")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(themeManager.secondaryTextColor)
                                
                                SecureField("Mevcut şifrenizi girin", text: $currentPassword)
                                    .font(.system(size: 16))
                                    .foregroundColor(themeManager.textColor)
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(themeManager.cardBackground)
                                    )
                                    .focused($focusedField, equals: .currentPassword)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .newPassword
                                    }
                            }
                            
                            // New Password
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Yeni Şifre")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(themeManager.secondaryTextColor)
                                
                                SecureField("En az 6 karakter", text: $newPassword)
                                    .font(.system(size: 16))
                                    .foregroundColor(themeManager.textColor)
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(themeManager.cardBackground)
                                    )
                                    .focused($focusedField, equals: .newPassword)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .confirmPassword
                                    }
                                
                                // Password strength indicator
                                if !newPassword.isEmpty {
                                    HStack(spacing: 4) {
                                        ForEach(0..<4) { index in
                                            Rectangle()
                                                .fill(passwordStrengthColor(index: index))
                                                .frame(height: 4)
                                                .cornerRadius(2)
                                        }
                                    }
                                    .padding(.top, 4)
                                    
                                    Text(passwordStrengthText)
                                        .font(.system(size: 12))
                                        .foregroundColor(passwordStrengthTextColor)
                                }
                            }
                            
                            // Confirm Password
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Yeni Şifre (Tekrar)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(themeManager.secondaryTextColor)
                                
                                SecureField("Yeni şifrenizi tekrar girin", text: $confirmPassword)
                                    .font(.system(size: 16))
                                    .foregroundColor(themeManager.textColor)
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(themeManager.cardBackground)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(confirmPasswordBorderColor, lineWidth: confirmPassword.isEmpty ? 0 : 2)
                                            )
                                    )
                                    .focused($focusedField, equals: .confirmPassword)
                                    .submitLabel(.done)
                                    .onSubmit {
                                        focusedField = nil
                                    }
                                
                                // Match indicator
                                if !confirmPassword.isEmpty {
                                    HStack(spacing: 4) {
                                        Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                                            .foregroundColor(passwordsMatch ? .green : .red)
                                        
                                        Text(passwordsMatch ? "Şifreler eşleşiyor" : "Şifreler eşleşmiyor")
                                            .font(.system(size: 12))
                                            .foregroundColor(passwordsMatch ? .green : .red)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Change Password Button
                        Button(action: {
                            changePassword()
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Şifreyi Değiştir")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isFormValid ? Color.blue : Color.gray)
                            )
                        }
                        .disabled(!isFormValid || isLoading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Info text
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Şifreniz en az 6 karakter olmalıdır", systemImage: "info.circle")
                            Label("Büyük/küçük harf ve rakam kullanın", systemImage: "info.circle")
                        }
                        .font(.system(size: 13))
                        .foregroundColor(themeManager.secondaryTextColor)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    .padding(.bottom, 40)
                }
                .onTapGesture {
                    focusedField = nil
                }
            }
            
            // Loading overlay
            if isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("Tamam") {
                if isSuccess {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        !currentPassword.isEmpty &&
        newPassword.count >= 6 &&
        passwordsMatch
    }
    
    private var passwordsMatch: Bool {
        !newPassword.isEmpty && newPassword == confirmPassword
    }
    
    private var confirmPasswordBorderColor: Color {
        if confirmPassword.isEmpty { return .clear }
        return passwordsMatch ? .green : .red
    }
    
    private var passwordStrength: Int {
        var strength = 0
        
        // Uzunluk kontrolleri
        if newPassword.count >= 6 { strength += 1 }
        if newPassword.count >= 10 { strength += 1 }
        
        // Büyük harf
        if newPassword.range(of: "[A-Z]", options: .regularExpression) != nil { strength += 1 }
        
        // Küçük harf
        if newPassword.range(of: "[a-z]", options: .regularExpression) != nil { strength += 1 }
        
        // Rakam
        if newPassword.range(of: "[0-9]", options: .regularExpression) != nil { strength += 1 }
        
        // Noktalama işaretleri ve özel karakterler
        if newPassword.range(of: "[!@#$%^&*(),.?\":{}|<>_\\-+=\\[\\]\\\\;'/`~]", options: .regularExpression) != nil { strength += 1 }
        
        // Maksimum 4 olarak sınırla (4 bar için)
        return min(strength, 4)
    }
    
    private var passwordStrengthText: String {
        // Ham puanı hesapla (sınırsız)
        var rawStrength = 0
        if newPassword.count >= 6 { rawStrength += 1 }
        if newPassword.count >= 10 { rawStrength += 1 }
        if newPassword.range(of: "[A-Z]", options: .regularExpression) != nil { rawStrength += 1 }
        if newPassword.range(of: "[a-z]", options: .regularExpression) != nil { rawStrength += 1 }
        if newPassword.range(of: "[0-9]", options: .regularExpression) != nil { rawStrength += 1 }
        if newPassword.range(of: "[!@#$%^&*(),.?\":{}|<>_\\-+=\\[\\]\\\\;'/`~]", options: .regularExpression) != nil { rawStrength += 1 }
        
        switch rawStrength {
        case 0: return "Çok Zayıf"
        case 1: return "Zayıf"
        case 2: return "Zayıf"
        case 3: return "Orta"
        case 4: return "Güçlü"
        case 5...6: return "Çok Güçlü"
        default: return ""
        }
    }
    
    private var passwordStrengthTextColor: Color {
        switch passwordStrength {
        case 0, 1: return .red
        case 2: return .orange
        case 3, 4: return .green
        default: return .gray
        }
    }
    
    private func passwordStrengthColor(index: Int) -> Color {
        if index < passwordStrength {
            switch passwordStrength {
            case 1: return .red
            case 2: return .orange
            case 3: return .yellow
            case 4: return .green
            default: return .gray.opacity(0.3)
            }
        }
        return .gray.opacity(0.3)
    }
    
    // MARK: - Functions
    
    private func changePassword() {
        focusedField = nil
        isLoading = true
        
        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            alertTitle = "Hata"
            alertMessage = "Kullanıcı bilgilerine ulaşılamadı."
            showAlert = true
            isLoading = false
            return
        }
        
        // Re-authenticate user with current password
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        
        user.reauthenticate(with: credential) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    isLoading = false
                    alertTitle = "Hata"
                    alertMessage = "Mevcut şifre yanlış. Lütfen tekrar deneyin."
                    showAlert = true
                }
                print("❌ Re-authentication failed: \(error.localizedDescription)")
                return
            }
            
            // Update password
            user.updatePassword(to: newPassword) { error in
                DispatchQueue.main.async {
                    isLoading = false
                    
                    if let error = error {
                        alertTitle = "Hata"
                        alertMessage = "Şifre değiştirilemedi: \(error.localizedDescription)"
                        showAlert = true
                        print("❌ Password update failed: \(error.localizedDescription)")
                    } else {
                        isSuccess = true
                        alertTitle = "Başarılı"
                        alertMessage = "Şifreniz başarıyla değiştirildi."
                        showAlert = true
                        print("✅ Password updated successfully")
                    }
                }
            }
        }
    }
}

#Preview {
    ChangePasswordView()
        .environmentObject(ThemeManager())
}
