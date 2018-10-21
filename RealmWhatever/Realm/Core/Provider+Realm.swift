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
    public func query(_ specification: Specification) throws -> [DomainModel] {
        let realm = try Realm()

        let realmObjects = realm.objects(PersistenceModel.self).apply(specification)

        return try realmObjects.map { realmObject in
            try Factory.createDomainModel(withPersistenceModel: realmObject, realm: realm)
        }
    }

    public func queryOne(_ specification: Specification, policy: QueryOnePolicy = .last) throws -> DomainModel? {
        let realm = try Realm()

        let realmObjects = realm.objects(PersistenceModel.self).apply(specification)

        return try realmObjects.elementWithPolicy(policy: policy).flatMap { realmObject in
            try Factory.createDomainModel(withPersistenceModel: realmObject, realm: realm)
        }
    }

    public func count(_ specification: Specification) throws -> Int {
        let realm = try Realm()

        let realmObjects = realm.objects(PersistenceModel.self).apply(specification)

        return realmObjects.count
    }
}
