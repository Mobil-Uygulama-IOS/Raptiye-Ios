import Foundation
import FirebaseFirestore

// MARK: - Invitation Status
enum InvitationStatus: String, Codable {
    case pending = "pending"
    case accepted = "accepted"
    case rejected = "rejected"
}

// MARK: - Project Invitation Model
struct ProjectInvitation: Identifiable, Codable {
    @DocumentID var documentId: String?
    var id: String
    var projectId: String
    var projectTitle: String
    var senderId: String
    var senderName: String
    var senderEmail: String
    var receiverId: String
    var receiverEmail: String
    var status: InvitationStatus
    var createdAt: Date
    var respondedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case documentId
        case id
        case projectId
        case projectTitle
        case senderId
        case senderName
        case senderEmail
        case receiverId
        case receiverEmail
        case status
        case createdAt
        case respondedAt
    }
    
    init(
        id: String = UUID().uuidString,
        projectId: String,
        projectTitle: String,
        senderId: String,
        senderName: String,
        senderEmail: String,
        receiverId: String,
        receiverEmail: String,
        status: InvitationStatus = .pending,
        createdAt: Date = Date(),
        respondedAt: Date? = nil
    ) {
        self.id = id
        self.projectId = projectId
        self.projectTitle = projectTitle
        self.senderId = senderId
        self.senderName = senderName
        self.senderEmail = senderEmail
        self.receiverId = receiverId
        self.receiverEmail = receiverEmail
        self.status = status
        self.createdAt = createdAt
        self.respondedAt = respondedAt
    }
    
    var statusText: String {
        switch status {
        case .pending:
            return "Kabul Bekliyor"
        case .accepted:
            return "Kabul Edildi"
        case .rejected:
            return "Reddedildi"
        }
    }
    
    var statusColor: String {
        switch status {
        case .pending:
            return "orange"
        case .accepted:
            return "green"
        case .rejected:
            return "red"
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, HH:mm"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: createdAt)
    }
}

// MARK: - Notification Type
enum NotificationType: String, Codable {
    case projectInvitation = "project_invitation"
    case invitationAccepted = "invitation_accepted"
    case invitationRejected = "invitation_rejected"
    case taskAssigned = "task_assigned"
    case taskCompleted = "task_completed"
    case taskDeadline = "task_deadline"
    case teamActivity = "team_activity"
}

// MARK: - App Notification Model
struct AppNotification: Identifiable, Codable {
    var id: String
    var userId: String
    var type: NotificationType
    var title: String
    var message: String
    var relatedId: String? // projectId, taskId, invitationId etc.
    var isRead: Bool
    var createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        type: NotificationType,
        title: String,
        message: String,
        relatedId: String? = nil,
        isRead: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.title = title
        self.message = message
        self.relatedId = relatedId
        self.isRead = isRead
        self.createdAt = createdAt
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, HH:mm"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: createdAt)
    }
    
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
    
    var iconName: String {
        switch type {
        case .projectInvitation:
            return "person.badge.plus"
        case .invitationAccepted:
            return "checkmark.circle.fill"
        case .invitationRejected:
            return "xmark.circle.fill"
        case .taskAssigned:
            return "doc.badge.plus"
        case .taskCompleted:
            return "checkmark.seal.fill"
        case .taskDeadline:
            return "clock.badge.exclamationmark"
        case .teamActivity:
            return "person.2.fill"
        }
    }
    
    var iconColor: String {
        switch type {
        case .projectInvitation:
            return "blue"
        case .invitationAccepted:
            return "green"
        case .invitationRejected:
            return "red"
        case .taskAssigned:
            return "orange"
        case .taskCompleted:
            return "green"
        case .taskDeadline:
            return "red"
        case .teamActivity:
            return "purple"
        }
    }
}

// MARK: - Pending Member (for UI display)
struct PendingMember: Identifiable, Codable {
    var id: String
    var odisplayName: String
    var email: String
    var status: InvitationStatus
    var invitationId: String
    
    var displayName: String {
        return odisplayName.isEmpty ? email : odisplayName
    }
}
