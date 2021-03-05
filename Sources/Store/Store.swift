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
    func fetch(_ query: Query) -> Future<[Object], Error>
}

public struct Query {}
