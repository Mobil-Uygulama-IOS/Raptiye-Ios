import SwiftUI
import SafariServices

struct ProfileEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var displayName: String = ""
    @State private var email: String = ""
    @State private var bio: String = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showDeleteConfirmation = false
    @State private var showChangePassword = false
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case displayName, bio
    }
    
    var body: some View {
        ZStack {
            // Background with theme
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
                    
                    Text("Profil Bilgileri")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(themeManager.textColor)
                    
                    Spacer()
                    
                    Button(action: {
                        saveProfile()
                    }) {
                        Text("Kaydet")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(isLoading ? themeManager.secondaryTextColor : .blue)
                    }
                    .disabled(isLoading)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 16)
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Avatar
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.3))
                                    .frame(width: 120, height: 120)
                                
                                Text(displayName.prefix(1).uppercased())
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.blue)
                            }
                            
                            Text(displayName.isEmpty ? "Test" : displayName)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(themeManager.textColor)
                            
                            Text(email)
                                .font(.system(size: 15))
                                .foregroundColor(themeManager.secondaryTextColor)
                        }
                        .padding(.top, 20)
                        
                        // Form Fields
                        VStack(spacing: 20) {
                            // Ad Soyad
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Ad Soyad")
                                    .font(.system(size: 14))
                                    .foregroundColor(themeManager.secondaryTextColor)
                                
                                TextField("Ad Soyad", text: $displayName)
                                    .font(.system(size: 16))
                                    .foregroundColor(themeManager.textColor)
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(themeManager.cardBackground)
                                    )
                                    .focused($focusedField, equals: .displayName)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .bio
                                    }
                            }
                            
                            // E-posta
                            VStack(alignment: .leading, spacing: 8) {
                                Text("E-posta")
                                    .font(.system(size: 14))
                                    .foregroundColor(themeManager.secondaryTextColor)
                                
                                TextField("E-posta", text: $email)
                                    .font(.system(size: 16))
                                    .foregroundColor(themeManager.textColor)
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(themeManager.cardBackground)
                                    )
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .disabled(true) // Email cannot be changed
                                    .opacity(0.7)
                            }
                            
                            // Hakkımda
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Hakkımda")
                                    .font(.system(size: 14))
                                    .foregroundColor(themeManager.secondaryTextColor)
                                
                                TextEditor(text: $bio)
                                    .font(.system(size: 16))
                                    .foregroundColor(themeManager.textColor)
                                    .frame(minHeight: 100)
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(themeManager.cardBackground)
                                    )
                                    .scrollContentBackground(.hidden)

                                // Gizlilik Politikası, Hizmet Şartları ve Destek Maili Linkleri
                                VStack(alignment: .leading, spacing: 12) {
                                    Button(action: {
                                        showPrivacyPolicy = true
                                    }) {
                                        HStack {
                                            Text("Gizlilik Politikası")
                                                .font(.system(size: 14))
                                                .foregroundColor(.blue)
                                            Spacer()
                                            Image(systemName: "arrow.up.right.square")
                                                .font(.system(size: 12))
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    
                                    Button(action: {
                                        showTermsOfService = true
                                    }) {
                                        HStack {
                                            Text("Hizmet Şartları")
                                                .font(.system(size: 14))
                                                .foregroundColor(.blue)
                                            Spacer()
                                            Image(systemName: "arrow.up.right.square")
                                                .font(.system(size: 12))
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    
                                    Button(action: {
                                        openMailApp()
                                    }) {
                                        HStack {
                                            Text("Destek: raptiyedestek@gmail.com")
                                                .font(.system(size: 14))
                                                .foregroundColor(.blue)
                                            Spacer()
                                            Image(systemName: "envelope")
                                                .font(.system(size: 12))
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Action Buttons
                        VStack(spacing: 16) {
                            // Şifre Değiştir
                            Button(action: {
                                showChangePassword = true
                            }) {
                                HStack {
                                    Image(systemName: "lock.rotation")
                                        .font(.system(size: 20))
                                    
                                    Text("Şifre Değiştir")
                                        .font(.system(size: 16, weight: .medium))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                }
                                .foregroundColor(themeManager.textColor)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(themeManager.cardBackground)
                                )
                            }
                            
                            // Hesabı Sil
                            Button(action: {
                                showDeleteConfirmation = true
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                        .font(.system(size: 20))
                                    
                                    Text("Hesabı Sil")
                                        .font(.system(size: 16, weight: .medium))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                }
                                .foregroundColor(.red)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(themeManager.cardBackground)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                    .padding(.bottom, 40)
                }
                .onTapGesture {
                    hideKeyboard()
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
        .navigationBarHidden(true)
        .onAppear {
            loadUserData()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Bilgi"),
                message: Text(alertMessage),
                dismissButton: .default(Text("Tamam"))
            )
        }
        .alert("Hesabı Sil", isPresented: $showDeleteConfirmation) {
            Button("İptal", role: .cancel) { }
            Button("Sil", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.")
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            SafariView(url: URL(string: "https://mobil-uygulama-ios.github.io/Raptiye-Ios/privacy-policy.html")!)
        }
        .sheet(isPresented: $showTermsOfService) {
            SafariView(url: URL(string: "https://mobil-uygulama-ios.github.io/Raptiye-Ios/terms-of-service.html")!)
        }
        .sheet(isPresented: $showChangePassword) {
            ChangePasswordView()
                .environmentObject(themeManager)
        }
    }
    
    // MARK: - Functions
    
    private func loadUserData() {
        if let user = authViewModel.userSession {
            displayName = user.displayName ?? ""
            email = user.email ?? ""
        }
        
        // Load bio from Firestore
        Task {
            let loadedBio = await authViewModel.loadUserBio()
            await MainActor.run {
                bio = loadedBio
            }
        }
    }
    
    private func saveProfile() {
        hideKeyboard()
        
        guard !displayName.isEmpty else {
            alertMessage = "Lütfen ad soyad alanını doldurun."
            showAlert = true
            return
        }
        
        isLoading = true
        
        // Update display name and bio in Firebase
        Task {
            await authViewModel.updateProfile(displayName: displayName, bio: bio)
            
            await MainActor.run {
                isLoading = false
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private func deleteAccount() {
        isLoading = true
        
        Task {
            let success = await authViewModel.deleteAccount()
            
            await MainActor.run {
                isLoading = false
                
                if success {
                    presentationMode.wrappedValue.dismiss()
                } else {
                    alertMessage = "Hesap silme işlemi başarısız oldu. Lütfen tekrar giriş yapıp deneyin."
                    showAlert = true
                }
            }
        }
    }
    
    private func hideKeyboard() {
        focusedField = nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func openMailApp() {
        let email = "raptiyedestek@gmail.com"
        let subject = "Destek Talebi"
        let body = ""
        
        let coded = "mailto:\(email)?subject=\(subject)&body=\(body)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        if let emailURL = URL(string: coded ?? ""), UIApplication.shared.canOpenURL(emailURL) {
            UIApplication.shared.open(emailURL)
        }
    }
}

// MARK: - SafariView
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
    }
}

// MARK: - Preview
struct ProfileEditView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileEditView()
            .environmentObject(AuthViewModel())
            .preferredColorScheme(.dark)
    }
}
