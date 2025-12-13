import SwiftUI
import Charts

struct ProjectAnalyticsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab: AnalyticsTab = .overview
    @State private var isLoading = true
    let project: Project
    
    var body: some View {
        ZStack {
            // Dark background
            Color(red: 0.11, green: 0.13, blue: 0.16)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Project Analytics")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Invisible button for balance
                    Image(systemName: "arrow.left")
                        .font(.title3)
                        .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // Tab Bar
                HStack(spacing: 0) {
                    ForEach(AnalyticsTab.allCases, id: \.self) { tab in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = tab
                            }
                        }) {
                            Text(tab.rawValue)
                                .font(.system(size: 15, weight: selectedTab == tab ? .semibold : .regular))
                                .foregroundColor(selectedTab == tab ? .white : .gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    selectedTab == tab ? Color.blue : Color.clear
                                )
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        switch selectedTab {
                        case .overview:
                            OverviewTabContent(project: project)
                        case .progress:
                            ProgressTabContent(project: project)
                        case .team:
                            TeamTabContent(project: project)
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 100)
                }
            }
            
            // Loading overlay
            if isLoading {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2.5)
                    .frame(width: 200, height: 200)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(red: 0.15, green: 0.17, blue: 0.21))
                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                )
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Simulate analytics data loading
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isLoading = false
            }
        }
    }
}

// MARK: - Analytics Tab Enum
enum AnalyticsTab: String, CaseIterable {
    case overview = "Overview"
    case progress = "Progress"
    case team = "Team"
}

// MARK: - Overview Tab Content
struct OverviewTabContent: View {
    let project: Project
    
    var completionRate: Double {
        guard project.tasksCount > 0 else { return 0 }
        return Double(project.completedTasksCount) / Double(project.tasksCount) * 100
    }
    
    var completedCount: Int {
        project.completedTasksCount
    }
    
    var inProgressCount: Int {
        project.tasks.filter { !$0.isCompleted }.count
    }
    
    var totalTasks: Int {
        project.tasksCount
    }
    
    var maxCount: Int {
        max(completedCount, max(inProgressCount, 1))
    }
    
    func barHeight(for count: Int) -> CGFloat {
        guard maxCount > 0 else { return 20 }
        return CGFloat(count) / CGFloat(maxCount) * 120 + 20
    }
    
    var statusColor: Color {
        switch project.status {
        case .todo: return .gray
        case .inProgress: return .blue
        case .completed: return .green
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Task Completion Rate Card
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Task Completion Rate")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("\(Int(completionRate))%")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("\(completedCount) of \(totalTasks) tasks completed")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                // Bar Chart
                HStack(alignment: .bottom, spacing: 20) {
                    // Completed
                    VStack(spacing: 8) {
                        VStack(spacing: 4) {
                            Text("\(completedCount)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                            
                            Rectangle()
                                .fill(Color.green)
                                .frame(height: barHeight(for: completedCount))
                                .cornerRadius(8)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Text("Completed")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    // In Progress
                    VStack(spacing: 8) {
                        VStack(spacing: 4) {
                            Text("\(inProgressCount)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                            
                            Rectangle()
                                .fill(Color.blue)
                                .frame(height: barHeight(for: inProgressCount))
                                .cornerRadius(8)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Text("In Progress")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    // Total
                    VStack(spacing: 8) {
                        VStack(spacing: 4) {
                            Text("\(totalTasks)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                            
                            Rectangle()
                                .fill(Color.purple)
                                .frame(height: barHeight(for: totalTasks))
                                .cornerRadius(8)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Text("Total")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                .frame(height: 180)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.15, green: 0.17, blue: 0.21))
            )
            
            // Project Status Card
            VStack(alignment: .leading, spacing: 16) {
                Text("Project Status")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Due Date")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        if let dueDate = project.dueDate {
                            Text(dueDate, style: .date)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        } else {
                            Text("Not set")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.2, green: 0.25, blue: 0.35))
                    )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Status")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Text(project.status.rawValue.capitalized)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(statusColor)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.2, green: 0.25, blue: 0.35))
                    )
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.15, green: 0.17, blue: 0.21))
            )
        }
    }
}

// MARK: - Progress Tab Content
struct ProgressTabContent: View {
    let project: Project
    
