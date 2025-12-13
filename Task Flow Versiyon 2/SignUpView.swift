//
//  SignUpView.swift
//  Raptiye
//
//  Created on 16 Ekim 2025.
//

import SwiftUI
import SafariServices

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var localization = LocalizationManager.shared
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPasswordMismatchAlert = false
    @State private var agreedToTerms = false
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, email, password, confirmPassword
    }
    
    // Yeşil raptiye rengi
    let greenAccent = Color(red: 0.40, green: 0.84, blue: 0.55)
    let darkBackground = Color(red: 0.11, green: 0.13, blue: 0.16)
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        // Header Section
                        headerSection
                            .frame(height: geometry.size.height * 0.25)
                        
                        // Sign Up Form Section
                        signUpFormSection
                            .padding(.horizontal, 32)
                            .padding(.top, 40)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .background(darkBackground)
            .ignoresSafeArea()
            .navigationBarHidden(true)
            .onTapGesture {
                hideKeyboard()
            }
            .alert(localization.localizedString("PasswordsDoNotMatch"), isPresented: $showPasswordMismatchAlert) {
                Button(localization.localizedString("OK"), role: .cancel) { }
            } message: {
                Text(localization.localizedString("PasswordsDoNotMatchMessage"))
            }
            .alert(localization.localizedString("Error"), isPresented: .constant(authViewModel.errorMessage != nil)) {
                Button(localization.localizedString("OK")) {
                    authViewModel.errorMessage = nil
                }
            } message: {
                Text(authViewModel.errorMessage ?? "")
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                SafariView(url: URL(string: "https://mobil-uygulama-ios.github.io/Raptiye-Ios/privacy-policy.html")!)
            }
            .sheet(isPresented: $showTermsOfService) {
                SafariView(url: URL(string: "https://mobil-uygulama-ios.github.io/Raptiye-Ios/terms-of-service.html")!)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .padding(.leading, 20)
                
                Spacer()
            }
            .padding(.top, 20)
            
            Spacer()
            
            // Yeşil Raptiye İkonu
            ZStack {
                Circle()
                    .fill(greenAccent.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "pin.fill")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(greenAccent)
                    .rotationEffect(.degrees(45))
            }
            
            // Title
            Text(localization.localizedString("CreateAccount"))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
        }
    }
    
    // MARK: - Sign Up Form Section
    private var signUpFormSection: some View {
        VStack(spacing: 24) {
            // Welcome Text
            VStack(spacing: 8) {
                Text(localization.localizedString("CreateAccount"))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(localization.localizedString("CreateAccountSubtitle"))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.bottom, 20)
            
            // Name Field
            CustomTextField(
                placeholder: localization.localizedString("FullName"),
                text: $name,
                keyboardType: .default,
                systemImage: "person"
            )
            .focused($focusedField, equals: .name)
            .submitLabel(.next)
            .onSubmit { focusedField = .email }
            
            // Email Field
            CustomTextField(
                placeholder: localization.localizedString("Email"),
                text: $email,
                keyboardType: .emailAddress,
                systemImage: "envelope"
            )
            .focused($focusedField, equals: .email)
            .submitLabel(.next)
            .onSubmit { focusedField = .password }
            
            // Password Field
            VStack(alignment: .leading, spacing: 8) {
                CustomSecureField(
                    placeholder: localization.localizedString("Password"),
                    text: $password,
                    systemImage: "lock"
                )
                .focused($focusedField, equals: .password)
                .submitLabel(.next)
                .onSubmit { focusedField = .confirmPassword }
                
                // Password strength indicator
                if !password.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(0..<4) { index in
                            Rectangle()
                                .fill(passwordStrengthColor(index: index))
                                .frame(height: 4)
                                .cornerRadius(2)
                        }
                    }
                    
                    Text(passwordStrengthText)
                        .font(.system(size: 12))
                        .foregroundColor(passwordStrengthTextColor)
                }
            }
            
            // Confirm Password Field
            CustomSecureField(
                placeholder: localization.localizedString("PasswordConfirm"),
                text: $confirmPassword,
                systemImage: "lock"
            )
            .focused($focusedField, equals: .confirmPassword)
            .submitLabel(.go)
            .onSubmit {
                Task {
                    await signUp()
                }
            }
            
            // Terms and Privacy Agreement
            HStack(alignment: .top, spacing: 12) {
                Button(action: {
                    agreedToTerms.toggle()
                }) {
                    Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                        .font(.system(size: 22))
                        .foregroundColor(agreedToTerms ? greenAccent : .white.opacity(0.5))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(localization.localizedString("IAgreeToThe"))
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Button(action: {
                            showPrivacyPolicy = true
                        }) {
                            Text(localization.localizedString("PrivacyPolicy"))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(greenAccent)
                                .underline()
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Text(localization.localizedString("AndThe"))
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Button(action: {
                            showTermsOfService = true
                        }) {
                            Text(localization.localizedString("TermsOfService"))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(greenAccent)
                                .underline()
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.top, 8)
            
            // Sign Up Button - Yeşil
            Button(action: {
                Task {
                    await signUp()
                }
            }) {
                HStack {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text(localization.localizedString("SignUp"))
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(greenAccent)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: greenAccent.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .disabled(authViewModel.isLoading || name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || !agreedToTerms)
            .opacity(authViewModel.isLoading || name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || !agreedToTerms ? 0.6 : 1.0)
            .padding(.top, 16)
            
            // Sign In Option
            HStack(spacing: 4) {
                Text(localization.localizedString("AlreadyHaveAccount"))
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                
                Button(localization.localizedString("SignIn")) {
                    presentationMode.wrappedValue.dismiss()
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(greenAccent)
            }
            .padding(.top, 20)
        }
    }
    
    // MARK: - Functions
    private func signUp() async {
        hideKeyboard()
        
        // Şifrelerin eşleşip eşleşmediğini kontrol et
        guard password == confirmPassword else {
            showPasswordMismatchAlert = true
            return
        }
        
        // Firebase sign up
        await authViewModel.signUp(email: email, password: password, fullName: name)
        
        // Başarılı olursa sayfayı kapat
        if authViewModel.userSession != nil {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func hideKeyboard() {
        focusedField = nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // MARK: - Password Strength
    
    private var passwordStrength: Int {
        var strength = 0
        
        // Uzunluk kontrolleri
        if password.count >= 6 { strength += 1 }
        if password.count >= 10 { strength += 1 }
        
        // Büyük harf
        if password.range(of: "[A-Z]", options: .regularExpression) != nil { strength += 1 }
        
        // Küçük harf
        if password.range(of: "[a-z]", options: .regularExpression) != nil { strength += 1 }
        
        // Rakam
        if password.range(of: "[0-9]", options: .regularExpression) != nil { strength += 1 }
        
        // Özel karakterler
        if password.range(of: "[!@#$%^&*(),.?\":{}|<>_\\-+=\\[\\]\\\\;'/`~]", options: .regularExpression) != nil { strength += 1 }
        
        return min(strength, 4)
    }
    
    private var passwordStrengthText: String {
        var rawStrength = 0
        if password.count >= 6 { rawStrength += 1 }
        if password.count >= 10 { rawStrength += 1 }
        if password.range(of: "[A-Z]", options: .regularExpression) != nil { rawStrength += 1 }
        if password.range(of: "[a-z]", options: .regularExpression) != nil { rawStrength += 1 }
        if password.range(of: "[0-9]", options: .regularExpression) != nil { rawStrength += 1 }
        if password.range(of: "[!@#$%^&*(),.?\":{}|<>_\\-+=\\[\\]\\\\;'/`~]", options: .regularExpression) != nil { rawStrength += 1 }
        
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
        case 0: return .red
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .green
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
}

// MARK: - Preview
struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(AuthViewModel())
    }
}
