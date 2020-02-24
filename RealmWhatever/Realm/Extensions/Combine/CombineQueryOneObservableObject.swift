//
//  CombineQueryOneObservableObject.swift
//  RealmWhatever
//
//  Created by Sergey Pimenov on 24.02.2020.
//  Copyright © 2020 Sergey Pimenov. All rights reserved.
//

import Combine
import Foundation
import RealmSwift

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public final class CombineQueryOneObservableObject<F: DomainConvertibleFactoryType>: ObservableObject {
    @Published public var object: F.DomainModel? = nil

    private let specification: SpecificationType
    private let factory: F
    private let pinPolicy: PinPolicy
    private let realmConfiguration: Realm.Configuration

    private var token: NotificationToken?

    init(
        specification: SpecificationType,
        factory: F,
        pinPolicy: PinPolicy = .beginning,
        realmConfiguration: Realm.Configuration = .defaultConfiguration
    ) throws {
        self.specification = specification
        self.factory = factory
        self.pinPolicy = pinPolicy
        self.realmConfiguration = realmConfiguration

        let realm = try Realm(configuration: realmConfiguration)

        let realmObjects = realm.objects(F.PersistenceModel.self).apply(specification)

        self.object = try realmObjects.elementWithPolicy(pinPolicy: pinPolicy).flatMap {
            try factory.createDomainModel(
                with: $0,
                realm: realm
            )
        }

        self.startObserving()
    }

    private func startObserving() {
        RealmNotificationThreadWrapper.shared.runAsync { [weak self] in
            guard let self = self else { return }

            do {
                let realm = try Realm(configuration: self.realmConfiguration)
                let objects = realm.objects(F.PersistenceModel.self).apply(self.specification)

                self.token = objects.observe { [weak self] changeset in
                    guard let self = self else { return }

                    let realmObjects: Results<F.PersistenceModel>

                    switch changeset {
                    case let .initial(latestValue):
                        realmObjects = latestValue
                    case let .update(latestValue, _, _, _):
                        realmObjects = latestValue
                    case let .error(error):
                        self.token?.invalidate()
                        print(error)
                        return
                    }

                    do {
                        let domainObject: F.DomainModel? = try realmObjects.elementWithPolicy(pinPolicy: self.pinPolicy).flatMap {
                            try self.factory.createDomainModel(
                                with: $0,
                                realm: realm
                            )
                        }

                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }

                            if self.object != domainObject {
                                self.object = domainObject
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
            } catch {
                print(error)
            }
        }
    }

    deinit {
        self.token?.invalidate()
    }
}
