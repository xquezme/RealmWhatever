//
//  Provider.swift
//  RealmWhatever
//
//  Created by Sergey Pimenov on 01/03/2018.
//  Copyright © 2018 Sergey Pimenov. All rights reserved.
//

import Foundation
import RealmSwift

public enum QueryOnePolicy {
    case first
    case last
}

public protocol ProviderType: class {
    associatedtype Specification: SpecificationType
    associatedtype PersistenceModel
    associatedtype DomainModel
    associatedtype Factory: DomainConvertibleFactoryType
        where
            Factory.PersistenceModel == Self.PersistenceModel,
            Factory.DomainModel == Self.DomainModel
}

open class Provider<
    Specification_: SpecificationType,
    Factory_: DomainConvertibleFactoryType
>: ProviderType {
    public typealias Specification = Specification_
    public typealias Factory = Factory_
    public typealias PersistenceModel = Factory.PersistenceModel
    public typealias DomainModel = Factory.DomainModel

    public init() {}
}
