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
    func query<F: DomainConvertibleFactoryType>(
        _ specification: Base.Specification,
        cursor: Cursor = .default,
        factory: F,
        realmConfiguration: Realm.Configuration = .defaultConfiguration,
        scheduler: Scheduler = UIScheduler()
    ) -> SignalProducer<[F.DomainModel], NSError> where F.PersistenceModel == Base.PersistenceModel {
        return SignalProducer<[F.DomainModel], NSError> { observer, lifetime in
            var token: NotificationToken?

            RealmNotificationThreadWrapper.shared.runAsync {
                do {
                    let realm = try Realm(configuration: realmConfiguration)
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
                        } catch {
                            observer.send(error: error as NSError)
                        }
                    }
                } catch {
                    observer.send(error: error as NSError)
                }
            }

            lifetime.observeEnded {
                RealmNotificationThreadWrapper.shared.runAsync {
                    token?.invalidate()
                }
            }
        }
        .skipRepeats()
        .observe(on: scheduler)
    }

    func queryOne<F: DomainConvertibleFactoryType>(
        _ specification: Base.Specification,
        pinPolicy: PinPolicy = .beginning,
        factory: F,
        realmConfiguration: Realm.Configuration = .defaultConfiguration,
        scheduler: Scheduler = UIScheduler()
    ) -> SignalProducer<F.DomainModel?, NSError> where F.PersistenceModel == Base.PersistenceModel {
        return SignalProducer<F.DomainModel?, NSError> { observer, lifetime in
            var token: NotificationToken?

            RealmNotificationThreadWrapper.shared.runAsync {
                do {
                    let realm = try Realm(configuration: realmConfiguration)
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
                        } catch {
                            observer.send(error: error as NSError)
                        }
                    }
                } catch {
                    observer.send(error: error as NSError)
                }
            }

            lifetime.observeEnded {
                RealmNotificationThreadWrapper.shared.runAsync {
                    token?.invalidate()
                }
            }
        }
        .skipRepeats()
        .observe(on: scheduler)
    }

    func count(
        _ specification: Base.Specification,
        realmConfiguration: Realm.Configuration = .defaultConfiguration,
        scheduler: Scheduler = UIScheduler()
    ) -> SignalProducer<Int, NSError> {
        return SignalProducer<Int, NSError> { observer, lifetime in
            var token: NotificationToken?

            RealmNotificationThreadWrapper.shared.runAsync {
                let realm = try! Realm(configuration: realmConfiguration)
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
                RealmNotificationThreadWrapper.shared.runAsync {
                    token?.invalidate()
                }
            }
        }
        .skipRepeats()
        .observe(on: scheduler)
    }
}

public extension Reactive where Base: ProviderType {
    func querySync<F: DomainConvertibleFactoryType>(
        _ specification: Base.Specification,
        cursor: Cursor = .default,
        factory: F,
        realmConfiguration: Realm.Configuration = .defaultConfiguration,
        scheduler: Scheduler = UIScheduler()
    ) -> SignalProducer<[F.DomainModel], NSError> where F.PersistenceModel == Base.PersistenceModel {
        do {
            let domainObjects = try self.base.query(specification, cursor: cursor, factory: factory)

            return self
                .query(
                    specification,
                    cursor: cursor,
                    factory: factory,
                    realmConfiguration: realmConfiguration,
                    scheduler: scheduler
                )
                .prefix(value: domainObjects)
        } catch {
            return SignalProducer<[F.DomainModel], NSError>.init(error: error as NSError)
        }
    }

    func queryOneSync<F: DomainConvertibleFactoryType>(
        _ specification: Base.Specification,
        pinPolicy: PinPolicy = .beginning,
        factory: F,
        realmConfiguration: Realm.Configuration = .defaultConfiguration,
        scheduler: Scheduler = UIScheduler()
    ) -> SignalProducer<F.DomainModel?, NSError> where F.PersistenceModel == Base.PersistenceModel {
        do {
            let domainObject = try self.base.queryOne(specification, pinPolicy: pinPolicy, factory: factory)

            return self
                .queryOne(
                    specification,
                    pinPolicy: pinPolicy,
                    factory: factory,
                    realmConfiguration: realmConfiguration,
                    scheduler: scheduler
                )
                .prefix(value: domainObject)
        } catch {
            return SignalProducer<F.DomainModel?, NSError>.init(error: error as NSError)
        }
    }

    func countSync(
        _ specification: Base.Specification,
        realmConfiguration: Realm.Configuration = .defaultConfiguration,
        scheduler: Scheduler = UIScheduler()
    ) -> SignalProducer<Int, NSError> {
        do {
            let count = try self.base.count(specification)

            return self
                .count(
                    specification,
                    realmConfiguration: realmConfiguration,
                    scheduler: scheduler
                )
                .prefix(value: count)
        } catch {
            return SignalProducer<Int, NSError>.init(error: error as NSError)
        }
    }
}
