import SwiftUI

struct TaskDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var task: ProjectTask
    @State private var newComment: String = ""
    @FocusState private var isCommentFieldFocused: Bool
    
    init(task: Binding<ProjectTask>) {
        _task = task
        print("TaskDetailView init with task: \(task.wrappedValue.title)")
    }
    
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
                    
                    Text("Görev Detayları")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        task.isCompleted.toggle()
                    }) {
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundColor(task.isCompleted ? .green : .gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(red: 0.11, green: 0.13, blue: 0.16))
                
                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Task Info Card
                        VStack(alignment: .leading, spacing: 16) {
                            // Title and Priority
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(task.title)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    if !task.description.isEmpty {
                                        Text(task.description)
                                            .font(.system(size: 15))
                                            .foregroundColor(.gray)
                                            .lineSpacing(4)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                                
                                Spacer()
                                
                                // Priority Badge
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(priorityColor)
                                        .frame(width: 8, height: 8)
                                    
                                    Text(task.priority.rawValue)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(priorityColor)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(priorityColor.opacity(0.2))
                                )
                            }
                            
                            Divider()
                                .background(Color.gray.opacity(0.3))
                            
                            // Assignee
                            if let assignee = task.assignee {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Görevli")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                    
                                    HStack(spacing: 12) {
                                        Circle()
                                            .fill(Color.blue.opacity(0.3))
                                            .frame(width: 45, height: 45)
                                            .overlay(
                                                Text(String(assignee.name.prefix(1)).uppercased())
                                                    .font(.system(size: 18, weight: .semibold))
                                                    .foregroundColor(.blue)
                                            )
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(assignee.name)
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.white)
                                            
                                            Text(assignee.email)
                                                .font(.system(size: 13))
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                    }
                                }
                                
                                Divider()
                                    .background(Color.gray.opacity(0.3))
                            }
                            
                            // Due Date
                            if task.dueDate != nil {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Son Teslim Tarihi")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                    
                                    HStack(spacing: 12) {
                                        Image(systemName: "calendar")
                                            .font(.system(size: 18))
                                            .foregroundColor(.blue)
                                        
                                        Text(task.formattedDueDate)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                    }
                                }
                                
                                Divider()
                                    .background(Color.gray.opacity(0.3))
                            }
                            
                            // Creation Date
                            HStack(spacing: 12) {
                                Image(systemName: "clock")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                
                                Text("Oluşturulma: \(task.formattedCreatedDate)")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 0.15, green: 0.17, blue: 0.21))
                        )
                        
                        // Comments Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Yorumlar")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("\(task.comments.count)")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color.gray.opacity(0.3))
                                    )
                            }
                            
                            // Comments list
                            if task.comments.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "bubble.left.and.bubble.right")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    
                                    Text("Henüz yorum yapılmamış")
                                        .font(.system(size: 15))
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 30)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(red: 0.15, green: 0.17, blue: 0.21))
                                )
                            } else {
                                ForEach(task.comments) { comment in
                                    CommentCard(comment: comment)
                                }
                            }
                            
                            // Add comment section
                            HStack(alignment: .center, spacing: 12) {
                                // Avatar
                                Circle()
                                    .fill(Color.blue.opacity(0.3))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Text("S")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.blue)
                                    )
                                
                                // Text field
                                TextField("Yorum ekle...", text: $newComment)
                                    .font(.system(size: 15))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color(red: 0.15, green: 0.17, blue: 0.21))
                                    )
                                    .focused($isCommentFieldFocused)
                                    .submitLabel(.send)
                                    .onSubmit {
                                        addComment()
                                    }
                                
                                // Send button
                                if !newComment.isEmpty {
                                    Button(action: {
                                        addComment()
                                    }) {
                                        Image(systemName: "arrow.up.circle.fill")
                                            .font(.system(size: 28))
                                            .foregroundColor(.blue)
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
        .onAppear {
            print("✅ TaskDetailView appeared with task: \(task.title)")
        }
    }
    
    private func addComment() {
        guard !newComment.isEmpty else { return }
        
        let comment = TaskComment(
            author: task.assignee ?? ProjectTask.sampleAssignees[0],
            content: newComment,
            createdDate: Date()
        )
        
        task.comments.append(comment)
        newComment = ""
        isCommentFieldFocused = false
    }
}

// MARK: - Comment Card
struct CommentCard: View {
    let comment: TaskComment
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar
            Circle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(comment.author.name.prefix(1)).uppercased())
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)
                )
            
            // Comment content
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(comment.author.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(comment.formattedDate)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Text(comment.content)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.15, green: 0.17, blue: 0.21))
        )
    }
}

// MARK: - Preview
struct TaskDetailView_Previews: PreviewProvider {
    @State static var sampleTask = ProjectTask.sampleTask
    
    static var previews: some View {
        TaskDetailView(task: $sampleTask)
            .preferredColorScheme(.dark)
    }
}
