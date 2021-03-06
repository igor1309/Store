//
//  Project.swift
//  
//
//  Created by Igor Malyarov on 05.03.2021.
//

import Foundation

public struct Project: Identifiable, Equatable {
    let name: String
    var amount: Double
    public let id: UUID
}
