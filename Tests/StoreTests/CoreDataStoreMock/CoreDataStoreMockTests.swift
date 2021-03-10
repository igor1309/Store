//
//  CoreDataStoreMockTests.swift
//  
//
//  Created by Igor Malyarov on 04.03.2021.
//

import XCTest
import CoreData
import Combine
@testable import Store

@available(macOS 11.0, *)
final class CoreDataStoreMockTests: XCTestCase {
    var store: CoreDataStoreMock!
    let requestAll = CDProject.fetchRequest(NSPredicate.all)

    override func setUpWithError() throws {
        let coreDataStack = CoreDataStack(inMemory: true)
        let context = coreDataStack.context
        store = CoreDataStoreMock(context: context)
    }

    func testInsertObject() throws {
        XCTAssertEqual(store.context.realCount(for: requestAll), 0, "Data store should be empty.")

        let expectation = expectation(description: String(describing: #function))
        let project = Project(name: "test", amount: 10, id: UUID())
        _ = store.insert(project)
            .sink { _ in
            } receiveValue: { value in
                XCTAssertEqual(value, project)
                expectation.fulfill()
            }

        waitForExpectations(timeout: 2)

        XCTAssertEqual(self.store.context.realCount(for: requestAll), 1, "Should be 1 CDProject in store.")
        let results = try store.context.fetch(requestAll)
        let cdProject = try XCTUnwrap(results.first)
        XCTAssertEqual(cdProject.name, project.name)
        XCTAssertEqual(cdProject.amount, project.amount)
        XCTAssertEqual(cdProject.id, project.id)
    }

    func testUpdateObject() throws {
        XCTAssertEqual(store.context.realCount(for: requestAll), 0, "Data store should be empty.")

        let expectation = expectation(description: String(describing: #function))
        let project = Project(name: "test", amount: 10, id: UUID())
        _ = store.insert(project)
            .flatMap { project -> Future<Project, Error> in
                var copy = project
                copy.amount = 100
                return self.store.update(copy)
            }
            .sink { _ in
            } receiveValue: { value in
                XCTAssertEqual(value.name, project.name)
                XCTAssertEqual(value.amount, 100)
                XCTAssertEqual(value.id, project.id)
                expectation.fulfill()
            }

        waitForExpectations(timeout: 2)

        XCTAssertEqual(self.store.context.realCount(for: requestAll), 1, "Should be 1 CDProject in store.")
        let results = try store.context.fetch(requestAll)
        let cdProject = try XCTUnwrap(results.first)
        XCTAssertEqual(cdProject.name, "test")
        XCTAssertEqual(cdProject.amount, 100)
        XCTAssertEqual(cdProject.id, project.id)

    }

    func testDeleteObject() throws {
        XCTAssertEqual(store.context.realCount(for: requestAll), 0, "Data store should be empty.")

        let expectation = expectation(description: String(describing: #function))
        let project = Project(name: "test", amount: 10, id: UUID())
        _ = store
            .insert(project)
            .flatMap(store.delete)
            .sink { _ in
            } receiveValue: { value in
                XCTAssertEqual(value, project)
                expectation.fulfill()
            }

        waitForExpectations(timeout: 2)

        XCTAssertEqual(store.context.realCount(for: requestAll), 0, "Data store should be empty.")
    }

    func testFetchObjects() {
        XCTAssertEqual(store.context.realCount(for: requestAll), 0, "Data store should be empty.")

        let expectation = expectation(description: String(describing: #function))
        let project = Project(name: "test", amount: 10, id: UUID())

        var projects = [Project]()
        _ = store.insert(project)
            .flatMap { _ in
                self.store.fetchAll()
            }
            .sink { _ in
            } receiveValue: { value in
                projects = value
                expectation.fulfill()
            }

        waitForExpectations(timeout: 2)

        XCTAssertEqual(store.context.realCount(for: requestAll), 1)
        XCTAssertEqual(projects, [project])
    }

    func testFetchObjects2() {
        XCTAssertEqual(store.context.realCount(for: requestAll), 0, "Data store should be empty.")

        let expectation = expectation(description: String(describing: #function))

        var projects = [Project]()
        _ = (0..<10).publisher
            .flatMap { i in
                self.store.insert(Project(name: "Test \(i)", amount: Double(i * 10), id: UUID()))
            }
            .collect()
            .eraseToAnyPublisher()
            .flatMap { _ in
                self.store.fetchAll()
            }
            .sink { _ in

            } receiveValue: { value in
                projects = value
                expectation.fulfill()
            }

        waitForExpectations(timeout: 2)

        XCTAssertEqual(store.context.realCount(for: requestAll), 10)
        XCTAssertEqual(projects.map(\.name), (0..<10).map { "Test \($0)" })
        XCTAssertEqual(projects.map(\.amount), (0..<10).map { Double($0 * 10) })
    }

}
