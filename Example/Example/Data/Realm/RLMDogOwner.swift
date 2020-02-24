//
//  RLMDogOwner.swift
//  Example
//
//  Created by Sergey Pimenov on 24.02.2020.
//  Copyright © 2020 Sergey Pimenov. All rights reserved.
//

import Foundation
import RealmSwift

class RLMDogOwner: Object {
    @objc dynamic var uuid: String!
    @objc dynamic var name: String!

    var doggos = List<RLMDog>()

    override static func primaryKey() -> String? {
        return "uuid"
    }
}
