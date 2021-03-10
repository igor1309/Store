//
//  Query.swift
//  
//
//  Created by Igor Malyarov on 10.03.2021.
//

import Foundation

public struct Query<T> {
    public let predicate: Predicate<T>
    /// Any time you’re sorting user-facing strings, be sure to pass the selector localizedStandardCompare:, which will sort according to the language rules of the current locale (locales may differ on ordering of case, diacritics, and so forth).
    /// https://nshipster.com/nssortdescriptor/
    public let sortOptions: [SortOption<T>]
}

public enum Predicate<T> {
    case compare(PartialKeyPath<T>, operation: Operation, value: Primitive)
    case all
}

public enum Operation: String {
    case equal = "=="
    case notEqual = "!="
}

public struct SortOption<T> {
    public let property: PartialKeyPath<T>
    public let order: Order

    public enum Order {
        case ascending
        case descending
    }
}

public protocol Primitive: CVarArg {}
extension String: Primitive {}
extension Double: Primitive {}
