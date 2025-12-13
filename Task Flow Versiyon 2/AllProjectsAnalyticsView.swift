import SwiftUI
import Charts

struct AllProjectsAnalyticsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var projectManager: ProjectManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
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
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Text("Proje Analizi")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(themeManager.textColor)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Overview Cards
                        overviewSection
                        
                        // Project Status Chart
                        statusChartSection
                        
                        // Progress Chart
                        progressChartSection
                        
                        // Projects List
                        projectsListSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    // MARK: - Overview Section
    
    private var overviewSection: some View {
        VStack(spacing: 16) {
            Text("Genel Bakış")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(themeManager.textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCard(
                    title: "Toplam Proje",
                    value: "\(projectManager.projects.count)",
                    icon: "folder.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Tamamlanan",
                    value: "\(completedProjectsCount)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Devam Eden",
                    value: "\(activeProjectsCount)",
                    icon: "clock.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "Toplam Görev",
                    value: "\(totalTasksCount)",
                    icon: "list.bullet",
                    color: .purple
                )
            }
        }
        .padding(.top, 16)
    }
    
    // MARK: - Status Chart Section
    
    private var statusChartSection: some View {
        VStack(spacing: 16) {
            Text("Proje Durumları")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(themeManager.textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if #available(iOS 16.0, *) {
                Chart {
                    SectorMark(
                        angle: .value("Tamamlanan", completedProjectsCount),
                        innerRadius: .ratio(0.5),
                        angularInset: 2
                    )
                    .foregroundStyle(.green)
                    .annotation(position: .overlay) {
                        if completedProjectsCount > 0 {
                            Text("\(completedProjectsCount)")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                        }
                    }
                    
                    SectorMark(
                        angle: .value("Devam Eden", activeProjectsCount),
                        innerRadius: .ratio(0.5),
                        angularInset: 2
                    )
                    .foregroundStyle(.orange)
                    .annotation(position: .overlay) {
                        if activeProjectsCount > 0 {
                            Text("\(activeProjectsCount)")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                        }
                    }
                }
                .frame(height: 200)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(themeManager.cardBackground)
                )
            }
            
            // Legend
            HStack(spacing: 24) {
                LegendItem(color: .green, title: "Tamamlanan", value: completedProjectsCount)
                LegendItem(color: .orange, title: "Devam Eden", value: activeProjectsCount)
            }
        }
    }
    
    // MARK: - Progress Chart Section
    
    private var progressChartSection: some View {
        VStack(spacing: 16) {
            Text("Proje İlerlemeleri")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(themeManager.textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if #available(iOS 16.0, *) {
                Chart(projectManager.projects) { project in
                    BarMark(
                        x: .value("İlerleme", project.progressPercentage * 100),
                        y: .value("Proje", project.title)
                    )
                    .foregroundStyle(project.progressPercentage >= 1.0 ? Color.green : Color.blue)
                    .cornerRadius(4)
                }
                .chartXScale(domain: 0...100)
                .chartXAxis {
                    AxisMarks(values: [0, 25, 50, 75, 100]) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let intValue = value.as(Int.self) {
                                Text("%\(intValue)")
                                    .font(.caption)
                            }
                        }
                    }
                }
                .frame(height: CGFloat(projectManager.projects.count * 50 + 40))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(themeManager.cardBackground)
                )
            }
        }
    }
    
    // MARK: - Projects List Section
    
    private var projectsListSection: some View {
        VStack(spacing: 16) {
            Text("Projeler")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(themeManager.textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(projectManager.projects.sorted { $0.progressPercentage > $1.progressPercentage }) { project in
                ProjectProgressRow(project: project)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var completedProjectsCount: Int {
        projectManager.projects.filter { $0.isCompleted }.count
    }
    
    private var activeProjectsCount: Int {
        projectManager.projects.filter { !$0.isCompleted }.count
    }
    
    private var totalTasksCount: Int {
        projectManager.projects.reduce(0) { $0 + $1.tasksCount }
    }
    
    private var completedTasksCount: Int {
        projectManager.projects.reduce(0) { $0 + $1.completedTasksCount }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(themeManager.textColor)
                
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.secondaryTextColor)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.cardBackground)
        )
    }
}

// MARK: - Legend Item

struct LegendItem: View {
    let color: Color
    let title: String
    let value: Int
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text("\(title): \(value)")
                .font(.system(size: 14))
                .foregroundColor(themeManager.secondaryTextColor)
        }
    }
}

// MARK: - Project Progress Row

struct ProjectProgressRow: View {
    let project: Project
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(project.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.textColor)
                
                Spacer()
                
                Text("%\(Int(project.progressPercentage * 100))")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(project.isCompleted ? .green : .blue)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(project.isCompleted ? Color.green : Color.blue)
                        .frame(width: geometry.size.width * project.progressPercentage, height: 8)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("\(project.completedTasksCount)/\(project.tasksCount) görev")
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.secondaryTextColor)
                
                Spacer()
                
                if project.isCompleted {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                        Text("Tamamlandı")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.green)
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

// MARK: - Preview

#Preview {
    AllProjectsAnalyticsView()
        .environmentObject(ProjectManager())
        .environmentObject(ThemeManager.shared)
}
