//
//  QueryableRepository+Realm+Rx.swift
//  RealmWhatever
//
//  Created by Sergey Pimenov on 02/03/2018.
//  Copyright © 2018 Sergey Pimenov. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

extension QueryableRepository: ReactiveCompatible {}

public extension Reactive where Base: QueryableRepositoryType, Base.PersistenceModel: RealmSwift.Object {
    public func query(_ specification: Base.QuerySpecification) -> Observable<[Base.DomainModel]> {
        let realm = try! Realm()
        let realmObjects = realm.objects(Base.PersistenceModel.self).apply(specification)
        let domainObjects: [Base.DomainModel] = realmObjects.flatMap {
            Base.Factory.createDomainModel(withPersistenceModel: $0)
        }

        let immediateObservable = Observable<[Base.DomainModel]>.just(domainObjects)

        let updateObservable = Observable<[Base.DomainModel]>.create { observer in
            var token: NotificationToken!

            RxRealmNotificationThreadWrapper.shared.runSync {
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
                        observer.onError(error)
                        return
                    }

                    let domainObjects: [Base.DomainModel] = realmObjects.flatMap {
                        Base.Factory.createDomainModel(withPersistenceModel: $0)
                    }

                    observer.onNext(domainObjects)
                }
            }

            return Disposables.create {
                RxRealmNotificationThreadWrapper.shared.runSync {
                    token!.invalidate()
                }
            }
        }

        return immediateObservable
            .concat(updateObservable)
            .distinctUntilChanged({ $0 == $1 })
    }
    
    public func queryOne(_ specification: Base.QuerySpecification) -> Observable<Base.DomainModel?> {
        let realm = try! Realm()
        let realmObjects = realm.objects(Base.PersistenceModel.self).apply(specification)
        let domainObject = Base.Factory.createDomainModel(withPersistenceModel: realmObjects.first)

        let immediateObservable = Observable<Base.DomainModel?>.just(domainObject)

        let updateObservable = Observable<Base.DomainModel?>.create { observer in
            var token: NotificationToken!

            RxRealmNotificationThreadWrapper.shared.runSync {
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
                        observer.onError(error)
                        return
                    }

                    let domainObject = Base.Factory.createDomainModel(withPersistenceModel: realmObjects.first)
                    observer.onNext(domainObject)
                }
            }

            return Disposables.create {
                RxRealmNotificationThreadWrapper.shared.runSync {
                    token!.invalidate()
                }
            }
        }
        
        return immediateObservable
            .concat(updateObservable)
            .distinctUntilChanged({ $0 == $1 })
    }

    public func count(_ specification: Base.QuerySpecification) -> Observable<Int> {
        let realm = try! Realm()
        let realmObjects = realm.objects(Base.PersistenceModel.self).apply(specification)

        let immediateObservable = Observable<Int>.just(realmObjects.count)

        let updateObservable = Observable<Int>.create { observer in
            var token: NotificationToken!

            RxRealmNotificationThreadWrapper.shared.runSync {
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
                        observer.onError(error)
                        return
                    }

                    observer.onNext(realmObjects.count)
                }
            }

            return Disposables.create {
                RxRealmNotificationThreadWrapper.shared.runSync {
                    token!.invalidate()
                }
            }
        }

        return immediateObservable
            .concat(updateObservable)
            .distinctUntilChanged({ $0 == $1 })
    }
}
