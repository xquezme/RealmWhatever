//
//  Provider+Realm+Rx.swift
//  RealmWhatever
//
//  Created by Sergey Pimenov on 02/03/2018.
//  Copyright © 2018 Sergey Pimenov. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

extension Provider: ReactiveCompatible {}

public extension Reactive where Base: ProviderType {
    func query<F: DomainConvertibleFactoryType>(
        _ specification: Base.Specification,
        cursor: Cursor = .default,
        factory: F
    ) -> Observable<[F.DomainModel]> where F.PersistenceModel == Base.PersistenceModel {
        return Observable<[F.DomainModel]>.create { observer in
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
                            observer.onError(error)
                            return
                        }

                        do {
                            let domainObjects: [F.DomainModel] = try factory.createDomainModels(
                                with: realmObjects.apply(cursor),
                                realm: realm
                            )
                            observer.onNext(domainObjects)
                        } catch let error {
                            observer.onError(error)
                        }
                    }
                } catch let error {
                    observer.onError(error)
                }
            }

            return Disposables.create {
                RealmNotificationThreadWrapper.shared.runSync {
                    token?.invalidate()
                }
            }
        }
    }
    
    func queryOne<F: DomainConvertibleFactoryType>(
        _ specification: Base.Specification,
        pinPolicy: PinPolicy = .beginning,
        factory: F
    ) -> Observable<F.DomainModel?> where F.PersistenceModel == Base.PersistenceModel {
        return Observable<F.DomainModel?>.create { observer in
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
                            observer.onError(error)
                            return
                        }

                        do {
                            let realmObject = realmObjects.elementWithPolicy(pinPolicy: pinPolicy)
                            let domainObject = try realmObject.flatMap { realmObject in
                                try factory.createDomainModel(with: realmObject, realm: realm)
                            }
                            observer.onNext(domainObject)
                        } catch let error {
                            observer.onError(error)
                        }
                    }
                } catch let error {
                    observer.onError(error)
                }
            }

            return Disposables.create {
                RealmNotificationThreadWrapper.shared.runSync {
                    token?.invalidate()
                }
            }
        }
    }

    func count(_ specification: Base.Specification) -> Observable<Int> {
        return Observable<Int>.create { observer in
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
                            observer.onError(error)
                            return
                        }

                        observer.onNext(realmObjects.count)
                    }
                } catch let error {
                    observer.onError(error)
                }
            }

            return Disposables.create {
                RealmNotificationThreadWrapper.shared.runSync {
                    token?.invalidate()
                }
            }
        }
    }
}


public extension Reactive where Base: ProviderType {
    func querySync<F: DomainConvertibleFactoryType>(
        _ specification: Base.Specification,
        cursor: Cursor = .default,
        factory: F
    ) -> Observable<[F.DomainModel]> where F.PersistenceModel == Base.PersistenceModel {
        do {
            let domainObjects = try self.base.query(specification, cursor: cursor, factory: factory)

            let immediateObservable = Observable<[F.DomainModel]>.just(domainObjects)
            let updateObservable = self.query(specification, cursor: cursor, factory: factory)

            return immediateObservable.concat(updateObservable)
        } catch let error {
            return Observable.error(error)
        }
    }

    func queryOneSync<F: DomainConvertibleFactoryType>(
        _ specification: Base.Specification,
        pinPolicy: PinPolicy = .beginning,
        factory: F
   ) -> Observable<F.DomainModel?> where F.PersistenceModel == Base.PersistenceModel {
        do {
            let domainObject = try self.base.queryOne(specification, pinPolicy: pinPolicy, factory: factory)

            let immediateObservable = Observable<F.DomainModel?>.just(domainObject)
            let updateObservable = self.queryOne(specification, pinPolicy: pinPolicy, factory: factory)

            return immediateObservable.concat(updateObservable)
        } catch let error {
            return Observable.error(error)
        }
    }

    func countSync(_ specification: Base.Specification) -> Observable<Int> {
        do {
            let count = try self.base.count(specification)

            let immediateObservable = Observable<Int>.just(count)
            let updateObservable = self.count(specification)

            return immediateObservable.concat(updateObservable)
        } catch let error {
            return Observable.error(error)
        }
    }
}