    var body: some View {
        VStack(spacing: 20) {
            // Progress overview
            VStack(alignment: .leading, spacing: 16) {
                Text("Overall Progress")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Total Tasks")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Text("\(project.tasksCount)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.15, green: 0.17, blue: 0.21))
                    )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Completed")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Text("\(project.completedTasksCount)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.15, green: 0.17, blue: 0.21))
                    )
                }
                
                // Progress bar
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Completion Rate")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text("\(Int(project.progressPercentage * 100))%")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(red: 0.2, green: 0.25, blue: 0.35))
                                .frame(height: 16)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue)
                                .frame(width: geometry.size.width * project.progressPercentage, height: 16)
                        }
                    }
                    .frame(height: 16)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.15, green: 0.17, blue: 0.21))
                )
            }
            
            // Task breakdown
            VStack(alignment: .leading, spacing: 16) {
                Text("Task Breakdown")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                ForEach(project.tasks) { task in
                    HStack(spacing: 12) {
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 20))
                            .foregroundColor(task.isCompleted ? .green : .gray)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(task.title)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                            
                            if let assignee = task.assignee {
                                Text(assignee.name)
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.15, green: 0.17, blue: 0.21))
                    )
                }
            }
        }
    }
}

// MARK: - Team Tab Content
struct TeamTabContent: View {
    let project: Project
    
    var allTeamMembers: [User] {
        var members: [User] = []
        if let leader = project.teamLeader {
            members.append(leader)
        }
        members.append(contentsOf: project.teamMembers)
        return members
    }
    
    func tasksForMember(_ member: User) -> Int {
        project.tasks.filter { task in
            guard let assigneeEmail = task.assignee?.email,
                  let memberEmail = member.email else { return false }
            return assigneeEmail.lowercased() == memberEmail.lowercased()
        }.count
    }
    
    func completedTasksForMember(_ member: User) -> Int {
        project.tasks.filter { task in
            guard let assigneeEmail = task.assignee?.email,
                  let memberEmail = member.email else { return false }
            return assigneeEmail.lowercased() == memberEmail.lowercased() && task.isCompleted
        }.count
    }
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Team Members")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                if allTeamMembers.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        Text("No team members assigned")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    ForEach(allTeamMembers) { member in
                        UserTeamMemberCard(
                            member: member,
                            totalTasks: tasksForMember(member),
                            completedTasks: completedTasksForMember(member),
                            isLeader: project.teamLeader?.id == member.id
                        )
                    }
                }
            }
        }
    }
}

// MARK: - User Team Member Card
struct UserTeamMemberCard: View {
    let member: User
    let totalTasks: Int
    let completedTasks: Int
    let isLeader: Bool
    
    var completionRate: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            Circle()
                .fill(isLeader ? Color.orange.opacity(0.3) : Color.blue.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 22))
                        .foregroundColor(isLeader ? .orange : .blue)
                )
            
            // Member info
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(member.displayName ?? (member.email ?? "Unknown"))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if isLeader {
                        Text("Leader")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.orange)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.orange.opacity(0.2))
                            )
                    }
                }
                
                Text(member.email ?? "")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                
                HStack(spacing: 8) {
                    Text("\(completedTasks)/\(totalTasks) tasks")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    if totalTasks > 0 {
                        Text("•")
                            .foregroundColor(.gray)
                        
                        Text("\(Int(completionRate * 100))%")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.15, green: 0.17, blue: 0.21))
        )
    }
}

// MARK: - Preview
struct ProjectAnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectAnalyticsView(project: Project.sampleProjects[2])
            .preferredColorScheme(.dark)
    }
}
