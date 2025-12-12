//
//  EnhancedLoginView.swift
//  Raptiye
//
//  Created on 16 Ekim 2025.
//

import SwiftUI

// MARK: - EnhancedLoginView

struct EnhancedLoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var localization = LocalizationManager.shared
    @State private var isShowingSignUp = false
    @State private var isShowingForgotPassword = false
    @State private var email = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    // Yeşil raptiye rengi
    let greenAccent = Color(red: 0.40, green: 0.84, blue: 0.55)
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                Spacer()
                
                // Logo ve Başlık
                VStack(spacing: 16) {
                    // Yeşil Raptiye İkonu
                    ZStack {
                        Circle()
                            .fill(greenAccent.opacity(0.2))
                            .frame(width: 90, height: 90)
                        
                        Image(systemName: "pin.fill")
                            .font(.system(size: 45, weight: .semibold))
                            .foregroundColor(greenAccent)
                            .rotationEffect(.degrees(45))
                    }
                    .scaleEffect(authViewModel.isLoading ? 0.9 : 1.0)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: authViewModel.isLoading)
                    
                    // App Title
                    VStack(spacing: 6) {
                        Text("Raptiye")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(localization.localizedString("Welcome"))
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
                    .frame(height: 20)
                
                // Login Form Section
                loginFormSection
                    .padding(.horizontal, 28)
                
                Spacer()
            }
            .padding(.bottom, 40)
        }
        .background(
            Color(red: 0.11, green: 0.13, blue: 0.16)
                .ignoresSafeArea()
        )
        .onTapGesture {
            hideKeyboard()
        }
        .sheet(isPresented: $isShowingSignUp) {
            SignUpView()
        }
        .alert(localization.localizedString("ForgotPassword"), isPresented: $isShowingForgotPassword) {
            TextField(localization.localizedString("Email"), text: $email)
            Button(localization.localizedString("Send")) {
                Task {
                    await authViewModel.resetPassword(email: email)
                }
            }
            Button(localization.localizedString("Cancel"), role: .cancel) { }
        } message: {
            Text(localization.localizedString("ForgotPasswordMessage"))
        }
        .alert(localization.localizedString("Error"), isPresented: .constant(authViewModel.errorMessage != nil)) {
            Button(localization.localizedString("OK")) {
                authViewModel.errorMessage = nil
            }
        } message: {
            Text(authViewModel.errorMessage ?? "")
        }
        .alert("Başarılı", isPresented: .constant(authViewModel.successMessage != nil)) {
            Button(localization.localizedString("OK")) {
                authViewModel.successMessage = nil
            }
        } message: {
            Text(authViewModel.successMessage ?? "")
        }
    }
    
    // MARK: - Login Form Section
    private var loginFormSection: some View {
        VStack(spacing: 20) {
            // Email Field
            CustomTextField(
                placeholder: localization.localizedString("Email"),
                text: $email,
                keyboardType: .emailAddress,
                systemImage: "envelope"
            )
            .focused($focusedField, equals: .email)
            .submitLabel(.next)
            .onSubmit {
                focusedField = .password
            }
            
            // Password Field
            CustomSecureField(
                placeholder: localization.localizedString("Password"),
                text: $password,
                systemImage: "lock"
            )
            .focused($focusedField, equals: .password)
            .submitLabel(.go)
            .onSubmit {
                Task {
                    await signIn()
                }
            }
            
            // Forgot Password Button
            HStack {
                Spacer()
                Button(localization.localizedString("ForgotPassword")) {
                    isShowingForgotPassword = true
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(greenAccent)
            }
            .padding(.top, -8)
            
            // Sign In Button - Yeşil
            Button(action: {
                Task {
                    await signIn()
                }
            }) {
                HStack {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text(localization.localizedString("SignIn"))
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
            .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty)
            .opacity(authViewModel.isLoading || email.isEmpty || password.isEmpty ? 0.6 : 1.0)
            .padding(.top, 16)
            
            // Sign Up Option
            HStack(spacing: 4) {
                Text(localization.localizedString("NoAccount"))
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                
                Button(localization.localizedString("SignUp")) {
                    isShowingSignUp = true
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(greenAccent)
            }
            .padding(.top, 20)
        }
    }
    
    // MARK: - Functions
    private func signIn() async {
        hideKeyboard()
        await authViewModel.signIn(email: email, password: password)
    }
    
    private func hideKeyboard() {
        focusedField = nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Custom TextField
struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    let systemImage: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 20))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 24)
            
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.gray))
                .font(.system(size: 16))
                .foregroundColor(.white)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Custom SecureField
struct CustomSecureField: View {
    let placeholder: String
    @Binding var text: String
    let systemImage: String
    @State private var isSecured = true
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 20))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 24)
            
            Group {
                if isSecured {
                    SecureField(placeholder, text: $text)
                        .textContentType(.password)
                } else {
                    TextField(placeholder, text: $text)
                        .textContentType(.password)
                }
            }
            .font(.system(size: 16))
            .foregroundColor(.white)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .textInputAutocapitalization(.never)
            
            Button(action: {
                isSecured.toggle()
            }) {
                Image(systemName: isSecured ? "eye.slash" : "eye")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Placeholder Extension
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// MARK: - Preview
#Preview {
    EnhancedLoginView()
        .environmentObject(AuthViewModel())
}
