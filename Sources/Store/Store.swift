//
//  Store.swift
//  
//
//  Created by Igor Malyarov on 04.03.2021.
//

import Combine

protocol Store {
    associatedtype Object

    func insert(_ object: Object) -> Future<Object, Error>
    func update(_ object: Object) -> Future<Object, Error>
    func delete(_ object: Object) -> Future<Object, Error>
}
