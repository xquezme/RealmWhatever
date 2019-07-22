//
//  Specification.swift
//  RealmWhatever
//
//  Created by Sergey Pimenov on 01/03/2018.
//  Copyright © 2018 Sergey Pimenov. All rights reserved.
//

import Foundation
import RealmSwift

public protocol SpecificationType {
    var predicate: NSPredicate? { get }
    var sortDescriptors: [NSSortDescriptor]? { get }
}

public extension SpecificationType {
    var predicate: NSPredicate? {
        return nil
    }

    var sortDescriptors: [NSSortDescriptor]? {
        return nil
    }
}
