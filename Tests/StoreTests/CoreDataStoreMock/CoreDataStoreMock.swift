//
//  CoreDataStoreMock.swift
//  
//
//  Created by Igor Malyarov on 05.03.2021.
//

import Combine
import CoreData
import Store

extension Query {
    #warning("finish this")
    var sortDescriptors: [NSSortDescriptor] {
        []
    }
}

extension CDProject {
    var name: String {
        get { name_ ?? "" }
        set { name_ = newValue }
    }
    public var id: UUID {
        get { uuid_ ?? UUID() }
        set { uuid_ = newValue }
    }
}

class CoreDataStoreMock: Store {
    typealias Object = Project

    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func insert(_ object: Project) -> Future<Project, Error> {
        Future { completion in
            let project = CDProject(context: self.context)
            project.name = object.name
            project.amount = object.amount
            project.id = object.id

            do {
                try self.context.save()
                completion(.success(object))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func update(_ object: Project) -> Future<Project, Error> {
        Future { completion in
            guard let project: CDProject = {
                let predicate = NSPredicate(format: "%K == %@", #keyPath(CDProject.uuid_), object.id as CVarArg)
                let request = CDProject.fetchRequest(predicate)
                do {
                    let results = try self.context.fetch(request)
                    return results.first
                } catch {
                    return nil
                }
            }() else {
                return completion(.failure(CoreDataError.noObject))
            }

            project.name = object.name
            project.amount = object.amount            

            do {
                try self.context.save()
                completion(.success(object))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func delete(_ object: Project) -> Future<Project, Error> {
        Future { completion in
            guard let project: CDProject = {
                let predicate = NSPredicate(format: "%K == %@", #keyPath(CDProject.uuid_), object.id as CVarArg)
                let request = CDProject.fetchRequest(predicate)
                do {
                    let results = try self.context.fetch(request)
                    return results.first
                } catch {
                    return nil
                }
            }() else {
                return completion(.failure(CoreDataError.noObject))
            }

            self.context.delete(project)

            do {
                try self.context.save()
                completion(.success(object))
            } catch {
                completion(.failure(error))
            }
        }
    }

    enum CoreDataError: Error { case fetchFailure, noObject }

    func fetch(_ query: Query) -> Future<[Project], Error> {
        Future { completion in
            do {
                let request = CDProject.fetchRequest(query.predicate, sortDescriptors: query.sortDescriptors)
                let fetchResults = try self.context.fetch(request)
                let projects: [Project] = fetchResults.map { (cdProject: CDProject) -> Project in
                    Project(name: cdProject.name,
                            amount: cdProject.amount,
                            id: cdProject.id)
                }
                completion(.success(projects))
            } catch {
                completion(.failure(error))
            }
        }
    }

}
