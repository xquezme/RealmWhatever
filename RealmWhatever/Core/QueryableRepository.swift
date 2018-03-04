//
//  QueryableRepository.swift
//  RealmWhatever
//
//  Created by Sergey Pimenov on 01/03/2018.
//  Copyright © 2018 Sergey Pimenov. All rights reserved.
//

import Foundation
import RealmSwift

public protocol QueryableRepositoryType: class {
    associatedtype QuerySpecification: QueryableSpecificationType
    associatedtype PersistenceModel
    associatedtype DomainModel
    associatedtype Factory: DomainConvertibleFactoryType
        where
            Factory.PersistenceModel == Self.PersistenceModel,
            Factory.DomainModel == Self.DomainModel
}

open class QueryableRepository<
    QuerySpecification_: QueryableSpecificationType,
    Factory_: DomainConvertibleFactoryType
>: QueryableRepositoryType {
    public typealias QuerySpecification = QuerySpecification_
    public typealias Factory = Factory_
    public typealias PersistenceModel = Factory.PersistenceModel
    public typealias DomainModel = Factory.DomainModel

    public init() {}
}
