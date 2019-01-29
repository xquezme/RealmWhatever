//
//  DomainConvertibleFactory.swift
//  RealmWhatever
//
//  Created by Sergey Pimenov on 01/03/2018.
//  Copyright © 2018 Sergey Pimenov. All rights reserved.
//

import Foundation
import RealmSwift

public protocol DomainConvertibleFactoryType {
    associatedtype PersistenceModel: RealmSwift.Object
    associatedtype DomainModel: Hashable

    func createDomainModels(with persistenceModels: [PersistenceModel], realm: Realm) throws -> [DomainModel]
}

extension DomainConvertibleFactoryType {
    func createDomainModel(with persistenceModel: PersistenceModel, realm: Realm) throws -> DomainModel? {
        return try createDomainModels(with: [persistenceModel], realm: realm).first
    }
}
