//
//  fetchRequest.swift
//
//
//  Created by Igor Malyarov on 21.12.2020.
//

import CoreData

extension CDProject {
    static func fetchRequest(_ predicate: NSPredicate) -> NSFetchRequest<CDProject> {
        let sortDescriptorName = NSSortDescriptor(key: #keyPath(CDProject.name_), ascending: true)
        return fetchRequest(predicate, sortDescriptors: [sortDescriptorName])
    }

    static func fetchRequest(_ predicate: NSPredicate, sortDescriptors: [NSSortDescriptor]) -> NSFetchRequest<CDProject> {
        let request = NSFetchRequest<CDProject>(entityName: "CDProject")
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        return request
    }
}
