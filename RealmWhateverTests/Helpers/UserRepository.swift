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
}

extension QuerySpecification: QueryableSpecificationType {
    func predicate() -> NSPredicate? {
        switch self {
        case .byUUID(let uuid):
            return NSPredicate(format: "uuid == %@", uuid.uuidString)
        }
    }
}

final class UserRepository: RealmWhatever.QueryableRepository<QuerySpecification, UserFactory> {

}
