//
//  StoreMock.swift
//  
//
//  Created by Igor Malyarov on 05.03.2021.
//

import Combine
import Store

class StoreMock: Store {
    typealias Object = Project    

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

    func fetch(_ query: Query<Project>) -> Future<[Project], Error> {
        #warning("finish this")
        return Future { completion in
            completion(.success(self.projects))
        }
    }

    enum TestError: String, Error { case objectNotFound}
}

