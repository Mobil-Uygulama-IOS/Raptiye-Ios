# Edit and Delete Project Feature

## Overview
Added complete edit and delete functionality to ProjectDetailView, allowing users to modify project details or remove projects from the system.

## Changes Made

### 1. ProjectDetailView.swift
**New Features:**
- Added menu button (ellipsis.circle icon) in the header next to analytics button
- Added action sheet with "Edit Project" and "Delete Project" options
- Added delete confirmation alert
- Implemented deleteProject() function with proper async/await and error handling

**State Variables Added:**
```swift
@State private var showEditProject = false
@State private var showDeleteConfirmation = false
@State private var showActionSheet = false
@StateObject private var localization = LocalizationManager.shared
```

**UI Components:**
- `.confirmationDialog()` - Shows edit/delete options when menu button is tapped
- `.sheet(isPresented: $showEditProject)` - Opens CreateProjectView in edit mode
- `.alert()` - Confirms deletion before executing

**Localization:**
All UI strings now use LocalizationManager for Turkish/English support:
- "EditProject"
- "DeleteProject"
- "DeleteProjectConfirmation"
- "Cancel"
- "Delete"

### 2. CreateProjectView.swift
**New Features:**
- Added support for edit mode via optional `projectToEdit` parameter
- Form now pre-fills with existing project data when editing
- Submit button text changes based on mode ("Save Changes" vs "Save and Create")
- Header title changes based on mode ("Edit Project" vs "Create New Project")

**New Properties:**
```swift
var projectToEdit: Project?
@StateObject private var localization = LocalizationManager.shared

private var isEditMode: Bool {
    projectToEdit != nil
}
```

**Edit Mode Logic:**
- `.onAppear` loads existing project data into form fields
- `createProject()` function now handles both create and update operations
- Uses `projectManager.updateProject()` when editing
- Uses `projectManager.createProject()` when creating

**Localization:**
- "EditProject"
- "CreateNewProject"
- "SaveChanges"
- "SaveAndCreate"

### 3. Localization Files

**tr.lproj/Localizable.strings (Turkish):**
```
"EditProject" = "Projeyi Düzenle";
"DeleteProject" = "Projeyi Sil";
"DeleteProjectConfirmation" = "Bu projeyi silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.";
"SaveChanges" = "Değişiklikleri Kaydet";
"CreateNewProject" = "Yeni Proje Oluştur";
"SaveAndCreate" = "Kaydet ve Oluştur";
"Delete" = "Sil";
```

**en.lproj/Localizable.strings (English):**
```
"EditProject" = "Edit Project";
"DeleteProject" = "Delete Project";
"DeleteProjectConfirmation" = "Are you sure you want to delete this project? This action cannot be undone.";
"SaveChanges" = "Save Changes";
"CreateNewProject" = "Create New Project";
"SaveAndCreate" = "Save and Create";
"Delete" = "Delete";
```

### 4. ProjectManager.swift
**Existing Functions Used:**
- `func updateProject(_ project: Project) async throws` - Updates existing project in Firestore
- `func deleteProject(_ project: Project) async throws` - Deletes project from Firestore

## User Flow

### Edit Project:
1. User opens ProjectDetailView
2. Taps menu button (ellipsis.circle) in header
3. Selects "Projeyi Düzenle" / "Edit Project" from action sheet
4. CreateProjectView opens with pre-filled data
5. User modifies title, description, or due date
6. Taps "Değişiklikleri Kaydet" / "Save Changes"
7. Project updates in Firestore
8. View dismisses and shows updated project

### Delete Project:
1. User opens ProjectDetailView
2. Taps menu button (ellipsis.circle) in header
3. Selects "Projeyi Sil" / "Delete Project" from action sheet
4. Confirmation alert appears with warning message
5. User taps "Sil" / "Delete" to confirm
6. Project is deleted from Firestore
7. View dismisses back to project list
8. Project removed from UI

## Technical Details

### Async/Await Pattern:
```swift
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
```

### Edit Mode Detection:
```swift
private var isEditMode: Bool {
    projectToEdit != nil
}
```

### Data Pre-loading:
```swift
.onAppear {
    if let project = projectToEdit {
        projectTitle = project.title
        projectDescription = project.description
        dueDate = project.dueDate
        tasks = project.tasks.map { $0.title }
    }
}
```

## Testing Checklist
- [ ] Open existing project in ProjectDetailView
- [ ] Tap menu button (ellipsis icon) - action sheet should appear
- [ ] Tap "Edit Project" - CreateProjectView should open with existing data
- [ ] Modify project title and description
- [ ] Tap "Save Changes" - project should update
- [ ] Verify changes reflected in ProjectDetailView
- [ ] Tap menu button again
- [ ] Tap "Delete Project" - confirmation alert should appear
- [ ] Tap "Cancel" - nothing happens
- [ ] Tap menu button and "Delete Project" again
- [ ] Tap "Delete" - project should be deleted
- [ ] Verify view dismisses to project list
- [ ] Verify project removed from list
- [ ] Test with Turkish language
- [ ] Test with English language
- [ ] Verify all strings are properly localized

## Dependencies
- LocalizationManager.swift - Manages Turkish/English translations
- ProjectManager.swift - Handles Firebase operations (updateProject, deleteProject)
- FirebaseFirestore - Backend database

## Notes
- Edit mode preserves existing tasks but allows modification of project metadata (title, description, due date)
- Delete operation is permanent and cannot be undone
- All operations use async/await for proper error handling
- UI dismisses automatically on successful operations
- Localization fully implemented for bilingual support
