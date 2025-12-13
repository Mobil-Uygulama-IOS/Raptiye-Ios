import SwiftUI

// Temporary task struct for creating tasks
struct TempTask: Identifiable {
    let id = UUID()
    var title: String
    var priority: TaskPriority
    var dueDate: Date
}

struct CreateProjectView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var projectManager: ProjectManager
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var localization = LocalizationManager.shared
    var onProjectCreated: ((Project) -> Void)?
    var projectToEdit: Project?
    
    @State private var projectTitle: String = ""
    @State private var projectDescription: String = ""
    @State private var dueDate: Date = Date()
    @State private var taskTitle: String = ""
    @State private var taskPriority: TaskPriority = .medium
    @State private var taskDueDate: Date = Date()
    @State private var tempTasks: [TempTask] = []
    @State private var showDatePicker = false
    @State private var showTaskDatePicker = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @FocusState private var focusedField: Field?
    
    private var isEditMode: Bool {
        projectToEdit != nil
    }
    
    enum Field {
        case title, description, task
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
                    
                    Text(isEditMode ? localization.localizedString("EditProject") : localization.localizedString("CreateNewProject"))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(themeManager.textColor)
                    
                    Spacer()
                    
                    // Invisible button for balance
                    Image(systemName: "xmark")
                        .font(.title3)
                        .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 16)
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Proje Başlığı
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Proje Başlığı")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(themeManager.secondaryTextColor)
                            
                            TextField("Örn: Web Sitesi Tasarımı", text: $projectTitle)
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.textColor)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(themeManager.cardBackground)
                                )
                                .focused($focusedField, equals: .title)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .description
                                }
                        }
                        
                        // Proje Açıklaması
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Proje Açıklaması")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(themeManager.secondaryTextColor)
                            
                            TextEditor(text: $projectDescription)
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.textColor)
                                .frame(minHeight: 100)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(themeManager.cardBackground)
                                )
                                .scrollContentBackground(.hidden)
                        }
                        
                        // Teslim Tarihi
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Teslim Tarihi")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(themeManager.secondaryTextColor)
                            
                            Button(action: {
                                hideKeyboard()
                                withAnimation {
                                    showDatePicker.toggle()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.blue)
                                    
                                    Text(formattedDate(dueDate))
                                        .font(.system(size: 16))
                                        .foregroundColor(themeManager.textColor)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(themeManager.secondaryTextColor)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(themeManager.cardBackground)
                                )
                            }
                            .buttonStyle(.plain)
                            
                            if showDatePicker {
                                DatePicker("", selection: $dueDate, in: Date()..., displayedComponents: .date)
                                    .datePickerStyle(.graphical)
                                    .colorScheme(themeManager.isDarkMode ? .dark : .light)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(themeManager.cardBackground)
                                    )
                            }
                        }
                        
                        // Görevler (Opsiyonel)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Görevler")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(themeManager.secondaryTextColor)
                            
                            // Task list
                            if !tempTasks.isEmpty {
                                VStack(spacing: 8) {
                                    ForEach(tempTasks) { task in
                                        HStack(spacing: 12) {
                                            // Priority indicator
                                            Circle()
                                                .fill(priorityColor(task.priority))
                                                .frame(width: 10, height: 10)
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(task.title)
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(themeManager.textColor)
                                                
                                                HStack(spacing: 8) {
                                                    // Priority badge
                                                    Text(task.priority.rawValue)
                                                        .font(.system(size: 11))
                                                        .foregroundColor(priorityColor(task.priority))
                                                        .padding(.horizontal, 6)
                                                        .padding(.vertical, 2)
                                                        .background(
                                                            Capsule()
                                                                .fill(priorityColor(task.priority).opacity(0.2))
                                                        )
                                                    
                                                    // Due date
                                                    HStack(spacing: 2) {
                                                        Image(systemName: "calendar")
                                                            .font(.system(size: 10))
                                                        Text(formatTaskDate(task.dueDate))
                                                            .font(.system(size: 11))
                                                    }
                                                    .foregroundColor(themeManager.secondaryTextColor)
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                if let index = tempTasks.firstIndex(where: { $0.id == task.id }) {
                                                    tempTasks.remove(at: index)
                                                }
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(themeManager.secondaryTextColor)
                                            }
                                        }
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(themeManager.searchBackground)
                                        )
                                    }
                                }
                            }
                            
                            // Add task form
                            VStack(spacing: 12) {
                                // Task title
                                TextField("Görev başlığı...", text: $taskTitle)
                                    .font(.system(size: 16))
                                    .foregroundColor(themeManager.textColor)
                                    .focused($focusedField, equals: .task)
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(themeManager.searchBackground)
                                    )
                                
                                // Priority and Date row
                                HStack(spacing: 12) {
                                    // Priority picker
                                    Menu {
                                        Button(action: { taskPriority = .low }) {
                                            Label("Düşük", systemImage: taskPriority == .low ? "checkmark" : "")
                                        }
                                        Button(action: { taskPriority = .medium }) {
                                            Label("Orta", systemImage: taskPriority == .medium ? "checkmark" : "")
                                        }
                                        Button(action: { taskPriority = .high }) {
                                            Label("Yüksek", systemImage: taskPriority == .high ? "checkmark" : "")
                                        }
                                    } label: {
                                        HStack(spacing: 6) {
                                            Circle()
                                                .fill(priorityColor(taskPriority))
                                                .frame(width: 8, height: 8)
                                            Text(taskPriority.rawValue)
                                                .font(.system(size: 14))
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 10))
                                        }
                                        .foregroundColor(themeManager.textColor)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(themeManager.searchBackground)
                                        )
                                    }
                                    
                                    // Date picker button
                                    Button(action: {
                                        hideKeyboard()
                                        withAnimation {
                                            showTaskDatePicker.toggle()
                                        }
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "calendar")
                                                .font(.system(size: 14))
                                            Text(formatTaskDate(taskDueDate))
                                                .font(.system(size: 14))
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 10))
                                        }
                                        .foregroundColor(themeManager.textColor)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(themeManager.searchBackground)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Spacer()
                                    
                                    // Add button
                                    Button(action: {
                                        addTask()
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 28))
                                            .foregroundColor(taskTitle.isEmpty ? .gray : .blue)
                                    }
                                    .disabled(taskTitle.isEmpty)
                                }
                                
                                // Task date picker
                                if showTaskDatePicker {
                                    DatePicker("", selection: $taskDueDate, in: Date()..., displayedComponents: .date)
                                        .datePickerStyle(.graphical)
                                        .colorScheme(themeManager.isDarkMode ? .dark : .light)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(themeManager.cardBackground)
                                        )
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(themeManager.cardBackground)
                            )
                        }
                        
                        // Create Button
                        Button(action: {
                            createProject()
                        }) {
                            Text(isEditMode ? localization.localizedString("SaveChanges") : localization.localizedString("SaveAndCreate"))
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.blue)
                                )
                        }
                        .padding(.top, 20)
                    }
                    .padding(20)
                    .padding(.bottom, 40)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .navigationBarHidden(true)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Uyarı"),
                message: Text(alertMessage),
                dismissButton: .default(Text("Tamam"))
            )
        }
        .onAppear {
            if let project = projectToEdit {
                projectTitle = project.title
                projectDescription = project.description
                dueDate = project.dueDate ?? Date()
                tempTasks = project.tasks.map { task in
                    TempTask(title: task.title, priority: task.priority, dueDate: task.dueDate ?? Date())
                }
            }
        }
    }
    
    // MARK: - Functions
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
    
    private func formatTaskDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: date)
    }
    
    private func priorityColor(_ priority: TaskPriority) -> Color {
        switch priority {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
    
    private func addTask() {
        guard !taskTitle.isEmpty else { return }
        let newTask = TempTask(title: taskTitle, priority: taskPriority, dueDate: taskDueDate)
        tempTasks.append(newTask)
        print("➕ Görev eklendi: \(taskTitle), Toplam: \(tempTasks.count)")
        taskTitle = ""
        taskPriority = .medium
        taskDueDate = Date()
        showTaskDatePicker = false
        hideKeyboard()
    }
    
    private func createProject() {
        hideKeyboard()
        // Validation
        guard !projectTitle.isEmpty else {
            alertMessage = "Lütfen proje başlığını girin."
            showAlert = true
            return
        }
        
        guard !projectDescription.isEmpty else {
            alertMessage = "Lütfen proje açıklamasını girin."
            showAlert = true
            return
        }
        
        if let existingProject = projectToEdit {
            // Edit mode - update existing project
            let projectTasks = tempTasks.map { task in
                ProjectTask(
                    title: task.title,
                    description: "",
                    assignee: nil,
                    dueDate: task.dueDate,
                    isCompleted: false,
                    priority: task.priority
                )
            }
            
            var updatedProject = existingProject
            updatedProject.title = projectTitle
            updatedProject.description = projectDescription
            updatedProject.dueDate = dueDate
            // Only update tasks if they were modified in this view
            if tempTasks.count > 0 {
                updatedProject.tasks = projectTasks
            }
            
            // Update in Firestore
            Task {
                do {
                    try await projectManager.updateProject(updatedProject)
                    
                    // Close view
                    await MainActor.run {
                        presentationMode.wrappedValue.dismiss()
                    }
                } catch {
                    alertMessage = "Proje güncellenemedi: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        } else {
            // Create mode - create new project
            let projectTasks = tempTasks.map { task in
                ProjectTask(
                    title: task.title,
                    description: "",
                    assignee: nil,
                    dueDate: task.dueDate,
                    isCompleted: false,
                    priority: task.priority
                )
            }
            
            print("🆕 Oluşturulan görev sayısı: \(projectTasks.count)")
            for task in projectTasks {
                print("   - \(task.title)")
            }
            
            let newProject = Project(
                title: projectTitle,
                description: projectDescription,
                iconName: "list.bullet",
                iconColor: "blue",
                status: .todo,
                dueDate: dueDate,
                tasks: projectTasks,
                teamLeader: nil,
                teamMembers: []
            )
            
            // Save to Firestore
            Task {
                do {
                    try await projectManager.createProject(newProject)
                    
                    // Notify parent view about new project
                    onProjectCreated?(newProject)
                    
                    // Close view
                    await MainActor.run {
                        presentationMode.wrappedValue.dismiss()
                    }
                } catch {
                    alertMessage = "Proje oluşturulamadı: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
    
    private func hideKeyboard() {
        focusedField = nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Preview
struct CreateProjectView_Previews: PreviewProvider {
    static var previews: some View {
        CreateProjectView()
            .environmentObject(ProjectManager())
            .preferredColorScheme(.dark)
    }
}
