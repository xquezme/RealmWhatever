//
//  Provider+Realm+Reactive.swift
//  RealmWhatever
//
//  Created by Sergey Pimenov on 24/03/2018.
//  Copyright © 2018 Sergey Pimenov. All rights reserved.
//

import Foundation
import ReactiveSwift
import RealmSwift

extension Provider: ReactiveExtensionsProvider {}

public extension Reactive where Base: ProviderType, Base.PersistenceModel: RealmSwift.Object {
    public func query(_ specification: Base.Specification, includeImmediateResults: Bool = true) -> SignalProducer<[Base.DomainModel], NSError> {
        let updateProducer = SignalProducer<[Base.DomainModel], NSError> { observer, lifetime in
            var token: NotificationToken!

            RealmNotificationThreadWrapper.shared.runSync {
                let realm = try! Realm()
                let objects = realm.objects(Base.PersistenceModel.self).apply(specification)

                token = objects.observe { [weak token] changeset in
                    let realmObjects: Results<Base.PersistenceModel>

                    switch changeset {
                    case let .initial(latestValue):
                        realmObjects = latestValue
                    case let .update(latestValue, _, _, _):
                        realmObjects = latestValue
                    case let .error(error):
                        token?.invalidate()
                        observer.send(error: error as NSError)
                        return
                    }

                    let domainObjects: [Base.DomainModel] = realmObjects.flatMap {
                        Base.Factory.createDomainModel(withPersistenceModel: $0)
                    }

                    observer.send(value: domainObjects)
                }
            }

            lifetime.observeEnded {
                RealmNotificationThreadWrapper.shared.runSync {
                    token!.invalidate()
                }
            }
        }

        guard includeImmediateResults else {
            return updateProducer
        }

        let domainObjects = base.query(specification)
        let immediateSignalProducer = SignalProducer<[Base.DomainModel], NSError>.init(value: domainObjects)

        return immediateSignalProducer.concat(updateProducer)
    }

    public func queryOne(_ specification: Base.Specification, includeImmediateResult: Bool = true) -> SignalProducer<Base.DomainModel?, NSError> {
        let updateProducer = SignalProducer<Base.DomainModel?, NSError> { observer, lifetime in
            var token: NotificationToken!

            RealmNotificationThreadWrapper.shared.runSync {
                let realm = try! Realm()
                let objects = realm.objects(Base.PersistenceModel.self).apply(specification)

                token = objects.observe { [weak token] changeset in
                    let realmObjects: Results<Base.PersistenceModel>

                    switch changeset {
                    case let .initial(latestValue):
                        realmObjects = latestValue
                    case let .update(latestValue, _, _, _):
                        realmObjects = latestValue
                    case let .error(error):
                        token?.invalidate()
                        observer.send(error: error as NSError)
                        return
                    }

                    let domainObject = Base.Factory.createDomainModel(withPersistenceModel: realmObjects.first)

                    observer.send(value: domainObject)
                }
            }

            lifetime.observeEnded {
                RealmNotificationThreadWrapper.shared.runSync {
                    token!.invalidate()
                }
            }
        }

        guard includeImmediateResult else {
            return updateProducer
        }

        let domainObject = base.queryOne(specification)
        let immediateSignalProducer = SignalProducer<Base.DomainModel?, NSError>.init(value: domainObject)

        return immediateSignalProducer.concat(updateProducer)
    }

    public func count(_ specification: Base.Specification, includeImmediateResults: Bool = true) -> SignalProducer<Int, NSError> {
        let updateProducer = SignalProducer<Int, NSError> { observer, lifetime in
            var token: NotificationToken!

            RealmNotificationThreadWrapper.shared.runSync {
                let realm = try! Realm()
                let objects = realm.objects(Base.PersistenceModel.self).apply(specification)

                token = objects.observe { [weak token] changeset in
                    let realmObjects: Results<Base.PersistenceModel>

                    switch changeset {
                    case let .initial(latestValue):
                        realmObjects = latestValue
                    case let .update(latestValue, _, _, _):
                        realmObjects = latestValue
                    case let .error(error):
                        token?.invalidate()
                        observer.send(error: error as NSError)
                        return
                    }

                    observer.send(value: realmObjects.count)
                }
            }

            lifetime.observeEnded {
                RealmNotificationThreadWrapper.shared.runSync {
                    token!.invalidate()
                }
            }
        }

        guard includeImmediateResults else {
            return updateProducer
        }

        let count = base.count(specification)
        let immediateSignalProducer = SignalProducer<Int, NSError>.init(value: count)

        return immediateSignalProducer.concat(updateProducer)
    }
}
