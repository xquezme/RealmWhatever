//
//  Provider.swift
//  RealmWhatever
//
//  Created by Sergey Pimenov on 01/03/2018.
//  Copyright © 2018 Sergey Pimenov. All rights reserved.
//

import Foundation
import RealmSwift

open class Provider<Specification: SpecificationType, PersistenceModel: RealmSwift.Object>: ProviderType {
    public init() {}
}
