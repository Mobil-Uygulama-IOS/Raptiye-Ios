//
//  ProjectManagerTests.swift
//  RaptiyeTests
//
//  Created on 2 Aralık 2025.
//

import XCTest
@testable import Task_Flow_Versiyon_2

@MainActor
final class ProjectManagerTests: XCTestCase {
    
    var sut: ProjectManager!
    
    override func setUp() {
        super.setUp()
        sut = ProjectManager()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testProjectManagerInitialization() {
        // Given & When: ProjectManager oluşturuldu (setUp'ta)
        
        // Then: Başlangıç değerleri doğru olmalı
        XCTAssertNotNil(sut, "ProjectManager nil olmamalı")
        XCTAssertTrue(sut.projects.isEmpty, "Başlangıçta projeler listesi boş olmalı")
        XCTAssertFalse(sut.isLoading, "Başlangıçta loading false olmalı")
        XCTAssertNil(sut.errorMessage, "Başlangıçta error mesajı nil olmalı")
    }
    
    // MARK: - Project Creation Tests
    
    func testCreateProjectWithValidData() async throws {
        // Given: Geçerli proje verisi
        let testProject = Project(
            title: "Test Projesi",
            description: "Test açıklaması",
            dueDate: Date().addingTimeInterval(7*24*60*60),
            status: .notStarted
        )
        
        // When: Proje oluşturulmaya çalışılır
        // Note: Bu test Firebase'e bağlı olduğu için gerçek ortamda çalışır
        // Mock veya test Firebase instance kullanılmalı
        
        // Then: Proje özellikleri doğru olmalı
        XCTAssertEqual(testProject.title, "Test Projesi")
        XCTAssertEqual(testProject.description, "Test açıklaması")
        XCTAssertEqual(testProject.status, .notStarted)
        XCTAssertTrue(testProject.tasks.isEmpty)
    }
    
    func testCreateProjectWithEmptyTitle() {
        // Given: Boş başlıklı proje
        let testProject = Project(
            title: "",
            description: "Test açıklaması",
            dueDate: Date(),
            status: .notStarted
        )
        
        // Then: Başlık boş olabilir (validation UI'da yapılmalı)
        XCTAssertTrue(testProject.title.isEmpty)
    }
    
    // MARK: - Task Management Tests
    
    func testAddTaskToProject() {
        // Given: Bir proje ve task
        var testProject = Project(
            title: "Test Projesi",
            description: "Test",
            dueDate: Date(),
            status: .inProgress
        )
        
        let testTask = ProjectTask(
            title: "Test Task",
            description: "Task açıklaması",
            dueDate: Date(),
            priority: .high,
            status: .notStarted
        )
        
        // When: Task projeye eklenir
        testProject.tasks.append(testTask)
        
        // Then: Task listesinde olmalı
        XCTAssertEqual(testProject.tasks.count, 1)
        XCTAssertEqual(testProject.tasks.first?.title, "Test Task")
    }
    
    func testMultipleTasksInProject() {
        // Given: Bir proje ve birden fazla task
        var testProject = Project(
            title: "Test Projesi",
            description: "Test",
            dueDate: Date(),
            status: .inProgress
        )
        
        let tasks = [
            ProjectTask(title: "Task 1", description: "Desc 1", dueDate: Date(), priority: .high, status: .notStarted),
            ProjectTask(title: "Task 2", description: "Desc 2", dueDate: Date(), priority: .medium, status: .inProgress),
            ProjectTask(title: "Task 3", description: "Desc 3", dueDate: Date(), priority: .low, status: .completed)
        ]
        
        // When: Tasklar eklenir
        testProject.tasks = tasks
        
        // Then: Tüm tasklar listede olmalı
        XCTAssertEqual(testProject.tasks.count, 3)
        XCTAssertEqual(testProject.tasks[0].title, "Task 1")
        XCTAssertEqual(testProject.tasks[1].status, .inProgress)
        XCTAssertEqual(testProject.tasks[2].priority, .low)
    }
    
    // MARK: - Project Status Tests
    
    func testProjectStatusTypes() {
        // Given: Farklı statuslerde projeler
        let notStartedProject = Project(title: "P1", description: "", dueDate: Date(), status: .notStarted)
        let inProgressProject = Project(title: "P2", description: "", dueDate: Date(), status: .inProgress)
        let completedProject = Project(title: "P3", description: "", dueDate: Date(), status: .completed)
        
        // Then: Status değerleri doğru olmalı
        XCTAssertEqual(notStartedProject.status, .notStarted)
        XCTAssertEqual(inProgressProject.status, .inProgress)
        XCTAssertEqual(completedProject.status, .completed)
    }
    
    // MARK: - Team Management Tests
    
    func testProjectWithTeamMembers() {
        // Given: Takım üyeleri olan proje
        let teamLeader = User(uid: "leader123", email: "leader@test.com", displayName: "Lider")
        let member1 = User(uid: "member1", email: "m1@test.com", displayName: "Üye 1")
        let member2 = User(uid: "member2", email: "m2@test.com", displayName: "Üye 2")
        
        let project = Project(
            title: "Takım Projesi",
            description: "Takım çalışması",
            dueDate: Date(),
            status: .inProgress,
            teamLeader: teamLeader,
            teamMembers: [member1, member2]
        )
        
        // Then: Takım bilgileri doğru olmalı
        XCTAssertNotNil(project.teamLeader)
        XCTAssertEqual(project.teamLeader?.displayName, "Lider")
        XCTAssertEqual(project.teamMembers.count, 2)
        XCTAssertEqual(project.teamMembers[0].displayName, "Üye 1")
    }
    
    // MARK: - Date Validation Tests
    
    func testProjectDueDateInFuture() {
        // Given: Gelecek tarihli proje
        let futureDate = Date().addingTimeInterval(30*24*60*60) // 30 gün sonra
        let project = Project(
            title: "Gelecek Proje",
            description: "Test",
            dueDate: futureDate,
            status: .notStarted
        )
        
        // Then: Due date gelecekte olmalı
        XCTAssertTrue(project.dueDate > Date())
    }
    
    func testProjectDueDateInPast() {
        // Given: Geçmiş tarihli proje
        let pastDate = Date().addingTimeInterval(-7*24*60*60) // 7 gün önce
        let project = Project(
            title: "Geçmiş Proje",
            description: "Test",
            dueDate: pastDate,
            status: .completed
        )
        
        // Then: Due date geçmişte olmalı
        XCTAssertTrue(project.dueDate < Date())
    }
}
