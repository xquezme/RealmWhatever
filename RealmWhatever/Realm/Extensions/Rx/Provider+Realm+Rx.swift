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
    public func query(
        _ specification: Base.Specification,
        includeImmediateResults: Bool = true
    ) -> Observable<[Base.DomainModel]> {
        let updateObservable = Observable<[Base.DomainModel]>.create { observer in
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

                        do {
                            let domainObjects: [Base.DomainModel] = try realmObjects.map { realmObject in
                                try Base.Factory.createDomainModel(withPersistenceModel: realmObject, realm: realm)
                            }
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

        guard includeImmediateResults else {
            return updateObservable.distinctUntilChanged()
        }

        do {
            let domainObjects = try self.base.query(specification)
            let immediateObservable = Observable<[Base.DomainModel]>.just(domainObjects)

            return immediateObservable.concat(updateObservable).distinctUntilChanged()
        } catch let error {
            return Observable.error(error)
        }
    }
    
    public func queryOne(
        _ specification: Base.Specification,
        policy: QueryOnePolicy = .last,
        includeImmediateResult: Bool = true
    ) -> Observable<Base.DomainModel?> {
        let updateObservable = Observable<Base.DomainModel?>.create { observer in
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

                        do {
                            let domainObject = try realmObjects.elementWithPolicy(policy: policy).flatMap { realmObject in
                                try Base.Factory.createDomainModel(withPersistenceModel: realmObject, realm: realm)
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

        guard includeImmediateResult else {
            return updateObservable.distinctUntilChanged()
        }

        do {
            let domainObject = try self.base.queryOne(specification)
            let immediateObservable = Observable<Base.DomainModel?>.just(domainObject)

            return immediateObservable.concat(updateObservable).distinctUntilChanged()
        } catch let error {
            return Observable.error(error)
        }
    }

    public func count(
        _ specification: Base.Specification,
        includeImmediateResults: Bool = true
    ) -> Observable<Int> {
        let updateObservable = Observable<Int>.create { observer in
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

        guard includeImmediateResults else {
            return updateObservable.distinctUntilChanged()
        }

        do {
            let count = try self.base.count(specification)
            let immediateObservable = Observable<Int>.just(count)

            return immediateObservable.concat(updateObservable).distinctUntilChanged()
        } catch let error {
            return Observable.error(error)
        }
    }
}
