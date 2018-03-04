//
//  DomainConvertibleFactory.swift
//  RealmWhatever
//
//  Created by Sergey Pimenov on 01/03/2018.
//  Copyright © 2018 Sergey Pimenov. All rights reserved.
//

import Foundation

public protocol DomainConvertibleFactoryType: AnyObject {
    associatedtype PersistenceModel
    associatedtype DomainModel: Hashable
    static func createDomainModel(withPersistenceModel persistenceModel: PersistenceModel) -> DomainModel?
}

extension DomainConvertibleFactoryType {
    static func createDomainModel(withPersistenceModel persistenceModel: PersistenceModel?) -> DomainModel? {
        guard let persistenceModel = persistenceModel else { return nil }
        return createDomainModel(withPersistenceModel: persistenceModel)
    }
}
