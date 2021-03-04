//
//  StoreTests.swift
//  
//
//  Created by Igor Malyarov on 04.03.2021.
//

import XCTest
import Combine
@testable import Store

final class StoreTests: XCTestCase {
    class StoreMock: Store {
        typealias Object = Project

        struct Project: Identifiable, Equatable {
            let name: String
            var amount = 0
            var id: String { name }
        }

        private(set) var projects: [Project] = []

        func insert(_ object: Project) -> Future<Project, Error> {
            Future { completion in
                self.projects.append(object)
                completion(.success(object))
            }
        }

        func update(_ object: Project) -> Future<Project, Error> {
            Future { [self] completion in
                guard let index = projects.firstIndex(where: { $0.id == object.id }) else {
                    return completion(.failure(TestError.objectNotFound))
                }
                projects[index] = object
                completion(.success(object))
            }
        }

        func delete(_ object: Project) -> Future<Project, Error> {
            Future { [self] completion in
                guard let index = projects.firstIndex(where: { $0.id == object.id }) else {
                    return completion(.failure(TestError.objectNotFound))
                }
                projects.remove(at: index)
                completion(.success(object))
            }
        }

        enum TestError: String, Error { case objectNotFound}
    }

    var storeMock: StoreMock!

    override func setUpWithError() throws {
        storeMock = StoreMock()
    }

    func testInsertObject() {
        XCTAssert(storeMock.projects.isEmpty)

        let expectation = expectation(description: String(describing: #function))
        let project = StoreMock.Project(name: "test")
        var result: StoreMock.Project?

        _ = storeMock
            .insert(project)
            .sink { _ in
            } receiveValue: { value in
                result = value
                expectation.fulfill()
            }

        waitForExpectations(timeout: 2)

        XCTAssertNotNil(result)
        XCTAssertEqual(result, StoreMock.Project(name: "test"))
        XCTAssertEqual(storeMock.projects.count, 1)
    }

    func testUpdateObject_failure() {
        XCTAssert(storeMock.projects.isEmpty)

        let expectation = expectation(description: String(describing: #function))
        let project = StoreMock.Project(name: "test")

        _ = storeMock
            .update(project)
            .sink { completion in
                switch completion {
                    case let .failure(error):
                        XCTAssertEqual(error as! StoreTests.StoreMock.TestError,
                                       StoreMock.TestError.objectNotFound)
                        expectation.fulfill()
                    case .finished:
                        XCTFail("Should not finish if updating non-existing object.")
                }
            } receiveValue: { value in
                XCTFail("Should not receive value if updating non-existing object.")
            }

        waitForExpectations(timeout: 2)

        XCTAssert(storeMock.projects.isEmpty)
    }

    func testUpdateObject_success() {
        XCTAssert(storeMock.projects.isEmpty)

        let expectation = expectation(description: String(describing: #function))
        let project = StoreMock.Project(name: "test")
        var result: StoreMock.Project?

        _ = storeMock
            .insert(project)
            .flatMap { (project: StoreMock.Project) -> Future<StoreMock.Project, Error> in
                var copy = project
                copy.amount = 10
                return self.storeMock.update(copy)
            }
            .sink { completion in
                switch completion {
                    case .failure(_):
                        XCTFail("Should not fail.")
                    case .finished:
                        expectation.fulfill()
                }
            } receiveValue: { value in
                result = value
            }

        waitForExpectations(timeout: 2)

        XCTAssertNotNil(result)
        XCTAssertEqual(result, StoreMock.Project(name: "test", amount: 10))
        XCTAssertEqual(storeMock.projects.count, 1)
    }

    func testDeleteObject_failure() {
        XCTAssert(storeMock.projects.isEmpty)

        let expectation = expectation(description: String(describing: #function))
        let project = StoreMock.Project(name: "test")

        _ = storeMock
            .delete(project)
            .sink { completion in
                switch completion {
                    case .failure(_):
                        expectation.fulfill()
                    case .finished:
                        XCTFail("Should not finish if deleting non-existing object.")
                }
            } receiveValue: { value in
                XCTFail("Should not receive value if deleting non-existing object.")
            }

        waitForExpectations(timeout: 2)

        XCTAssert(storeMock.projects.isEmpty)
    }

    func testDeleteObject_success() {
        XCTAssert(storeMock.projects.isEmpty)

        let expectation = expectation(description: String(describing: #function))
        let project = StoreMock.Project(name: "test")

        _ = storeMock
            .insert(project)
            .flatMap { project in
                self.storeMock.delete(project)
            }
            .sink { _ in
            } receiveValue: { value in
                XCTAssertEqual(value, StoreMock.Project(name: "test"))
                expectation.fulfill()
            }

        waitForExpectations(timeout: 2)

        XCTAssert(storeMock.projects.isEmpty)
    }
}
