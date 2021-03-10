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

    func test_func_predicate_name() {
        let predicate = Predicate<Project>.compare(\Project.name, operation: .equal, value: "Test")
        let sortOption = SortOption(property: \Project.name, order: .ascending)
        let query = Query<Project>(predicate: predicate, sortOptions: [sortOption])

        let nsPredicate = CDProject.predicate(from: query)
        XCTAssertEqual(nsPredicate, NSPredicate(format: "%K == %@", #keyPath(CDProject.name_), "Test"))

        let nsSortDescriptors = CDProject.sortDescriptors(from: query)
        let nsSortDescriptor = NSSortDescriptor(keyPath: \CDProject.name_, ascending: true)
        XCTAssertEqual(nsSortDescriptors, [nsSortDescriptor])
    }

    func test_func_predicate_amount() {
        let predicate = Predicate<Project>.compare(\Project.amount, operation: .equal, value: 2.0)
        let sortOption = SortOption(property: \Project.amount, order: .ascending)
        let query = Query<Project>(predicate: predicate, sortOptions: [sortOption])

        let nsPredicate = CDProject.predicate(from: query)
        let nsPredicate2 = NSPredicate(format: "%K == %@", #keyPath(CDProject.amount), NSNumber(floatLiteral: 2))
        XCTAssertEqual(nsPredicate, nsPredicate2)

        let nsSortDescriptors = CDProject.sortDescriptors(from: query)
        let nsSortDescriptor = NSSortDescriptor(keyPath: \CDProject.amount, ascending: true)
        XCTAssertEqual(nsSortDescriptors, [nsSortDescriptor])
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

        let predicate = Predicate<Project>.compare(\Project.name, operation: .notEqual, value: "")
        let sortOptions = [SortOption<Project>(property: \Project.name, order: .ascending)]
        let query = Query(predicate: predicate, sortOptions: sortOptions)

        var projects = [Project]()
        _ = store.insert(project)
            .flatMap { _ in
                self.store.fetch(query)
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

        let predicate = Predicate<Project>.compare(\Project.name, operation: .notEqual, value: "")
        let sortOptions = [SortOption<Project>(property: \Project.name, order: .ascending)]
        let query = Query(predicate: predicate, sortOptions: sortOptions)

        var projects = [Project]()
        _ = (0..<10).publisher
            .flatMap { i in
                self.store.insert(Project(name: "Test \(i)", amount: Double(i * 10), id: UUID()))
            }
            .collect()
            .eraseToAnyPublisher()
            .flatMap { _ in
                self.store.fetch(query)
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

    func testFetchObjects3() {
        XCTAssertEqual(store.context.realCount(for: requestAll), 0, "Data store should be empty.")

        let expectation = expectation(description: String(describing: #function))

        let predicate = Predicate<Project>.compare(\Project.name, operation: .equal, value: "Test 3")
        let sortOptions = [SortOption<Project>(property: \Project.name, order: .ascending)]
        let query = Query(predicate: predicate, sortOptions: sortOptions)

        var projects = [Project]()
        _ = (0..<10).publisher
            .flatMap { i in
                self.store.insert(Project(name: "Test \(i)", amount: Double(i * 10), id: UUID()))
            }
            .collect()
            .eraseToAnyPublisher()
            .flatMap { _ in
                self.store.fetch(query)
            }
            .sink { _ in

            } receiveValue: { value in
                projects = value
                expectation.fulfill()
            }

        waitForExpectations(timeout: 2)

        XCTAssertEqual(store.context.realCount(for: requestAll), 10)
        XCTAssertEqual(projects.map(\.name), ["Test 3"])
        XCTAssertEqual(projects.map(\.amount), [30.0])
    }
}
