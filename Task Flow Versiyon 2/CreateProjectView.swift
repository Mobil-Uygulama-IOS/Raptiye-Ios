import SwiftUI

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
    @State private var tasks: [String] = []
    @State private var showDatePicker = false
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
                .onTapGesture {
                    hideKeyboard()
                }
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(themeManager.textColor)
                    }
                    
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
                                showDatePicker.toggle()
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
                            
                            if showDatePicker {
                                DatePicker("", selection: $dueDate, displayedComponents: .date)
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
                            if !tasks.isEmpty {
                                VStack(spacing: 8) {
                                    ForEach(Array(tasks.enumerated()), id: \.offset) { index, task in
                                        HStack(spacing: 12) {
                                            Image(systemName: "circle")
                                                .font(.system(size: 18))
                                                .foregroundColor(.gray)
                                            
                                            Text(task)
                                                .font(.system(size: 14))
                                                .foregroundColor(themeManager.textColor)
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                tasks.remove(at: index)
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
                            
                            // Add task
                            HStack(spacing: 12) {
                                TextField("Yeni görev ekle...", text: $taskTitle)
                                    .font(.system(size: 16))
                                    .foregroundColor(themeManager.textColor)
                                    .focused($focusedField, equals: .task)
                                    .submitLabel(.done)
                                    .onSubmit {
                                        addTask()
                                    }
                                
                                if !taskTitle.isEmpty {
                                    Button(action: {
                                        addTask()
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.blue)
                                    }
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
                tasks = project.tasks.map { $0.title }
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
    
    private func addTask() {
        guard !taskTitle.isEmpty else { return }
        tasks.append(taskTitle)
        taskTitle = ""
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
            let projectTasks = tasks.map { taskTitle in
                ProjectTask(
                    title: taskTitle,
                    description: "",
                    assignee: nil,
                    dueDate: dueDate,
                    isCompleted: false
                )
            }
            
            var updatedProject = existingProject
            updatedProject.title = projectTitle
            updatedProject.description = projectDescription
            updatedProject.dueDate = dueDate
            // Only update tasks if they were modified in this view
            if tasks.count > 0 {
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
            let projectTasks = tasks.map { taskTitle in
                ProjectTask(
                    title: taskTitle,
                    description: "",
                    assignee: nil,
                    dueDate: dueDate,
                    isCompleted: false
                )
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
