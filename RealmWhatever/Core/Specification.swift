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
    func predicate() -> NSPredicate?
    func sortDescriptor() -> NSSortDescriptor?
}

public extension SpecificationType {
    public func predicate() -> NSPredicate? {
        return nil
    }

    public func sortDescriptor() -> NSSortDescriptor? {
        return nil
    }
}
