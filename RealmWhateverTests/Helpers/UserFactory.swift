//
//  UserFactory.swift
//  RealmWhateverTests
//
//  Created by Sergey Pimenov on 01/03/2018.
//  Copyright © 2018 Sergey Pimenov. All rights reserved.
//

import Foundation
import RealmWhatever
import RealmSwift

enum TransformError: Swift.Error {
    case uuidNotConvertible(uuid: String)
}

final class UserFactory: DomainConvertibleFactoryType {
    typealias PersistenceModel = RLMUser
    typealias DomainModel = User

    func createDomainModels(with persistenceModels: [RLMUser], realm: Realm) throws -> [User] {
        return try persistenceModels.compactMap { persistenceModel in
            guard let uuid = UUID(uuidString: persistenceModel.uuid) else {
                throw TransformError.uuidNotConvertible(uuid: persistenceModel.uuid)
            }

            return User(uuid: uuid, age: persistenceModel.age, name: persistenceModel.name)
        }
    }
}
