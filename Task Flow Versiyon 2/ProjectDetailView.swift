import SwiftUI

struct ProjectDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var projectManager: ProjectManager
    @StateObject private var localization = LocalizationManager.shared
    @Binding var project: Project
    @State private var selectedTaskIndex: Int?
    @State private var showTaskDetail = false
    @State private var showAnalytics = false
    @State private var showAddTask = false
    @State private var showAddTeamMember = false
    @State private var showEditProject = false
    @State private var showDeleteConfirmation = false
    @State private var showActionSheet = false
    
    var teamMembers: [User] {
        var members: [User] = []
        
        // Önce proje lideri varsa ekle
        if let leader = project.teamLeader {
            members.append(leader)
        }
        
        // Diğer ekip üyelerini ekle (proje lideri değilse)
        for member in project.teamMembers {
            // Duplicate kontrolü - zaten listede yoksa ekle
            if !members.contains(where: { $0.uid == member.uid }) {
                members.append(member)
            }
        }
        
        return members
    }
    
    var projectLeader: User? {
        project.teamLeader ?? project.teamMembers.first
    }
    
    var priorityColor: Color {
        guard let index = selectedTaskIndex, index < project.tasks.count else { return .blue }
        let task = project.tasks[index]
        switch task.priority {
        case .high:
            return .red
        case .medium:
            return .orange
        case .low:
            return .green
        }
    }
    
    var body: some View {
        ZStack {
            // Background
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
                    
                    Text(localization.localizedString("ProjectDetails"))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        // Analytics button
                        Button(action: {
                            showAnalytics = true
                        }) {
                            Image(systemName: "chart.bar.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                        }
                        
                        // More menu button
                        Button(action: {
                            showActionSheet = true
                        }) {
                            Image(systemName: "ellipsis.circle")
                                .font(.title3)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 16)
                
                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Project Info
                        VStack(alignment: .leading, spacing: 12) {
                            Text(project.title)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(project.description)
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                                .lineSpacing(4)
                            
                            if !project.dueDateString.isEmpty {
                                Text(project.dueDateString)
                                    .font(.system(size: 14))
                                    .foregroundColor(.blue)
                            }
                            
                            // Progress
                            if project.tasks.count > 0 {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(localization.localizedString("Progress"))
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                        
                                        Spacer()
                                        
                                        Text("\(project.tasks.filter { $0.isCompleted }.count)/\(project.tasks.count)")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white)
                                    }
                                    
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(height: 8)
                                            
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.blue)
                                                .frame(width: geometry.size.width * (project.tasks.count > 0 ? Double(project.tasks.filter { $0.isCompleted }.count) / Double(project.tasks.count) : 0), height: 8)
                                        }
                                    }
                                    .frame(height: 8)
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.15, green: 0.17, blue: 0.21))
                        )
                        
                        // Ekip Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text(localization.localizedString("Team"))
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(action: {
                                    showAddTeamMember = true
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "person.badge.plus")
                                        Text(localization.localizedString("AddMember"))
                                    }
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(red: 0.40, green: 0.84, blue: 0.55))
                                }
                            }
                            
                            // Ekip Lideri
                            if let leader = projectLeader {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(localization.localizedString("TeamLeader"))
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                    
                                    TeamMemberRow(member: leader, isLeader: true)
                                }
                            }
                            
                            // Ekip Üyeleri
                            if teamMembers.count > 1 {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(localization.localizedString("TeamMembers"))
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                    
                                    ForEach(teamMembers.dropFirst()) { member in
                                        TeamMemberRow(member: member, isLeader: false)
                                    }
                                }
                            }
                        }
                        
                        // Görevler Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text(localization.localizedString("Tasks"))
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(action: {
                                    showAddTask = true
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            if project.tasks.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "tray")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    
                                    Text(localization.localizedString("NoTasksYet"))
                                        .font(.system(size: 15))
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            } else {
                                ForEach(Array(project.tasks.indices), id: \.self) { index in
                                    TaskRowCard(task: project.tasks[index]) {
                                        toggleTaskCompletion(project.tasks[index])
                                    }
                                    .onTapGesture {
                                        selectedTaskIndex = index
                                        showTaskDetail = true
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showTaskDetail) {
            if let index = selectedTaskIndex, index < project.tasks.count {
                TaskDetailView(task: $project.tasks[index])
            }
        }
        .sheet(isPresented: $showAnalytics) {
            ProjectAnalyticsView(project: project)
        }
        .sheet(isPresented: $showAddTask) {
            AddTaskView(
                tasks: $project.tasks,
                projectId: project.id,
                availableAssignees: teamMembers
            )
        }
        .sheet(isPresented: $showAddTeamMember) {
            AddTeamMemberView(project: project)
        }
        .sheet(isPresented: $showEditProject) {
            CreateProjectView(projectToEdit: project)
        }
        .confirmationDialog("", isPresented: $showActionSheet) {
            Button(localization.localizedString("EditProject")) {
                showEditProject = true
            }
            Button(localization.localizedString("DeleteProject"), role: .destructive) {
                showDeleteConfirmation = true
            }
            Button(localization.localizedString("Cancel"), role: .cancel) {}
        }
        .alert(localization.localizedString("DeleteProject"), isPresented: $showDeleteConfirmation) {
            Button(localization.localizedString("Cancel"), role: .cancel) {}
            Button(localization.localizedString("Delete"), role: .destructive) {
                deleteProject()
            }
        } message: {
            Text(localization.localizedString("DeleteProjectConfirmation"))
        }
    }
    
    private func toggleTaskCompletion(_ task: ProjectTask) {
        if let index = project.tasks.firstIndex(where: { $0.id == task.id }) {
            project.tasks[index].isCompleted.toggle()
        }
    }
    
    private func deleteProject() {
        Task {
            do {
                try await projectManager.deleteProject(project)
                await MainActor.run {
                    presentationMode.wrappedValue.dismiss()
                }
            } catch {
                print("❌ Proje silme hatası: \(error)")
            }
        }
    }
}

