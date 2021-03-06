//
//  Store.swift
//  
//
//  Created by Igor Malyarov on 04.03.2021.
//

import Combine

public protocol Store {
    associatedtype Object

    func insert(_ object: Object) -> Future<Object, Error>
    func update(_ object: Object) -> Future<Object, Error>
    func delete(_ object: Object) -> Future<Object, Error>
    func fetch(_ query: Query<Object>) -> Future<[Object], Error>
}


import CoreData

public struct Query<T> {
    let predicate: Predicate<T>

    #warning("finish this")
    public var nsPredicate: NSPredicate


}
extension Query {
    #warning("finish this")
    var sortDescriptors: [NSSortDescriptor] {
        []
    }
}

enum Predicate<T> {
    case comparison(PartialKeyPath<T>, Operator, Primitive)
}

enum Operator {
    case lessThan
}
// https://gist.github.com/ftchirou/989f9cc8293ea5a0e72200fae51ae5af
protocol Primitive {}

