//
//  StoreMockTests.swift
//  
//
//  Created by Igor Malyarov on 04.03.2021.
//

import XCTest
import Combine
import Store

final class StoreMockTests: XCTestCase {
    var store: StoreMock!

    override func setUpWithError() throws {
        store = StoreMock()
    }

    func testInsertObject() {
        XCTAssert(store.projects.isEmpty)

        let expectation = expectation(description: String(describing: #function))
        let project = StoreMock.Project(name: "test")
        var result: StoreMock.Project?

        _ = store
            .insert(project)
            .sink { _ in
            } receiveValue: { value in
                result = value
                expectation.fulfill()
            }

        waitForExpectations(timeout: 2)

        XCTAssertNotNil(result)
        XCTAssertEqual(result, StoreMock.Project(name: "test"))
        XCTAssertEqual(store.projects.count, 1)
    }

    func testUpdateObject_failure() {
        XCTAssert(store.projects.isEmpty)

        let expectation = expectation(description: String(describing: #function))
        let project = StoreMock.Project(name: "test")

        _ = store
            .update(project)
            .sink { completion in
                switch completion {
                    case let .failure(error):
                        XCTAssertEqual(error as! StoreMock.TestError,
                                       StoreMock.TestError.objectNotFound)
                        expectation.fulfill()
                    case .finished:
                        XCTFail("Should not finish if updating non-existing object.")
                }
            } receiveValue: { value in
                XCTFail("Should not receive value if updating non-existing object.")
            }

        waitForExpectations(timeout: 2)

        XCTAssert(store.projects.isEmpty)
    }

    func testUpdateObject_success() {
        XCTAssert(store.projects.isEmpty)

        let expectation = expectation(description: String(describing: #function))
        let project = StoreMock.Project(name: "test")
        var result: StoreMock.Project?

        _ = store
            .insert(project)
            .flatMap { (project: StoreMock.Project) -> Future<StoreMock.Project, Error> in
                var copy = project
                copy.amount = 10
                return self.store.update(copy)
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
        XCTAssertEqual(store.projects.count, 1)
    }

    func testDeleteObject_failure() {
        XCTAssert(store.projects.isEmpty)

        let expectation = expectation(description: String(describing: #function))
        let project = StoreMock.Project(name: "test")

        _ = store
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

        XCTAssert(store.projects.isEmpty)
    }

    func testDeleteObject_success() {
        XCTAssert(store.projects.isEmpty)

        let expectation = expectation(description: String(describing: #function))
        let project = StoreMock.Project(name: "test")

        _ = store
            .insert(project)
            .flatMap { project in
                self.store.delete(project)
            }
            .sink { _ in
            } receiveValue: { value in
                XCTAssertEqual(value, StoreMock.Project(name: "test"))
                expectation.fulfill()
            }

        waitForExpectations(timeout: 2)

        XCTAssert(store.projects.isEmpty)
    }
}
