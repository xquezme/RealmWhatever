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
    public func query<F: DomainConvertibleFactoryType>(
        _ specification: Base.Specification,
        cursor: Cursor = .default,
        factory: F
    ) -> SignalProducer<[F.DomainModel], NSError> where F.PersistenceModel == Base.PersistenceModel {
        return SignalProducer<[F.DomainModel], NSError> { observer, lifetime in
            var token: NotificationToken?

            RealmNotificationThreadWrapper.shared.runSync {
                do {
                    let realm = try Realm()
                    let objects = realm.objects(F.PersistenceModel.self).apply(specification)

                    token = objects.observe { [weak token] changeset in
                        let realmObjects: Results<F.PersistenceModel>

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
                            let domainObjects: [F.DomainModel] = try factory.createDomainModels(
                                with: realmObjects.apply(cursor),
                                realm: realm
                            )

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
    }

    public func queryOne<F: DomainConvertibleFactoryType>(
        _ specification: Base.Specification,
        pinPolicy: PinPolicy = .beginning,
        factory: F
    ) -> SignalProducer<F.DomainModel?, NSError> where F.PersistenceModel == Base.PersistenceModel {
        return SignalProducer<F.DomainModel?, NSError> { observer, lifetime in
            var token: NotificationToken?

            RealmNotificationThreadWrapper.shared.runSync {
                do {
                    let realm = try Realm()
                    let objects = realm.objects(F.PersistenceModel.self).apply(specification)

                    token = objects.observe { [weak token] changeset in
                        let realmObjects: Results<F.PersistenceModel>

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
                            let realmObject = realmObjects.elementWithPolicy(pinPolicy: pinPolicy)
                            let domainObject = try realmObject.flatMap { realmObject in
                                try factory.createDomainModel(
                                    with: realmObject,
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
    }

    public func count(_ specification: Base.Specification) -> SignalProducer<Int, NSError> {
        return SignalProducer<Int, NSError> { observer, lifetime in
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
    }
}

public extension Reactive where Base: ProviderType {
    public func querySync<F: DomainConvertibleFactoryType>(
        _ specification: Base.Specification,
        cursor: Cursor = .default,
        factory: F
    ) -> SignalProducer<[F.DomainModel], NSError> where F.PersistenceModel == Base.PersistenceModel {
        do {
            let domainObjects = try self.base.query(specification, cursor: cursor, factory: factory)

            let immediateSignalProducer = SignalProducer<[F.DomainModel], NSError>.init(value: domainObjects)
            let updateSignalProducer = self.query(specification, cursor: cursor, factory: factory)

            return immediateSignalProducer.concat(updateSignalProducer)
        } catch let error {
            return SignalProducer<[F.DomainModel], NSError>.init(error: error as NSError)
        }
    }

    public func queryOneSync<F: DomainConvertibleFactoryType>(
        _ specification: Base.Specification,
        pinPolicy: PinPolicy = .beginning,
        factory: F
    ) -> SignalProducer<F.DomainModel?, NSError> where F.PersistenceModel == Base.PersistenceModel {
        do {
            let domainObject = try self.base.queryOne(specification, pinPolicy: pinPolicy, factory: factory)

            let immediateSignalProducer = SignalProducer<F.DomainModel?, NSError>.init(value: domainObject)
            let updateSignalProducer = self.queryOne(specification, pinPolicy: pinPolicy, factory: factory)

            return immediateSignalProducer.concat(updateSignalProducer)
        } catch let error {
            return SignalProducer<F.DomainModel?, NSError>.init(error: error as NSError)
        }
    }

    public func countSync(_ specification: Base.Specification) -> SignalProducer<Int, NSError> {
        do {
            let count = try self.base.count(specification)
            let immediateSignalProducer = SignalProducer<Int, NSError>.init(value: count)
            let updateSignalProducer = self.count(specification)

            return immediateSignalProducer.concat(updateSignalProducer)
        } catch let error {
            return SignalProducer<Int, NSError>.init(error: error as NSError)
        }
    }
}
