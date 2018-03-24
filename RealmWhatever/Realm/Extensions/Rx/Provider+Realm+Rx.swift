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

public extension Reactive where Base: ProviderType, Base.PersistenceModel: RealmSwift.Object {
    public func query(_ specification: Base.Specification, includeImmediateResults: Bool = true) -> Observable<[Base.DomainModel]> {
        let updateObservable = Observable<[Base.DomainModel]>.create { observer in
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
                RealmNotificationThreadWrapper.shared.runSync {
                    token!.invalidate()
                }
            }
        }

        guard includeImmediateResults else {
            return updateObservable
        }

        let domainObjects = base.query(specification)
        let immediateObservable = Observable<[Base.DomainModel]>.just(domainObjects)

        return immediateObservable.concat(updateObservable)
    }
    
    public func queryOne(_ specification: Base.Specification, includeImmediateResult: Bool = true) -> Observable<Base.DomainModel?> {
        let updateObservable = Observable<Base.DomainModel?>.create { observer in
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
                        observer.onError(error)
                        return
                    }

                    let domainObject = Base.Factory.createDomainModel(withPersistenceModel: realmObjects.first)
                    
                    observer.onNext(domainObject)
                }
            }

            return Disposables.create {
                RealmNotificationThreadWrapper.shared.runSync {
                    token!.invalidate()
                }
            }
        }

        guard includeImmediateResult else {
            return updateObservable
        }

        let domainObject = base.queryOne(specification)
        let immediateObservable = Observable<Base.DomainModel?>.just(domainObject)
        
        return immediateObservable.concat(updateObservable)
    }

    public func count(_ specification: Base.Specification, includeImmediateResults: Bool = true) -> Observable<Int> {
        let updateObservable = Observable<Int>.create { observer in
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
                        observer.onError(error)
                        return
                    }

                    observer.onNext(realmObjects.count)
                }
            }

            return Disposables.create {
                RealmNotificationThreadWrapper.shared.runSync {
                    token!.invalidate()
                }
            }
        }

        guard includeImmediateResults else {
            return updateObservable
        }

        let count = base.count(specification)
        let immediateObservable = Observable<Int>.just(count)

        return immediateObservable.concat(updateObservable)
    }
}
