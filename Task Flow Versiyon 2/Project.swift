import Foundation

// MARK: - Project Status Enum
enum ProjectStatus: String, Codable {
    case todo = "Yapılacaklar"
    case inProgress = "Devam Ediyor"
    case completed = "Tamamlandı"
}

// MARK: - Proje Data Modeli
struct Project: Identifiable, Codable {
    var id: UUID
    var title: String
    var description: String
    var iconName: String
    var iconColor: String
    var createdDate: Date
    var status: ProjectStatus
    var dueDate: Date?
    var tasks: [ProjectTask]
    var teamLeader: User?
    var teamMembers: [User]
    
    // Firebase için gerekli alanlar
    var ownerId: String = ""
    var teamMemberIds: [String] = []
    
    init(id: UUID = UUID(), title: String, description: String, iconName: String = "folder.fill", iconColor: String = "blue", status: ProjectStatus = .todo, dueDate: Date? = nil, tasks: [ProjectTask] = [], teamLeader: User? = nil, teamMembers: [User] = [], createdDate: Date = Date(), ownerId: String = "", teamMemberIds: [String] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
        self.iconColor = iconColor
        self.createdDate = createdDate
        self.status = status
        self.dueDate = dueDate
        self.tasks = tasks
        self.teamLeader = teamLeader
        self.teamMembers = teamMembers
        self.ownerId = ownerId
        self.teamMemberIds = teamMemberIds
    }
    
    var tasksCount: Int {
        tasks.count
    }
    
    var completedTasksCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    var progressPercentage: Double {
        guard tasksCount > 0 else { return 0.0 }
        return Double(completedTasksCount) / Double(tasksCount)
    }
    
    var isCompleted: Bool {
        status == .completed
    }
    
    var dueDateString: String {
        guard let dueDate = dueDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        formatter.locale = Locale(identifier: "tr_TR")
        return "Son teslim: \(formatter.string(from: dueDate))"
    }
}

// MARK: - Sample Data
extension Project {
    static var sampleProjects: [Project] {
        let assignees = ProjectTask.sampleAssignees
        let users = User.sampleUsers
        
        return [
            // Yapılacaklar
            Project(
                title: "Proje 1: Web Sitesi Tasarımı",
                description: "Web sitesi tasarımının tamamlanması",
                iconName: "list.bullet",
                iconColor: "blue",
                status: .todo,
                dueDate: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 20)),
                tasks: [
                    ProjectTask(
                        title: "UI/UX Design for Mobile App",
                        description: "Create a modern and user-friendly interface for the new student project tracking application.",
                        assignee: assignees[0],
                        dueDate: Calendar.current.date(from: DateComponents(year: 2024, month: 7, day: 20)),
                        comments: [
                            TaskComment(
                                author: assignees[0],
                                content: "Initial project scope and objectives defined.",
                                createdDate: Calendar.current.date(from: DateComponents(year: 2024, month: 7, day: 10)) ?? Date()
                            )
                        ]
                    )
                ],
                teamLeader: users[0],
                teamMembers: [users[1], users[2]]
            ),
            Project(
                title: "Proje 4: Blog Platformu",
                description: "Blog platformu geliştirmesi",
                iconName: "list.bullet",
                iconColor: "blue",
                status: .todo,
                dueDate: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 5)),
                tasks: [],
                teamLeader: users[1],
                teamMembers: [users[0], users[3]]
            ),
            
            // Devam Ediyor
            Project(
                title: "Proje 2: Mobil Uygulama Geliştirme",
                description: "Mobil uygulama geliştirme projesi",
                iconName: "list.bullet",
                iconColor: "blue",
                status: .inProgress,
                dueDate: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 25)),
                tasks: [
                    ProjectTask(
                        title: "Backend API Development",
                        description: "Develop REST API for mobile application",
                        assignee: assignees[1],
                        dueDate: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 15)),
                        isCompleted: true
                    ),
                    ProjectTask(
                        title: "Database Design",
                        description: "Design and implement database schema",
                        assignee: assignees[1],
                        dueDate: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 20))
                    )
                ],
                teamLeader: users[2],
                teamMembers: [users[0], users[1], users[3]]
            ),
            
            // Tamamlandı
            Project(
                title: "Proje 3: Pazarlama Kampanyası",
                description: "Pazarlama kampanyası planlaması",
                iconName: "list.bullet",
                iconColor: "blue",
                status: .completed,
                dueDate: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 30)),
                tasks: [
                    ProjectTask(
                        title: "Market Research",
                        description: "Complete market research analysis",
                        assignee: assignees[2],
                        dueDate: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 10)),
                        isCompleted: true
                    )
                ],
                teamLeader: users[3],
                teamMembers: [users[0], users[2]]
            )
        ]
    }
}