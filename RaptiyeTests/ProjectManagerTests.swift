//
//  ProjectManagerTests.swift
//  RaptiyeTests
//
//  Created on 2 Aralık 2025.
//

import XCTest
@testable import Raptiye

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
        // Given & When: ProjectManager oluşturuldu
        
        // Then: Başlangıç değerleri doğru olmalı
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.projects.count, 0)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }
    
    // MARK: - Project Tests
    
    func testProjectInitialization() {
        // Given: Proje verisi
        let project = Project(
            title: "Test Projesi",
            description: "Test açıklaması",
            iconName: "folder.fill",
            iconColor: "blue",
            status: .todo
        )
        
        // Then: Proje özellikleri doğru olmalı
        XCTAssertEqual(project.title, "Test Projesi")
        XCTAssertEqual(project.description, "Test açıklaması")
        XCTAssertEqual(project.iconName, "folder.fill")
        XCTAssertEqual(project.iconColor, "blue")
        XCTAssertEqual(project.status, .todo)
        XCTAssertEqual(project.tasks.count, 0)
    }
    
    func testProjectStatusEnum() {
        // Given: Status enum değerleri
        let todoStatus = ProjectStatus.todo
        let inProgressStatus = ProjectStatus.inProgress
        let completedStatus = ProjectStatus.completed
        
        // Then: Status değerleri doğru olmalı
        XCTAssertEqual(todoStatus.rawValue, "Yapılacaklar")
        XCTAssertEqual(inProgressStatus.rawValue, "Devam Ediyor")
        XCTAssertEqual(completedStatus.rawValue, "Tamamlandı")
    }
    
    func testProjectProgressCalculation() {
        // Given: Task'lı proje
        let task1 = ProjectTask(
            title: "Task 1",
            description: "Test task 1",
            isCompleted: true,
            priority: .high
        )
        let task2 = ProjectTask(
            title: "Task 2",
            description: "Test task 2",
            isCompleted: false,
            priority: .medium
        )
        
        let project = Project(
            title: "Test",
            description: "Test",
            tasks: [task1, task2]
        )
        
        // Then: Progress hesaplaması doğru olmalı
        XCTAssertEqual(project.tasksCount, 2)
        XCTAssertEqual(project.completedTasksCount, 1)
        XCTAssertEqual(project.progressPercentage, 0.5, accuracy: 0.01)
    }
    
    // MARK: - ProjectTask Tests
    
    func testProjectTaskInitialization() {
        // Given: Task verisi
        let task = ProjectTask(
            title: "Test Task",
            description: "Test açıklaması",
            isCompleted: false,
            priority: .high
        )
        
        // Then: Task özellikleri doğru olmalı
        XCTAssertEqual(task.title, "Test Task")
        XCTAssertEqual(task.description, "Test açıklaması")
        XCTAssertEqual(task.priority, .high)
        XCTAssertFalse(task.isCompleted)
    }
    
    func testTaskPriorityEnum() {
        // Given: Priority enum değerleri
        let lowPriority = TaskPriority.low
        let mediumPriority = TaskPriority.medium
        let highPriority = TaskPriority.high
        
        // Then: Priority değerleri doğru olmalı
        XCTAssertEqual(lowPriority.rawValue, "Düşük")
        XCTAssertEqual(mediumPriority.rawValue, "Orta")
        XCTAssertEqual(highPriority.rawValue, "Yüksek")
    }
    
    // MARK: - Loading State Tests
    
    func testLoadingStateInitiallyFalse() {
        // Given & When: Yeni ProjectManager
        
        // Then: Loading başlangıçta false olmalı
        XCTAssertFalse(sut.isLoading)
    }
    
    func testLoadingStateCanBeToggled() {
        // Given: Loading başlangıçta false
        XCTAssertFalse(sut.isLoading)
        
        // When: Loading true yapılır
        sut.isLoading = true
        
        // Then: Loading true olmalı
        XCTAssertTrue(sut.isLoading)
    }
    
    // MARK: - Error Message Tests
    
    func testErrorMessageInitiallyNil() {
        // Given & When: Yeni ProjectManager
        
        // Then: Error mesajı başlangıçta nil olmalı
        XCTAssertNil(sut.errorMessage)
    }
    
    func testErrorMessageCanBeSet() {
        // Given: Test error mesajı
        let testError = "Test error mesajı"
        
        // When: Error mesajı set edilir
        sut.errorMessage = testError
        
        // Then: Error mesajı doğru olmalı
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertEqual(sut.errorMessage, testError)
    }
    
    // MARK: - Projects Array Tests
    
    func testProjectsArrayInitiallyEmpty() {
        // Given & When: Yeni ProjectManager
        
        // Then: Projects dizisi başlangıçta boş olmalı
        XCTAssertTrue(sut.projects.isEmpty)
        XCTAssertEqual(sut.projects.count, 0)
    }
    
    func testProjectsArrayCanBePopulated() {
        // Given: Test projeleri
        let project1 = Project(title: "Proje 1", description: "Açıklama 1")
        let project2 = Project(title: "Proje 2", description: "Açıklama 2")
        
        // When: Projeler eklenir
        sut.projects = [project1, project2]
        
        // Then: Projects dizisi dolu olmalı
        XCTAssertFalse(sut.projects.isEmpty)
        XCTAssertEqual(sut.projects.count, 2)
        XCTAssertEqual(sut.projects[0].title, "Proje 1")
        XCTAssertEqual(sut.projects[1].title, "Proje 2")
    }
}
