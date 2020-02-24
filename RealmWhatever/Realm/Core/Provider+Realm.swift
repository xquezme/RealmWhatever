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
    func query<F: DomainConvertibleFactoryType>(
        _ specification: Specification,
        cursor: Cursor = .default,
        factory: F,
        realmConfiguration: Realm.Configuration = .defaultConfiguration
    ) throws -> [F.DomainModel] where F.PersistenceModel == PersistenceModel {
        let realm = try Realm(configuration: realmConfiguration)

        let realmObjects = realm.objects(F.PersistenceModel.self).apply(specification)

        return try factory.createDomainModels(
            with: realmObjects.apply(cursor),
            realm: realm
        )
    }

    func queryOne<F: DomainConvertibleFactoryType>(
        _ specification: Specification,
        pinPolicy: PinPolicy = .beginning,
        factory: F,
        realmConfiguration: Realm.Configuration = .defaultConfiguration
    ) throws -> F.DomainModel? where F.PersistenceModel == PersistenceModel {
        let realm = try Realm(configuration: realmConfiguration)

        let realmObjects = realm.objects(F.PersistenceModel.self).apply(specification)

        let realmObject = realmObjects.elementWithPolicy(pinPolicy: pinPolicy)

        return try realmObject.flatMap { realmObject in
            try factory.createDomainModel(with: realmObject, realm: realm)
        }
    }

    func count(
        _ specification: Specification,
        realmConfiguration: Realm.Configuration = .defaultConfiguration
    ) throws -> Int {
        let realm = try Realm(configuration: realmConfiguration)

        let realmObjects = realm.objects(PersistenceModel.self).apply(specification)

        return realmObjects.count
    }
}
