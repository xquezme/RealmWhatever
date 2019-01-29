//
//  ProviderType.swift
//  RealmWhatever
//
//  Created by Unison on 29/01/2019.
//  Copyright © 2019 Sergey Pimenov. All rights reserved.
//

import Foundation
import RealmSwift

public protocol ProviderType: class {
    associatedtype Specification: SpecificationType
    associatedtype PersistenceModel: RealmSwift.Object
}
