//
//  NSManagedObjectContext+Ext.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 03.12.2020.
//

import Foundation
import CoreData
import Combine

public extension NSManagedObjectContext {
        
    //  MARK: - Real Count: non-optional count
    
    /// count func without optionality
    func realCount<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? count(for: fetchRequest)) ?? 0
    }
    
    
    //  MARK: - Save Context
    
    /// Only save if there are changes
    func saveContext() {
        guard hasChanges else { return }
        
        do {
            try self.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            /*fatalError*/ print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

}

