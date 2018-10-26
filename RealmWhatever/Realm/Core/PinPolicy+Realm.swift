//
//  PinPolicy+Realm.swift
//  RealmWhatever
//
//  Created by Sergey Pimenov on 26/10/2018.
//  Copyright © 2018 Sergey Pimenov. All rights reserved.
//

import Foundation
import RealmSwift

extension Results {
    func elementWithPolicy(pinPolicy: PinPolicy) -> Element? {
        switch pinPolicy {
        case .beginning:
            return self.first
        case .end:
            return self.last
        }
    }
}
