//
//  CombineQueryObservableObject.swift
//  RealmWhatever
//
//  Created by Sergey Pimenov on 24.02.2020.
//  Copyright © 2020 Sergey Pimenov. All rights reserved.
//

import Combine
import Foundation
import RealmSwift

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public final class CombineQueryObservableObject<F: DomainConvertibleFactoryType>: ObservableObject {
    @Published public var objects: [F.DomainModel] = []

    private let specification: SpecificationType
    private let factory: F
    private let cursor: Cursor
    private let realmConfiguration: Realm.Configuration

    private var token: NotificationToken?

    init(
        specification: SpecificationType,
        factory: F,
        cursor: Cursor = .default,
        realmConfiguration: Realm.Configuration = .defaultConfiguration
    ) throws {
        self.specification = specification
        self.factory = factory
        self.cursor = cursor
        self.realmConfiguration = realmConfiguration

        let realm = try Realm(configuration: realmConfiguration)

        let realmObjects = realm.objects(F.PersistenceModel.self).apply(specification)

        self.objects = try factory.createDomainModels(
            with: realmObjects.apply(cursor),
            realm: realm
        )

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
                        let domainObjects: [F.DomainModel] = try self.factory.createDomainModels(
                            with: realmObjects.apply(self.cursor),
                            realm: realm
                        )

                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }

                            if self.objects != domainObjects {
                                self.objects = domainObjects
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