// MARK: - Team Member Row
struct TeamMemberRow: View {
    let member: User
    let isLeader: Bool
    
    var avatarColor: Color {
        isLeader ? .orange : .blue
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(avatarColor.opacity(0.3))
                .frame(width: 45, height: 45)
                .overlay(
                    Text(member.initials)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(avatarColor)
                )
            
            // Member info
            VStack(alignment: .leading, spacing: 4) {
                Text(member.displayName ?? "Unknown")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text(member.email ?? "")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.2, green: 0.22, blue: 0.26))
        )
    }
}

// MARK: - Task Row Card
struct TaskRowCard: View {
    let task: ProjectTask
    var onToggleComplete: (() -> Void)?
    
    var priorityColor: Color {
        switch task.priority {
        case .high:
            return .red
        case .medium:
            return .orange
        case .low:
            return .green
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Checkbox
            Button(action: {
                onToggleComplete?()
            }) {
                ZStack {
                    if task.isCompleted {
                        // Tamamlanmış - yeşil dolu daire
                        Circle()
                            .fill(Color.green)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        // Tamamlanmamış - gri çember
                        Circle()
                            .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                            .frame(width: 24, height: 24)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Task info
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(task.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .strikethrough(task.isCompleted)
                        .lineLimit(1)
                    
                    // Priority Badge
                    HStack(spacing: 3) {
                        Circle()
                            .fill(priorityColor)
                            .frame(width: 6, height: 6)
                        
                        Text(task.priority.rawValue)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(priorityColor)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(priorityColor.opacity(0.2))
                    )
                }
                
                HStack(spacing: 8) {
                    if let assignee = task.assignee {
                        HStack(spacing: 4) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 10))
                            Text(assignee.name)
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.gray)
                    }
                    
                    if !task.dueDateString.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 10))
                            Text(task.dueDateString)
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.15, green: 0.17, blue: 0.21))
        )
    }
}

// MARK: - Preview
struct ProjectDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectDetailView(project: .constant(Project.sampleProjects[0]))
            .preferredColorScheme(.dark)
    }
}
