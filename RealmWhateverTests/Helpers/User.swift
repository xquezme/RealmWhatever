//
//  User.swift
//  RealmWhateverTests
//
//  Created by Sergey Pimenov on 01/03/2018.
//  Copyright © 2018 Sergey Pimenov. All rights reserved.
//

import Foundation

struct User: Hashable {
    let uuid: UUID
    let age: Int
    let name: String

    var hashValue: Int {
        return self.uuid.hashValue
    }
}
