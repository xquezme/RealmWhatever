//
//  Provider+Realm+Rx.swift
//  RealmWhatever
//
//  Created by Sergey Pimenov on 02/03/2018.
//  Copyright © 2018 Sergey Pimenov. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

extension Provider: ReactiveCompatible {}

public extension Reactive where Base: ProviderType {
    func query<F: DomainConvertibleFactoryType>(
        _ specification: Base.Specification,
        cursor: Cursor = .default,
        factory: F,
        realmConfiguration: Realm.Configuration = .defaultConfiguration,
        scheduler: ImmediateSchedulerType = MainScheduler.asyncInstance
    ) -> Observable<[F.DomainModel]> where F.PersistenceModel == Base.PersistenceModel {
        return Observable<[F.DomainModel]>.create { observer in
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
                            observer.onError(error)
                            return
                        }

                        do {
                            let domainObjects: [F.DomainModel] = try factory.createDomainModels(
                                with: realmObjects.apply(cursor),
                                realm: realm
                            )
                            observer.onNext(domainObjects)
                        } catch {
                            observer.onError(error)
                        }
                    }
                } catch {
                    observer.onError(error)
                }
            }

            return Disposables.create {
                RealmNotificationThreadWrapper.shared.runAsync {
                    token?.invalidate()
                }
            }
        }
        .distinctUntilChanged()
        .observeOn(scheduler)
    }

    func queryOne<F: DomainConvertibleFactoryType>(
        _ specification: Base.Specification,
        pinPolicy: PinPolicy = .beginning,
        factory: F,
        realmConfiguration: Realm.Configuration = .defaultConfiguration,
        scheduler: ImmediateSchedulerType = MainScheduler.asyncInstance
    ) -> Observable<F.DomainModel?> where F.PersistenceModel == Base.PersistenceModel {
        return Observable<F.DomainModel?>.create { observer in
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
                            observer.onError(error)
                            return
                        }

                        do {
                            let realmObject = realmObjects.elementWithPolicy(pinPolicy: pinPolicy)
                            let domainObject = try realmObject.flatMap { realmObject in
                                try factory.createDomainModel(with: realmObject, realm: realm)
                            }
                            observer.onNext(domainObject)
                        } catch {
                            observer.onError(error)
                        }
                    }
                } catch {
                    observer.onError(error)
                }
            }

            return Disposables.create {
                RealmNotificationThreadWrapper.shared.runAsync {
                    token?.invalidate()
                }
            }
        }
        .distinctUntilChanged()
        .observeOn(scheduler)
    }

    func count(
        _ specification: Base.Specification,
        realmConfiguration: Realm.Configuration = .defaultConfiguration,
        scheduler: ImmediateSchedulerType = MainScheduler.asyncInstance
    ) -> Observable<Int> {
        return Observable<Int>.create { observer in
            var token: NotificationToken?

            RealmNotificationThreadWrapper.shared.runAsync {
                do {
                    let realm = try Realm(configuration: realmConfiguration)
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
                            observer.onError(error)
                            return
                        }

                        observer.onNext(realmObjects.count)
                    }
                } catch {
                    observer.onError(error)
                }
            }

            return Disposables.create {
                RealmNotificationThreadWrapper.shared.runAsync {
                    token?.invalidate()
                }
            }
        }
        .distinctUntilChanged()
        .observeOn(scheduler)
    }
}

public extension Reactive where Base: ProviderType {
    func querySync<F: DomainConvertibleFactoryType>(
        _ specification: Base.Specification,
        cursor: Cursor = .default,
        factory: F,
        realmConfiguration: Realm.Configuration = .defaultConfiguration,
        scheduler: ImmediateSchedulerType = MainScheduler.asyncInstance
    ) -> Observable<[F.DomainModel]> where F.PersistenceModel == Base.PersistenceModel {
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
                .startWith(domainObjects)
        } catch {
            return Observable.error(error)
        }
    }

    func queryOneSync<F: DomainConvertibleFactoryType>(
        _ specification: Base.Specification,
        pinPolicy: PinPolicy = .beginning,
        factory: F,
        realmConfiguration: Realm.Configuration = .defaultConfiguration,
        scheduler: ImmediateSchedulerType = MainScheduler.asyncInstance
    ) -> Observable<F.DomainModel?> where F.PersistenceModel == Base.PersistenceModel {
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
                .startWith(domainObject)
        } catch {
            return Observable.error(error)
        }
    }

    func countSync(
        _ specification: Base.Specification,
        realmConfiguration: Realm.Configuration = .defaultConfiguration,
        scheduler: ImmediateSchedulerType = MainScheduler.asyncInstance
    ) -> Observable<Int> {
        do {
            let count = try self.base.count(specification)

            return self
                .count(
                    specification,
                    realmConfiguration: realmConfiguration,
                    scheduler: scheduler
                )
                .startWith(count)
        } catch {
            return Observable.error(error)
        }
    }
}
