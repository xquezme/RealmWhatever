//
//  Provider+Realm.swift
//  RealmWhatever
//
//  Created by Sergey Pimenov on 04/03/2018.
//  Copyright © 2018 Sergey Pimenov. All rights reserved.
//

import Foundation
import RealmSwift

public extension ProviderType where PersistenceModel: RealmSwift.Object {
    public func query(_ specification: Specification) -> [DomainModel] {
        let realm = try! Realm()

        let realmObjects = realm.objects(PersistenceModel.self).apply(specification)

        return realmObjects.flatMap {
            Factory.createDomainModel(withPersistenceModel: $0)
        }
    }

    public func queryOne(_ specification: Specification) -> DomainModel? {
        let realm = try! Realm()

        let realmObjects = realm.objects(PersistenceModel.self).apply(specification)

        return Factory.createDomainModel(withPersistenceModel: realmObjects.first)
    }

    public func count(_ specification: Specification) -> Int {
        let realm = try! Realm()

        let objects = realm.objects(PersistenceModel.self).apply(specification)

        return objects.count
    }
}
