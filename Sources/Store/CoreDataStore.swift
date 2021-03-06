//
//  CoreDataStore.swift
//  
//
//  Created by Igor Malyarov on 05.03.2021.
//

import Combine
import CoreData

public protocol CoreDataStorable {
    associatedtype Reflection

    /// Method `reflection` provides a way to identify and return the underlying object (reflection),
    /// that is used to persist the original CoreDataStorable object.
    func reflection(in context: NSManagedObjectContext) -> Reflection?
}

public protocol CoreDataManageable: NSManagedObject {
    associatedtype Object

    /// A bridge, or map, from properties of Object to properties of CoreDataManageable.
    func update(with object: Object)
    /// A method to `transform` CoreDataManageable to Object.
    /// In other words, a way to create Object from CoreDataManageable.
    func transform() -> Object
}

open class CoreDataStore<Object: CoreDataStorable,
                         Reflection: CoreDataManageable>: Store where Object.Reflection == Reflection,
                                                                      Reflection.Object == Object {
    let context: NSManagedObjectContext

    public init(context: NSManagedObjectContext) {
        self.context = context
    }

    public func insert(_ object: Object) -> Future<Object, Error> {
        Future { completion in
            let reflection = Reflection(context: self.context)
//            guard let r = NSEntityDescription.insertNewObject(forEntityName: String(describing: Reflection.self), into: self.context) else { return completion(.failure(CoreDataError.invalidManagedObjectType)) }
            reflection.update(with: object)

            do {
                try self.context.save()
                return completion(.success(object))
            } catch {
                return completion(.failure(error))
            }
        }
    }

    enum CoreDataError: Error { case noObject }

    public func update(_ object: Object) -> Future<Object, Error> {
        Future { completion in
            guard let reflection = object.reflection(in: self.context) else {
                return completion(.failure(CoreDataError.noObject))
            }

            reflection.update(with: object)

            do {
                try self.context.save()
                return completion(.success(object))
            } catch {
                return completion(.failure(error))
            }
        }
    }

    public func delete(_ object: Object) -> Future<Object, Error> {
        Future { completion in
            guard let reflection = object.reflection(in: self.context) else {
                return completion(.failure(CoreDataError.noObject))
            }

            self.context.delete(reflection)

            do {
                try self.context.save()
                return completion(.success(object))
            } catch {
                return completion(.failure(error))
            }
        }
    }

    public func fetch(_ query: Query) -> Future<[Object], Error> {
        Future { completion in
            do {
                let results: [Reflection] = try self.context.fetch(query)
                let objects = results.map { $0.transform() }
                completion(.success(objects))
            } catch {
                completion(.failure(error))
            }
        }
    }

}

extension NSManagedObjectContext {
    func fetch<T: NSManagedObject>(_ query: Query<T>) throws -> [T] {
        let fetchRequest: NSFetchRequest<T> = NSFetchRequest<T>(entityName: T.description())
        fetchRequest.predicate = query.nsPredicate
        fetchRequest.sortDescriptors = query.sortDescriptors
        return try fetch(fetchRequest)
    }
}
