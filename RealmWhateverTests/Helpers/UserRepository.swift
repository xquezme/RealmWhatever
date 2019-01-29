//
//  UserRepository.swift
//  RealmWhateverTests
//
//  Created by Sergey Pimenov on 01/03/2018.
//  Copyright © 2018 Sergey Pimenov. All rights reserved.
//

import Foundation
import RealmWhatever
import RxSwift

enum QuerySpecification {
    case byUUID(uuid: UUID)
    case byAge(age: Int)
    case byAgeSortedByName(age: Int)
}

extension QuerySpecification: SpecificationType {
    var predicate: NSPredicate? {
        switch self {
        case let .byUUID(uuid):
            return NSPredicate(format: "uuid == %@", uuid.uuidString)
        case let .byAge(age):
            return NSPredicate(format: "age == %@", age as NSNumber)
        case let .byAgeSortedByName(age):
            return NSPredicate(format: "age == %@", age as NSNumber)
        }
    }

    var sortDescriptors: [NSSortDescriptor]? {
        switch self {
        case .byUUID:
            return nil
        case .byAge:
            return nil
        case .byAgeSortedByName:
            return [NSSortDescriptor(key: "name", ascending: true)]
        }
    }
}

final class UserRepository: RealmWhatever.Provider<QuerySpecification, RLMUser> {

}
