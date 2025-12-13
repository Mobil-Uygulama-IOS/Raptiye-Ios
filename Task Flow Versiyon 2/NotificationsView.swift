import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var localization = LocalizationManager.shared
    
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Bildirimler")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(themeManager.textColor)
                
                Spacer()
                
                if notificationManager.unreadCount > 0 {
                    Button(action: {
                        Task {
                            await notificationManager.markAllAsRead()
                        }
                    }) {
                        Text("Tümünü Okundu İşaretle")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Tab Selector
            HStack(spacing: 0) {
                TabButton(title: "Davetler", count: notificationManager.pendingInvitations.count, isSelected: selectedTab == 0) {
                    withAnimation { selectedTab = 0 }
                }
                
                TabButton(title: "Bildirimler", count: notificationManager.unreadCount, isSelected: selectedTab == 1) {
                    withAnimation { selectedTab = 1 }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            
            // Content
            if selectedTab == 0 {
                invitationsView
            } else {
                notificationsListView
            }
        }
        .background(themeManager.backgroundColor.ignoresSafeArea())
    }
    
    // MARK: - Invitations View
    
    private var invitationsView: some View {
        Group {
            if notificationManager.pendingInvitations.isEmpty {
                emptyStateView(
                    icon: "envelope.badge",
                    title: "Davet Yok",
                    message: "Bekleyen proje davetiniz bulunmuyor"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(notificationManager.pendingInvitations) { invitation in
                            InvitationCard(invitation: invitation) { accept in
                                Task {
                                    try? await notificationManager.respondToInvitation(invitation, accept: accept)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
    }
    
    // MARK: - Notifications List View
    
    private var notificationsListView: some View {
        Group {
            if notificationManager.notifications.isEmpty {
                emptyStateView(
                    icon: "bell.slash",
                    title: "Bildirim Yok",
                    message: "Henüz bildiriminiz bulunmuyor"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(notificationManager.notifications) { notification in
                            NotificationCard(notification: notification)
                                .onTapGesture {
                                    Task {
                                        await notificationManager.markAsRead(notification)
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
    }
    
    // MARK: - Empty State View
    
    private func emptyStateView(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(themeManager.secondaryTextColor.opacity(0.5))
            
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(themeManager.textColor)
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(themeManager.secondaryTextColor)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(40)
    }
}

// MARK: - Tab Button

struct TabButton: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? themeManager.textColor : themeManager.secondaryTextColor)
                    
                    if count > 0 {
                        Text("\(count)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.red)
                            )
                    }
                }
                
                Rectangle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(height: 3)
                    .cornerRadius(1.5)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Invitation Card

struct InvitationCard: View {
    let invitation: ProjectInvitation
    let onRespond: (Bool) -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Proje Daveti")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.textColor)
                    
                    Text(invitation.timeAgo)
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.secondaryTextColor)
                }
                
                Spacer()
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text("\(invitation.senderName) sizi projeye davet etti:")
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.secondaryTextColor)
                
                Text(invitation.projectTitle)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.textColor)
            }
            
            // Actions
            HStack(spacing: 12) {
                Button(action: {
                    onRespond(false)
                }) {
                    Text("Reddet")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red, lineWidth: 1)
                        )
                }
                
                Button(action: {
                    onRespond(true)
                }) {
                    Text("Kabul Et")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue)
                        )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.cardBackground)
        )
    }
}

// MARK: - Notification Card

struct NotificationCard: View {
    let notification: AppNotification
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var iconColor: Color {
        switch notification.iconColor {
        case "blue": return .blue
        case "green": return .green
        case "red": return .red
        case "orange": return .orange
        default: return .blue
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: notification.iconName)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(themeManager.textColor)
                    
                    Spacer()
                    
                    if !notification.isRead {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                    }
                }
                
                Text(notification.message)
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.secondaryTextColor)
                    .lineLimit(2)
                
                Text(notification.timeAgo)
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.secondaryTextColor.opacity(0.7))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(notification.isRead ? themeManager.cardBackground : themeManager.cardBackground.opacity(0.8))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(notification.isRead ? Color.clear : Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Time Ago Extension

extension ProjectInvitation {
    var timeAgo: String {
        let now = Date()
        let diff = now.timeIntervalSince(createdAt)
        
        if diff < 60 {
            return "Az önce"
        } else if diff < 3600 {
            let minutes = Int(diff / 60)
            return "\(minutes) dk önce"
        } else if diff < 86400 {
            let hours = Int(diff / 3600)
            return "\(hours) saat önce"
        } else if diff < 604800 {
            let days = Int(diff / 86400)
            return "\(days) gün önce"
        } else {
            return formattedDate
        }
    }
}

#Preview {
    NotificationsView()
        .environmentObject(ThemeManager())
}
