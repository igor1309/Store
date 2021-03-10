//
//  CoreDataStoreMock.swift
//  
//
//  Created by Igor Malyarov on 05.03.2021.
//

import Combine
import CoreData
import Store

class CoreDataStoreMock: CoreDataStore<Project, CDProject> {}

extension Project: CoreDataStorable {
    public typealias Reflection = CDProject

    #warning("write tests for this")
    public func reflection(in context: NSManagedObjectContext) -> CDProject? {
        // let predicate = NSPredicate(format: "%K == %@", argumentArray: [\CDProject.uuid_, id])
        let predicate = NSPredicate(format: "%K == %@", #keyPath(CDProject.uuid_), self.id as CVarArg)
        let request = CDProject.fetchRequest(predicate)
        do {
            let results = try context.fetch(request)
            return results.first
        } catch {
            #warning("change to Result type and return error .objectNotFound")
            return nil
        }
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

extension CDProject: CoreDataManageable {
    public typealias Object = Project

    public func update(with object: Project) {
        name = object.name
        amount = object.amount
        id = object.id
    }

    public func object() -> Project {
        Project(name: name, amount: amount, id: id)
    }

}
