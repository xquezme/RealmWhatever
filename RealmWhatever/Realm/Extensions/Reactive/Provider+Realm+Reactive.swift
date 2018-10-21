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

public extension Reactive where Base: ProviderType {
    public func query(
        _ specification: Base.Specification,
        includeImmediateResults: Bool = true
    ) -> SignalProducer<[Base.DomainModel], NSError> {
        let updateProducer = SignalProducer<[Base.DomainModel], NSError> { observer, lifetime in
            var token: NotificationToken?

            RealmNotificationThreadWrapper.shared.runSync {
                do {
                    let realm = try Realm()
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

                        do {
                            let domainObjects: [Base.DomainModel] = try realmObjects.map { realmObject in
                                try Base.Factory.createDomainModel(
                                    withPersistenceModel: realmObject,
                                    realm: realm
                                )
                            }

                            observer.send(value: domainObjects)
                        } catch let error {
                            observer.send(error: error as NSError)
                        }
                    }
                } catch let error {
                    observer.send(error: error as NSError)
                }
            }

            lifetime.observeEnded {
                RealmNotificationThreadWrapper.shared.runSync {
                    token?.invalidate()
                }
            }
        }

        guard includeImmediateResults else {
            return updateProducer.skipRepeats()
        }

        do {
            let domainObjects = try self.base.query(specification)
            let immediateSignalProducer = SignalProducer<[Base.DomainModel], NSError>.init(value: domainObjects)

            return immediateSignalProducer.concat(updateProducer).skipRepeats()
        } catch let error {
            return SignalProducer<[Base.DomainModel], NSError>.init(error: error as NSError)
        }
    }

    public func queryOne(
        _ specification: Base.Specification,
        policy: QueryOnePolicy = .last,
        includeImmediateResult: Bool = true
    ) -> SignalProducer<Base.DomainModel?, NSError> {
        let updateProducer = SignalProducer<Base.DomainModel?, NSError> { observer, lifetime in
            var token: NotificationToken?

            RealmNotificationThreadWrapper.shared.runSync {
                do {
                    let realm = try Realm()
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

                        do {
                            let domainObject = try realmObjects.elementWithPolicy(policy: policy).flatMap { realmObject in
                                try Base.Factory.createDomainModel(
                                    withPersistenceModel: realmObject,
                                    realm: realm
                                )
                            }
                            observer.send(value: domainObject)
                        } catch let error {
                            observer.send(error: error as NSError)
                        }
                    }
                } catch let error {
                    observer.send(error: error as NSError)
                }
            }

            lifetime.observeEnded {
                RealmNotificationThreadWrapper.shared.runSync {
                    token?.invalidate()
                }
            }
        }

        guard includeImmediateResult else {
            return updateProducer.skipRepeats()
        }

        do {
            let domainObject = try self.base.queryOne(specification)
            let immediateSignalProducer = SignalProducer<Base.DomainModel?, NSError>.init(value: domainObject)

            return immediateSignalProducer.concat(updateProducer).skipRepeats()
        } catch let error {
            return SignalProducer<Base.DomainModel?, NSError>.init(error: error as NSError)
        }
    }

    public func count(
        _ specification: Base.Specification,
        includeImmediateResults: Bool = true
    ) -> SignalProducer<Int, NSError> {
        let updateProducer = SignalProducer<Int, NSError> { observer, lifetime in
            var token: NotificationToken?

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
                    token?.invalidate()
                }
            }
        }

        guard includeImmediateResults else {
            return updateProducer.skipRepeats()
        }

        do {
            let count = try self.base.count(specification)
            let immediateSignalProducer = SignalProducer<Int, NSError>.init(value: count)

            return immediateSignalProducer.concat(updateProducer).skipRepeats()
        } catch let error {
            return SignalProducer<Int, NSError>.init(error: error as NSError)
        }
    }
}
