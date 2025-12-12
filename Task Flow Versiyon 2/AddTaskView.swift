import SwiftUI

struct AddTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var tasks: [ProjectTask]
    let projectId: UUID
    let availableAssignees: [User]
    
    @State private var taskTitle: String = ""
    @State private var taskDescription: String = ""
    @State private var selectedAssignee: User?
    @State private var dueDate: Date = Date()
    @State private var selectedPriority: TaskPriority = .medium
    @State private var showAlert = false
    @State private var alertMessage = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case title, description
    }
    
    var body: some View {
        ZStack {
            // Dark background
            Color(red: 0.11, green: 0.13, blue: 0.16)
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
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Yeni Görev Ekle")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        saveTask()
                    }) {
                        Text("Kaydet")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Görev Başlığı
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Görev Başlığı")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                            
                            TextField("Görev başlığını girin", text: $taskTitle)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(red: 0.15, green: 0.17, blue: 0.21))
                                )
                                .focused($focusedField, equals: .title)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .description
                                }
                        }
                        
                        // Görev Açıklaması
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Görev Açıklaması")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                            
                            TextEditor(text: $taskDescription)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .frame(height: 120)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(red: 0.15, green: 0.17, blue: 0.21))
                                )
                                .scrollContentBackground(.hidden)
                        }
                        
                        // Görevli Seçimi
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Görevli")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                            
                            if let assignee = selectedAssignee {
                                // Seçili görevli
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color.blue.opacity(0.3))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Text(assignee.initials)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.blue)
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(assignee.displayName ?? "Unknown")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        Text(assignee.email ?? "")
                                            .font(.system(size: 13))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        selectedAssignee = nil
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(red: 0.15, green: 0.17, blue: 0.21))
                                )
                            }
                            
                            // Görevli listesi
                            VStack(spacing: 8) {
                                ForEach(availableAssignees.filter { $0.id != selectedAssignee?.id }) { user in
                                    Button(action: {
                                        selectedAssignee = user
                                    }) {
                                        HStack(spacing: 12) {
                                            Circle()
                                                .fill(Color.blue.opacity(0.3))
                                                .frame(width: 40, height: 40)
                                                .overlay(
                                                    Text(user.initials)
                                                        .font(.system(size: 16, weight: .semibold))
                                                        .foregroundColor(.blue)
                                                )
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(user.displayName ?? "Unknown")
                                                    .font(.system(size: 16, weight: .medium))
                                                    .foregroundColor(.white)
                                                
                                                Text(user.email ?? "")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.gray)
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "plus.circle")
                                                .foregroundColor(.blue)
                                        }
                                        .padding(16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(red: 0.2, green: 0.22, blue: 0.26))
                                        )
                                    }
                                }
                            }
                        }
                        
                        // Öncelik Seçimi
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Öncelik")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 12) {
                                ForEach([TaskPriority.low, TaskPriority.medium, TaskPriority.high], id: \.self) { priority in
                                    Button(action: {
                                        selectedPriority = priority
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: selectedPriority == priority ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(selectedPriority == priority ? .blue : .gray)
                                            
                                            Text(priority.rawValue)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(selectedPriority == priority ? .white : .gray)
                                        }
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(selectedPriority == priority ? Color.blue.opacity(0.2) : Color(red: 0.15, green: 0.17, blue: 0.21))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(selectedPriority == priority ? Color.blue : Color.clear, lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                        
                        // Son Teslim Tarihi
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Son Teslim Tarihi")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                            
                            DatePicker(
                                "",
                                selection: $dueDate,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.graphical)
                            .colorScheme(.dark)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(red: 0.15, green: 0.17, blue: 0.21))
                            )
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 100)
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Uyarı"),
                message: Text(alertMessage),
                dismissButton: .default(Text("Tamam"))
            )
        }
    }
    
    private func saveTask() {
        hideKeyboard()
        
        guard !taskTitle.isEmpty else {
            alertMessage = "Lütfen görev başlığını girin."
            showAlert = true
            return
        }
        
        // TaskAssignee oluştur
        let taskAssignee = selectedAssignee != nil ? TaskAssignee(
            name: selectedAssignee?.displayName ?? "Unknown",
            avatarName: "",
            email: selectedAssignee?.email ?? ""
        ) : nil
        
        // Yeni görev oluştur
        let newTask = ProjectTask(
            title: taskTitle,
            description: taskDescription,
            assignee: taskAssignee,
            dueDate: dueDate,
            comments: [],
            projectId: projectId,
            isCompleted: false,
            priority: selectedPriority
        )
        
        // Görevi listeye ekle
        tasks.append(newTask)
        
        // View'i kapat
        presentationMode.wrappedValue.dismiss()
    }
    
    private func hideKeyboard() {
        focusedField = nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Preview
struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView(
            tasks: .constant([]),
            projectId: UUID(),
            availableAssignees: User.sampleUsers
        )
        .preferredColorScheme(.dark)
    }
}
