//
//  DogOwner.swift
//  Example
//
//  Created by Sergey Pimenov on 24.02.2020.
//  Copyright © 2020 Sergey Pimenov. All rights reserved.
//

import Foundation

struct DogOwner: Equatable {
    let uuid: UUID
    let name: String
    let dogs: [Dog]
}

extension DogOwner: Identifiable {
    typealias ID = UUID

    var id: UUID {
        return uuid
    }
}
