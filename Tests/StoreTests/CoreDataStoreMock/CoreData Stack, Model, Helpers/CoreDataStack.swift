//
//  CoreDataStack.swift
//  
//
//  Created by Igor Malyarov on 05.03.2021.
//

import CoreData

class PersistentContainer: NSPersistentContainer {}

final class CoreDataStack {
    static let modelName = "Mock"

    static var model: NSManagedObjectModel = {
        //let bundle = Bundle(for: CoreDataStack.self)

        guard let url = Bundle.module.url(forResource: modelName, withExtension: "momd") else {
            fatalError("Can't find model file.")
        }

        guard let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Can't load model.")
        }

        return model
    }()

    private let container: PersistentContainer

    lazy var context: NSManagedObjectContext = {
        container.viewContext
    }()

    init(inMemory: Bool = false) {
        container = PersistentContainer(name: Self.modelName, managedObjectModel: Self.model)

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
