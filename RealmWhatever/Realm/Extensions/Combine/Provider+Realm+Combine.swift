//
//  Provider+Realm+Combine.swift
//  RealmWhatever
//
//  Created by Sergey Pimenov on 24.02.2020.
//  Copyright © 2020 Sergey Pimenov. All rights reserved.
//

import Combine
import Foundation
import RealmSwift

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Provider: CombineExtensionsProvider {}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Combine where Base: ProviderType {
    func query<F: DomainConvertibleFactoryType>(
        _ specification: Base.Specification,
        cursor: Cursor = .default,
        factory: F,
        realmConfiguration: Realm.Configuration = .defaultConfiguration
    ) throws -> CombineQueryObservableObject<F> where F.PersistenceModel == Base.PersistenceModel {
        let object = try CombineQueryObservableObject<F>(
            specification: specification,
            factory: factory,
            cursor: cursor,
            realmConfiguration: realmConfiguration
        )

        return object
    }

    func queryOne<F: DomainConvertibleFactoryType>(
        _ specification: Base.Specification,
        pinPolicy: PinPolicy = .beginning,
        factory: F,
        realmConfiguration: Realm.Configuration = .defaultConfiguration
    ) throws -> CombineQueryOneObservableObject<F> where F.PersistenceModel == Base.PersistenceModel {
        let object = try CombineQueryOneObservableObject<F>(
            specification: specification,
            factory: factory,
            pinPolicy: pinPolicy,
            realmConfiguration: realmConfiguration
        )

        return object
    }

    func count(
        _ specification: Base.Specification,
        realmConfiguration: Realm.Configuration = .defaultConfiguration
    ) throws -> CombineCountObservableObject<Base.PersistenceModel> {
        let object = try CombineCountObservableObject<Base.PersistenceModel>(
            specification: specification,
            realmConfiguration: realmConfiguration
        )

        return object
    }
}
