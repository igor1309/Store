//
//  Project.swift
//  
//
//  Created by Igor Malyarov on 05.03.2021.
//

import Foundation

struct Project: Identifiable, Equatable {
    let name: String
    var amount: Double
    let id: UUID
}
