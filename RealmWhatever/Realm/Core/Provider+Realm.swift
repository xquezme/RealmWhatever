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
    public func query(_ specification: Specification, cursor: Cursor = .default) throws -> [DomainModel] {
        let realm = try Realm()

        let realmObjects = realm.objects(PersistenceModel.self).apply(specification)

        return try Factory.createDomainModels(
            with: realmObjects.apply(cursor),
            realm: realm
        )
    }

    public func queryOne(_ specification: Specification, pinPolicy: PinPolicy = .beginning) throws -> DomainModel? {
        let realm = try Realm()

        let realmObjects = realm.objects(PersistenceModel.self).apply(specification)

        let realmObject = realmObjects.elementWithPolicy(pinPolicy: pinPolicy)

        return try realmObject.flatMap { realmObject in
            try Factory.createDomainModel(with: realmObject, realm: realm)
        }
    }

    public func count(_ specification: Specification) throws -> Int {
        let realm = try Realm()

        let realmObjects = realm.objects(PersistenceModel.self).apply(specification)

        return realmObjects.count
    }
}
