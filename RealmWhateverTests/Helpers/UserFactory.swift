//
//  UserFactory.swift
//  RealmWhateverTests
//
//  Created by Sergey Pimenov on 01/03/2018.
//  Copyright © 2018 Sergey Pimenov. All rights reserved.
//

import Foundation
import RealmWhatever

final class UserFactory: DomainConvertibleFactoryType {
    typealias PersistenceModel = RLMUser
    typealias DomainModel = User

    static func createDomainModel(withPersistenceModel persistenceModel: RLMUser) -> User? {
        guard let uuid = UUID(uuidString: persistenceModel.uuid) else { return nil }

        return User(uuid: uuid)
    }
}
