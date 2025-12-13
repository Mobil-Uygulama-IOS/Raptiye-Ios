import SwiftUI

struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var localization = LocalizationManager.shared
    
    @State private var isLoading = true
    
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
                                .frame(width: 36, height: 36)
                                .background(themeManager.cardBackground)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        Text(localization.localizedString("About"))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(themeManager.textColor)
                        
                        Spacer()
                        
                        // Balance spacer
                        Color.clear
                            .frame(width: 36, height: 36)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    
                    if isLoading {
                        VStack {
                            Spacer()
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.blue)
                            Text(localization.localizedString("Loading"))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.top, 16)
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            VStack(spacing: 32) {
                                // App Icon & Name
                                VStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 0.40, green: 0.84, blue: 0.55).opacity(0.2))
                                        .frame(width: 120, height: 120)
                                    
                                    Image(systemName: "pin.fill")
                                        .font(.system(size: 60, weight: .semibold))
                                        .foregroundColor(Color(red: 0.40, green: 0.84, blue: 0.55))
                                        .rotationEffect(.degrees(45))
                                }
                                
                                VStack(spacing: 8) {
                                    Text("Raptiye")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(themeManager.textColor)
                                    
                                    Text(localization.localizedString("Version"))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.top, 20)
                            
                            // Description
                            VStack(alignment: .leading, spacing: 16) {
                                Text(localization.localizedString("AboutRaptiye"))
                                    .font(.headline)
                                    .foregroundColor(themeManager.textColor)
                                    .padding(.horizontal, 20)
                                
                                Text(localization.localizedString("AboutRaptiyeDescription"))
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal, 20)
                            }
                            
                            // Features
                            VStack(alignment: .leading, spacing: 16) {
                                Text(localization.localizedString("KeyFeatures"))
                                    .font(.headline)
                                    .foregroundColor(themeManager.textColor)
                                    .padding(.horizontal, 20)
                                
                                VStack(spacing: 12) {
                                    FeatureRow(icon: "folder.badge.plus", title: localization.localizedString("ProjectManagement"), description: localization.localizedString("CreateManageMultipleProjects"))
                                    FeatureRow(icon: "list.bullet.clipboard", title: localization.localizedString("TaskTracking"), description: localization.localizedString("KeepTrackAllTasks"))
                                    FeatureRow(icon: "person.3", title: localization.localizedString("TeamCollaboration"), description: localization.localizedString("WorkTogetherTeam"))
                                    FeatureRow(icon: "chart.bar", title: localization.localizedString("Analytics"), description: localization.localizedString("TrackProgressDetailedAnalytics"))
                                    FeatureRow(icon: "globe", title: localization.localizedString("MultiLanguage"), description: localization.localizedString("SupportTurkishEnglish"))
                                }
                                .padding(.horizontal, 20)
                            }
                            
                            // Links
                            VStack(spacing: 12) {
                                Button(action: {
                                    // Open privacy policy
                                    if let url = URL(string: "https://mobil-uygulama-ios.github.io/Raptiye-Ios/privacy-policy.html") {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "hand.raised.fill")
                                            .foregroundColor(.blue)
                                        Text(localization.localizedString("PrivacyPolicy"))
                                            .foregroundColor(themeManager.textColor)
                                        Spacer()
                                        Image(systemName: "arrow.up.right")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(16)
                                    .background(themeManager.cardBackground)
                                    .cornerRadius(12)
                                }
                                
                                Button(action: {
                                    // Open terms of service
                                    if let url = URL(string: "https://mobil-uygulama-ios.github.io/Raptiye-Ios/terms-of-service.html") {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "doc.text.fill")
                                            .foregroundColor(.blue)
                                        Text(localization.localizedString("TermsOfService"))
                                            .foregroundColor(themeManager.textColor)
                                        Spacer()
                                        Image(systemName: "arrow.up.right")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(16)
                                    .background(themeManager.cardBackground)
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Copyright
                            Text(localization.localizedString("AllRightsReserved"))
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.bottom, 40)
                        }
                        .padding(.vertical, 20)
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isLoading = false
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(themeManager.textColor)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(16)
        .background(themeManager.cardBackground)
        .cornerRadius(12)
    }
}

#Preview {
    AboutView()
        .environmentObject(ThemeManager.shared)
}
