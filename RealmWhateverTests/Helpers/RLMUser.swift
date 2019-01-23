//
//  RLMUser.swift
//  RealmWhateverTests
//
//  Created by Sergey Pimenov on 01/03/2018.
//  Copyright © 2018 Sergey Pimenov. All rights reserved.
//

import Foundation
import RealmSwift
@testable import RealmWhatever

class RLMUser: Object {
    @objc dynamic var uuid: String!
    @objc dynamic var age: Int = 0
    @objc dynamic var name: String!

    override class func primaryKey() -> String? {
        return "uuid"
    }
}
