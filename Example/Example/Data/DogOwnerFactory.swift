//
//  DogOwnerFactory.swift
//  Example
//
//  Created by Sergey Pimenov on 24.02.2020.
//  Copyright © 2020 Sergey Pimenov. All rights reserved.
//

import Foundation
import RealmSwift
import RealmWhatever

final class DogOwnerFactory: DomainConvertibleFactoryType {
    typealias PersistenceModel = RLMDogOwner
    typealias DomainModel = DogOwner

    func createDomainModels(with persistenceModels: [RLMDogOwner], realm _: Realm) throws -> [DogOwner] {
        return persistenceModels.map {
            DogOwner(
                uuid: UUID(uuidString: $0.uuid)!,
                name: $0.name,
                dogs: $0.doggos.map {
                    Dog(
                        uuid: UUID(uuidString: $0.uuid)!,
                        name: $0.name
                    )
                }
            )
        }
    }
}
