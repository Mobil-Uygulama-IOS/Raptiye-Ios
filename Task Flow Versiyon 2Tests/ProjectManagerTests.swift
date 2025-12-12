//
//  ProjectManagerTests.swift
//  Task Flow Versiyon 2Tests
//
//  Created on 2 Aralık 2025.
//

import XCTest
@testable import Task_Flow_Versiyon_2

@MainActor
final class ProjectManagerTests: XCTestCase {
    
    var projectManager: ProjectManager!
    
    override func setUp() {
        super.setUp()
        projectManager = ProjectManager()
    }
    
    override func tearDown() {
        projectManager = nil
        super.tearDown()
    }
    
    // MARK: - Project Creation Tests
    
    func testProjectInitialization() {
        // Given
        let project = Project(
            title: "Test Projesi",
            description: "Test açıklaması",
            dueDate: Date(),
            status: .notStarted
        )
        
        // Then
        XCTAssertEqual(project.title, "Test Projesi")
        XCTAssertEqual(project.description, "Test açıklaması")
        XCTAssertEqual(project.status, .notStarted)
        XCTAssertTrue(project.tasks.isEmpty)
    }
    
    func testProjectStatusEnum() {
        // Given & When
        let notStarted = ProjectStatus.notStarted
        let inProgress = ProjectStatus.inProgress
        let completed = ProjectStatus.completed
        
        // Then
        XCTAssertEqual(notStarted.rawValue, "notStarted")
        XCTAssertEqual(inProgress.rawValue, "inProgress")
        XCTAssertEqual(completed.rawValue, "completed")
    }
    
    // MARK: - Task Tests
    
    func testTaskInitialization() {
        // Given
        let task = ProjectTask(
            title: "Test Görevi",
            description: "Test görev açıklaması",
            dueDate: Date(),
            priority: .high,
            status: .notStarted,
            assignedTo: nil
        )
        
        // Then
        XCTAssertEqual(task.title, "Test Görevi")
        XCTAssertEqual(task.priority, .high)
        XCTAssertEqual(task.status, .notStarted)
        XCTAssertNil(task.assignedTo)
    }
    
    func testTaskPriorityEnum() {
        // Given & When
        let low = TaskPriority.low
        let medium = TaskPriority.medium
        let high = TaskPriority.high
        
        // Then
        XCTAssertEqual(low.rawValue, "low")
        XCTAssertEqual(medium.rawValue, "medium")
        XCTAssertEqual(high.rawValue, "high")
    }
    
    // MARK: - ProjectManager Tests
    
    func testProjectManagerInitialization() {
        // Then
        XCTAssertNotNil(projectManager)
        XCTAssertTrue(projectManager.projects.isEmpty)
        XCTAssertFalse(projectManager.isLoading)
        XCTAssertNil(projectManager.errorMessage)
    }
    
    func testProjectsArrayEmpty() {
        // Given & When
        let isEmpty = projectManager.projects.isEmpty
        
        // Then
        XCTAssertTrue(isEmpty)
        XCTAssertEqual(projectManager.projects.count, 0)
    }
    
    // MARK: - Performance Tests
    
    func testProjectCreationPerformance() {
        measure {
            _ = Project(
                title: "Performance Test",
                description: "Testing performance",
                dueDate: Date(),
                status: .inProgress
            )
        }
    }
}
