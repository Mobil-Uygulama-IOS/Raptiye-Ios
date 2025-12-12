import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var localization = LocalizationManager.shared
    
    @State private var isLoading = true
    @State private var pushNotifications = true
    @State private var emailNotifications = false
    @State private var taskReminders = true
    @State private var projectUpdates = true
    @State private var teamActivity = false
    
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
                        
                        Spacer()
                        
                        Text(localization.localizedString("Notifications"))
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
                            // Push Notifications
                            VStack(alignment: .leading, spacing: 16) {
                                Text(localization.localizedString("PushNotifications"))
                                    .font(.headline)
                                    .foregroundColor(themeManager.textColor)
                                    .padding(.horizontal, 20)
                                
                                VStack(spacing: 1) {
                                    NotificationToggleRow(
                                        title: localization.localizedString("EnablePushNotifications"),
                                        description: localization.localizedString("ReceiveNotificationsDevice"),
                                        isOn: $pushNotifications
                                    )
                                    
                                    NotificationToggleRow(
                                        title: localization.localizedString("TaskReminders"),
                                        description: localization.localizedString("GetRemindedUpcomingTasks"),
                                        isOn: $taskReminders
                                    )
                                    
                                    NotificationToggleRow(
                                        title: localization.localizedString("ProjectUpdates"),
                                        description: localization.localizedString("StayUpdatedProjectChanges"),
                                        isOn: $projectUpdates
                                    )
                                    
                                    NotificationToggleRow(
                                        title: localization.localizedString("TeamActivity"),
                                        description: localization.localizedString("GetNotifiedTeamActions"),
                                        isOn: $teamActivity
                                    )
                                }
                                .background(themeManager.cardBackground)
                                .cornerRadius(12)
                                .padding(.horizontal, 20)
                            }
                            
                            // Email Notifications
                            VStack(alignment: .leading, spacing: 16) {
                                Text(localization.localizedString("EmailNotifications"))
                                    .font(.headline)
                                    .foregroundColor(themeManager.textColor)
                                    .padding(.horizontal, 20)
                                
                                VStack(spacing: 1) {
                                    NotificationToggleRow(
                                        title: localization.localizedString("EmailNotifications"),
                                        description: localization.localizedString("ReceiveUpdatesEmail"),
                                        isOn: $emailNotifications
                                    )
                                }
                                .background(themeManager.cardBackground)
                                .cornerRadius(12)
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

struct NotificationToggleRow: View {
    let title: String
    let description: String
    @Binding var isOn: Bool
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var localization = LocalizationManager.shared
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .foregroundColor(themeManager.textColor)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.blue)
        }
        .padding(16)
    }
}

#Preview {
    NotificationSettingsView()
        .environmentObject(ThemeManager.shared)
}
