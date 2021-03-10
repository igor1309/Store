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

    #warning("write tests for this")
    public static func predicate(from query: Query<Project>) -> NSPredicate {
        switch query.predicate {
            case let .compare(keyPath, operation: operation, value: value):
                switch keyPath {
                    case \Project.name:
                        // let keyPath = \CDProject.name_
                        // return NSPredicate(format: "%K \(operation.rawValue) %@", keyPath as! CVarArg, value)
                        // return NSPredicate(format: "%K \(operation.rawValue) %@", argumentArray: [keyPath, value])
                        return NSPredicate(format: "%K \(operation.rawValue) %@", #keyPath(CDProject.name_), value)
                    case \Project.amount:
                        // let keyPath = \CDProject.amount
                        // return NSPredicate(format: "%K \(operation.rawValue) %@", argumentArray: [keyPath, value])
                        return NSPredicate(format: "%K \(operation.rawValue) %@", #keyPath(CDProject.amount), NSNumber(floatLiteral: value as! Double))
                    default:
                        return .all
                }
            case .all: return NSPredicate.all
        }
    }

    #warning("write tests for this")
    /// Any time you’re sorting user-facing strings, be sure to pass the selector localizedStandardCompare:, which will sort according to the language rules of the current locale (locales may differ on ordering of case, diacritics, and so forth).
    /// https://nshipster.com/nssortdescriptor/
    public static func sortDescriptors(from query: Query<Project>) -> [NSSortDescriptor] {
        query.sortOptions.compactMap {
            let order = $0.order == .ascending

            switch $0.property {
                case \Project.name:
                    let keyPath = \CDProject.name_
                    return NSSortDescriptor(keyPath: keyPath, ascending: order)
                case \Project.amount:
                    let keyPath = \CDProject.amount
                    return NSSortDescriptor(keyPath: keyPath, ascending: order)
                default:
                    return nil
            }
        }
    }

}
