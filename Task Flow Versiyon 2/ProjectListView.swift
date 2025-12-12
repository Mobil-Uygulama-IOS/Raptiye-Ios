import SwiftUI

struct ProjectListView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var projectManager: ProjectManager
    @StateObject private var localization = LocalizationManager.shared
    @State private var searchText = ""
    @State private var selectedSortOption = LocalizationManager.shared.localizedString("SortOptionDate")
    @State private var selectedFilterOption = LocalizationManager.shared.localizedString("FilterOptionAll")
    @State private var showAnalytics = false
    @State private var showProjectBoard = false
    @State private var selectedProject: Project?
    @State private var showCreateProject = false
    
    init() {
        print("📋 ProjectListView initialized")
    }
    
    var sortOptions: [String] {
        [localization.localizedString("SortOptionDate"), localization.localizedString("SortOptionName"), localization.localizedString("SortOptionProgress")]
    }

    var filterOptions: [String] {
        [localization.localizedString("FilterOptionAll"), localization.localizedString("FilterOptionActive"), localization.localizedString("FilterOptionCompleted")]
    }
    
    var filteredProjects: [Project] {
        var filtered = projectManager.projects
        
        // Arama filtresi
        if !searchText.isEmpty {
            filtered = filtered.filter { project in
                project.title.localizedCaseInsensitiveContains(searchText) ||
                project.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Durum filtresi
        let activeKey = localization.localizedString("FilterOptionActive")
        let completedKey = localization.localizedString("FilterOptionCompleted")
        switch selectedFilterOption {
        case activeKey:
            filtered = filtered.filter { !$0.isCompleted }
        case completedKey:
            filtered = filtered.filter { $0.isCompleted }
        default:
            break
        }
        
        // Sıralama
        let nameKey = localization.localizedString("SortOptionName")
        let progressKey = localization.localizedString("SortOptionProgress")
        switch selectedSortOption {
        case nameKey:
            filtered = filtered.sorted { $0.title < $1.title }
        case progressKey:
            filtered = filtered.sorted { $0.progressPercentage > $1.progressPercentage }
        default: // Date
            filtered = filtered.sorted { $0.createdDate > $1.createdDate }
        }
        
        return filtered
    }
    
    var body: some View {
        let _ = print("📋 ProjectListView render")
        
        // NavigationView YOK (Doğru), ama modifierlar ZStack'e eklenecek.
        return ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // --- Header Kısmı ---
                HStack {
                    Text(localization.localizedString("Projects"))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.textColor)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        // Analytics button
                        Button(action: {
                            if !projectManager.projects.isEmpty {
                                selectedProject = projectManager.projects.first
                                showAnalytics = true
                            }
                        }) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(projectManager.projects.isEmpty ? Color.orange.opacity(0.5) : Color.orange)
                                .clipShape(Circle())
                        }
                        .disabled(projectManager.projects.isEmpty)
                        
                        // Kanban Board button
                        Button(action: {
                            if !projectManager.projects.isEmpty {
                                showProjectBoard = true
                            }
                        }) {
                            Image(systemName: "square.grid.2x2.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(projectManager.projects.isEmpty ? Color.green.opacity(0.5) : Color.green)
                                .clipShape(Circle())
                        }
                        .disabled(projectManager.projects.isEmpty)
                        
                        // Add new project button
                        Button(action: {
                            showCreateProject = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, ((UIApplication.shared.connectedScenes.compactMap { ($0 as? UIWindowScene)?.windows.first?.safeAreaInsets.top }.first) ?? 0) + 8)
                .padding(.bottom, 16)
                .background(themeManager.backgroundColor.ignoresSafeArea(.container, edges: .top))
                
                // --- Scrollable Content ---
                ScrollView {
                    VStack(spacing: 0) {
                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(themeManager.secondaryTextColor)
                            
                            TextField(localization.localizedString("SearchProjectsPlaceholder"), text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                                .foregroundColor(themeManager.textColor)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(themeManager.searchBackground)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        // Sort and Filter buttons
                        HStack(spacing: 12) {
                            // Sort dropdown
                            Menu {
                                ForEach(sortOptions, id: \.self) { option in
                                    Button(action: {
                                        selectedSortOption = option
                                    }) {
                                        HStack {
                                            Text(option)
                                            if selectedSortOption == option {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(localization.localizedString("Sort"))
                                    Image(systemName: "chevron.down")
                                }
                                .font(.subheadline)
                                .foregroundColor(themeManager.textColor)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(themeManager.cardBackground)
                                .cornerRadius(8)
                            }
                            
                            // Filter dropdown
                            Menu {
                                ForEach(filterOptions, id: \.self) { option in
                                    Button(action: {
                                        selectedFilterOption = option
                                    }) {
                                        HStack {
                                            Text(option)
                                            if selectedFilterOption == option {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(localization.localizedString("Filter"))
                                    Image(systemName: "chevron.down")
                                }
                                .font(.subheadline)
                                .foregroundColor(themeManager.textColor)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(themeManager.cardBackground)
                                .cornerRadius(8)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        // Projects section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text(localization.localizedString("MyProjects"))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(themeManager.textColor)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 24)
                            
                            // --- PROJECTS LIST ---
                            if filteredProjects.isEmpty {
                                // Empty state view...
                                emptyStateView
                            } else {
                                // LISTE BURADA BAŞLIYOR
                                LazyVStack(spacing: 12) {
                                    ForEach(filteredProjects) { project in
                                        Button(action: {
                                            print("🔍 Proje seçildi (Button): \(project.title)")
                                            selectedProject = project
                                        }) {
                                            ProjectCardView(project: project)
                                        }
                                        .buttonStyle(PlainButtonStyle()) 
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                            }
                        }
                    }
                } // ScrollView sonu
            }
        }
        // DÜZELTME BURADA:
        // NavigationView sargısı YOK, ama Parent View'dan (MainApp/CustomTabView) gelen barı gizlemek zorundayız.
        .navigationBarTitle("") // Başlığı boşalt
        .navigationBarHidden(true) // Barı tamamen gizle (Legacy)
        .navigationBarBackButtonHidden(true) // Geri butonunu gizle
        .edgesIgnoringSafeArea(.all) // Kenar boşluklarını yok say
        // --- Navigation / Sheets ---
        .sheet(item: $selectedProject) { project in
            ProjectDetailView(project: Binding(
                get: { 
                    projectManager.projects.first(where: { $0.id == project.id }) ?? project 
                },
                set: { updatedProject in
                    Task {
                        try? await projectManager.updateProject(updatedProject)
                    }
                }
            ))
            .environmentObject(themeManager)
            .environmentObject(projectManager)
        }
        .sheet(isPresented: $showAnalytics) {
            if let project = selectedProject {
                ProjectAnalyticsView(project: project)
                    .environmentObject(themeManager)
            }
        }
        .sheet(isPresented: $showProjectBoard) {
            ProjectBoardView()
                .environmentObject(themeManager)
                .environmentObject(projectManager)
        }
        .sheet(isPresented: $showCreateProject) {
            CreateProjectView { newProject in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if let foundProject = projectManager.projects.first(where: { $0.id == newProject.id }) {
                        selectedProject = foundProject
                    }
                }
            }
            .environmentObject(projectManager)
            .environmentObject(themeManager)
        }
    }
    
    // Empty state view
    var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 60)
            
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 70))
                .foregroundColor(themeManager.secondaryTextColor.opacity(0.5))
            
            VStack(spacing: 8) {
                Text(searchText.isEmpty ? localization.localizedString("NoProjectsYet") : localization.localizedString("ProjectNotFound"))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.textColor)
                
                Text(searchText.isEmpty ? localization.localizedString("NoProjectsYetMessage") : localization.localizedString("ProjectNotFoundMessage"))
                    .font(.subheadline)
                    .foregroundColor(themeManager.secondaryTextColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            if searchText.isEmpty {
                Button(action: {
                    showCreateProject = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text(localization.localizedString("CreateNewProject"))
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.top, 8)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Project Card View
struct ProjectCardView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let project: Project
    
    var body: some View {
        HStack(spacing: 16) {
            // Project icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(project.iconColor).opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: project.iconName)
                    .font(.title2)
                    .foregroundColor(Color(project.iconColor))
            }
            
            // Project info
            VStack(alignment: .leading, spacing: 4) {
                Text(project.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.textColor)
                    .lineLimit(1)
                
                Text(project.description)
                    .font(.subheadline)
                    .foregroundColor(themeManager.secondaryTextColor)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Progress bar (if has tasks)
                if project.tasksCount > 0 {
                    HStack(spacing: 8) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color(.systemGray4))
                                    .frame(height: 4)
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.blue)
                                    .frame(width: geometry.size.width * project.progressPercentage, height: 4)
                            }
                        }
                        .frame(height: 4)
                        
                        Text("\(project.completedTasksCount)/\(project.tasksCount)")
                            .font(.caption)
                            .foregroundColor(themeManager.secondaryTextColor)
                            .frame(minWidth: 30)
                    }
                }
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(themeManager.secondaryTextColor)
        }
        .padding(16)
        .background(themeManager.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Preview
struct ProjectListView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectListView()
            .environmentObject(ThemeManager.shared)
            .preferredColorScheme(.light)
    }
}