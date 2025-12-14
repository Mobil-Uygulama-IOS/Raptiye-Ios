import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var localization = LocalizationManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    
    let greenAccent = Color(red: 0.40, green: 0.84, blue: 0.55)
    
    @State private var isLoading = true
    @State private var isSaving = false
    @AppStorage("pushNotifications") private var pushNotifications = true {
        didSet { saveSettings() }
    }
    @AppStorage("emailNotifications") private var emailNotifications = false {
        didSet { saveSettings() }
    }
    @AppStorage("taskReminders") private var taskReminders = true {
        didSet { saveSettings() }
    }
    @AppStorage("projectUpdates") private var projectUpdates = true {
        didSet { saveSettings() }
    }
    @AppStorage("teamActivity") private var teamActivity = false {
        didSet { saveSettings() }
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
                                .frame(width: 36, height: 36)
                                .background(themeManager.cardBackground)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        
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
                                .tint(greenAccent)
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
                            
                            // Reminder Settings
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Hatırlatıcı Ayarları")
                                    .font(.headline)
                                    .foregroundColor(themeManager.textColor)
                                    .padding(.horizontal, 20)
                                
                                VStack(spacing: 1) {
                                    ReminderSettingRow(
                                        title: "Proje Bitiş Uyarısı",
                                        description: "Proje bitiş tarihinden kaç gün önce bildirim alsın",
                                        settingKey: "projectDeadlineReminderDays",
                                        defaultValue: 3
                                    )
                                    
                                    ReminderSettingRow(
                                        title: "Görev Bitiş Uyarısı",
                                        description: "Görev bitiş tarihinden kaç gün önce bildirim alsın",
                                        settingKey: "taskDeadlineReminderDays",
                                        defaultValue: 1
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
            loadSettings()
        }
    }
    
    // MARK: - Helper Functions
    
    private func loadSettings() {
        Task {
            await notificationManager.loadNotificationSettings { settings in
                if let settings = settings {
                    pushNotifications = settings["pushNotifications"] as? Bool ?? true
                    emailNotifications = settings["emailNotifications"] as? Bool ?? false
                    taskReminders = settings["taskReminders"] as? Bool ?? true
                    projectUpdates = settings["projectUpdates"] as? Bool ?? true
                    teamActivity = settings["teamActivity"] as? Bool ?? false
                }
            }
        }
    }
    
    private func saveSettings() {
        guard !isSaving else { return }
        isSaving = true
        
        Task {
            let settings: [String: Any] = [
                "pushNotifications": pushNotifications,
                "emailNotifications": emailNotifications,
                "taskReminders": taskReminders,
                "projectUpdates": projectUpdates,
                "teamActivity": teamActivity
            ]
            
            await notificationManager.saveNotificationSettings(settings)
            
            // E-posta bildirimleri aktifse, kullanıcıya bilgi ver
            if emailNotifications {
                await notificationManager.requestEmailNotificationPermission()
            }
            
            DispatchQueue.main.async {
                isSaving = false
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
                .tint(Color(red: 0.40, green: 0.84, blue: 0.55))
        }
        .padding(16)
    }
}

struct ReminderSettingRow: View {
    let title: String
    let description: String
    let settingKey: String
    let defaultValue: Int
    
    @StateObject private var themeManager = ThemeManager.shared
    @AppStorage("projectDeadlineReminderDays") private var projectDays = 3
    @AppStorage("taskDeadlineReminderDays") private var taskDays = 1
    
    var binding: Binding<Int> {
        Binding(
            get: { settingKey == "projectDeadlineReminderDays" ? projectDays : taskDays },
            set: { newValue in
                if settingKey == "projectDeadlineReminderDays" {
                    projectDays = newValue
                } else {
                    taskDays = newValue
                }
            }
        )
    }
    
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
            
            Stepper("\(binding.wrappedValue) gün", value: binding, in: 1...30)
                .foregroundColor(themeManager.textColor)
        }
        .padding(16)
    }
}

#Preview {
    NotificationSettingsView()
        .environmentObject(ThemeManager.shared)
}
