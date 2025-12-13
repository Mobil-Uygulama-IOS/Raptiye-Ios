import SwiftUI

struct HelpView: View {
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
                        
                        Text(localization.localizedString("Help"))
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
                            VStack(spacing: 24) {
                            // Getting Started
                            HelpSection(
                                title: localization.localizedString("GettingStarted"),
                                items: [
                                    HelpItem(question: localization.localizedString("HowCreateProject"), answer: localization.localizedString("HowCreateProjectAnswer")),
                                    HelpItem(question: localization.localizedString("HowAddTeamMembers"), answer: localization.localizedString("HowAddTeamMembersAnswer")),
                                    HelpItem(question: localization.localizedString("HowAddTasks"), answer: localization.localizedString("HowAddTasksAnswer"))
                                ]
                            )
                            
                            // Managing Projects
                            HelpSection(
                                title: localization.localizedString("ManagingProjects"),
                                items: [
                                    HelpItem(question: localization.localizedString("HowEditProject"), answer: localization.localizedString("HowEditProjectAnswer")),
                                    HelpItem(question: localization.localizedString("HowDeleteProject"), answer: localization.localizedString("HowDeleteProjectAnswer")),
                                    HelpItem(question: localization.localizedString("HowTrackProgress"), answer: localization.localizedString("HowTrackProgressAnswer"))
                                ]
                            )
                            
                            // Account & Settings
                            HelpSection(
                                title: localization.localizedString("AccountSettings"),
                                items: [
                                    HelpItem(question: localization.localizedString("HowChangeProfile"), answer: localization.localizedString("HowChangeProfileAnswer")),
                                    HelpItem(question: localization.localizedString("HowChangeLanguage"), answer: localization.localizedString("HowChangeLanguageAnswer")),
                                    HelpItem(question: localization.localizedString("HowEnableDarkMode"), answer: localization.localizedString("HowEnableDarkModeAnswer"))
                                ]
                            )
                            
                            // Contact Support
                            VStack(alignment: .leading, spacing: 16) {
                                Text(localization.localizedString("NeedMoreHelp"))
                                    .font(.headline)
                                    .foregroundColor(themeManager.textColor)
                                    .padding(.horizontal, 20)
                                
                                VStack(spacing: 12) {
                                    Button(action: {
                                        // Email support
                                        if let url = URL(string: "mailto:raptiyedestek@gmail.com?subject=Destek%20Talebi") {
                                            UIApplication.shared.open(url)
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "envelope.fill")
                                                .foregroundColor(.blue)
                                            Text(localization.localizedString("EmailSupport"))
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
                            }
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

struct HelpSection: View {
    let title: String
    let items: [HelpItem]
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(themeManager.textColor)
                .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                ForEach(items) { item in
                    HelpItemView(item: item)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct HelpItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

struct HelpItemView: View {
    let item: HelpItem
    @State private var isExpanded = false
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(item.question)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(themeManager.textColor)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            if isExpanded {
                Text(item.answer)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(16)
        .background(themeManager.cardBackground)
        .cornerRadius(12)
    }
}

#Preview {
    HelpView()
        .environmentObject(ThemeManager.shared)
}
