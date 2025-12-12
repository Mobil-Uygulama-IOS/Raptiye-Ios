//
//  ProjectBoardView.swift
//  Raptiye
//
//  Created on 16 Ekim 2025.
//

import SwiftUI

/// Kanban Panosu Ekranı - Gerçek proje verilerini gösterir
struct ProjectBoardView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var projectManager: ProjectManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = 0
    @State private var selectedProjectIndex: Int?
    @State private var selectedTaskIndex: Int?
    @State private var showTaskDetail = false
    
    let tabs = ["Yapılacaklar", "Devam Ediyor", "Tamamlandı"]
    let selectedTabColor = Color.blue
    
    // Tüm projelerden görevleri topla
    var allTasks: [ProjectTask] {
        projectManager.projects.flatMap { $0.tasks }
    }
    
    var filteredTasks: [ProjectTask] {
        switch selectedTab {
        case 0: // Yapılacaklar (To-Do)
            return allTasks.filter { !$0.isCompleted && $0.priority != .high }
        case 1: // Devam Ediyor (In Progress - yüksek öncelikli)
            return allTasks.filter { !$0.isCompleted && $0.priority == .high }
        case 2: // Tamamlandı
            return allTasks.filter { $0.isCompleted }
        default:
            return allTasks
        }
    }
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title3)
                            .foregroundColor(themeManager.textColor)
                    }
                    
                    Spacer()
                    
                    Text("Proje Panosu")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(themeManager.textColor)
                    
                    Spacer()
                    
                    // Invisible button for balance
                    Image(systemName: "arrow.left")
                        .font(.title3)
                        .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // Custom Tab Bar
                HStack(spacing: 0) {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = index
                            }
                        }) {
                            VStack(spacing: 8) {
                                Text(tabs[index])
                                    .font(.system(size: 15, weight: selectedTab == index ? .semibold : .regular))
                                    .foregroundColor(selectedTab == index ? selectedTabColor : themeManager.secondaryTextColor)
                                
                                // Bottom indicator
                                Rectangle()
                                    .fill(selectedTab == index ? selectedTabColor : Color.clear)
                                    .frame(height: 2)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // Tasks List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredTasks) { task in
                            TaskBoardCard(task: task)
                                .environmentObject(themeManager)
                                .onTapGesture {
                                    // Hangi projeye ait olduğunu bul
                                    for (pIndex, project) in projectManager.projects.enumerated() {
                                        if let tIndex = project.tasks.firstIndex(where: { $0.id == task.id }) {
                                            selectedProjectIndex = pIndex
                                            selectedTaskIndex = tIndex
                                            showTaskDetail = true
                                            break
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showTaskDetail) {
            if let pIndex = selectedProjectIndex,
               let tIndex = selectedTaskIndex,
               pIndex < projectManager.projects.count,
               tIndex < projectManager.projects[pIndex].tasks.count {
                TaskDetailView(task: Binding(
                    get: { projectManager.projects[pIndex].tasks[tIndex] },
                    set: { projectManager.projects[pIndex].tasks[tIndex] = $0 }
                ))
                .environmentObject(themeManager)
            }
        }
    }
}

// MARK: - Task Board Card
struct TaskBoardCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let task: ProjectTask
    
    var body: some View {
        HStack(spacing: 16) {
            // Sol taraf - Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: "list.bullet")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
            }
            
            // Orta - Başlık ve tarih
            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.textColor)
                    .lineLimit(1)
                
                if task.dueDate != nil {
                    Text(task.formattedDueDate)
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.secondaryTextColor)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.cardBackground)
        )
    }
}

// MARK: - Preview
struct ProjectBoardView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectBoardView()
            .environmentObject(ThemeManager.shared)
            .preferredColorScheme(.dark)
        
        ProjectBoardView()
            .environmentObject(ThemeManager.shared)
            .preferredColorScheme(.light)
    }
}
