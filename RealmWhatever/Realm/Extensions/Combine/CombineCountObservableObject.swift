//
//  CombineCountObservableObject.swift
//  RealmWhatever
//
//  Created by Sergey Pimenov on 24.02.2020.
//  Copyright © 2020 Sergey Pimenov. All rights reserved.
//

import Combine
import Foundation
import RealmSwift

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public final class CombineCountObservableObject<M: RealmSwift.Object>: ObservableObject {
    @Published public var count: Int = 0

    private let specification: SpecificationType
    private let realmConfiguration: Realm.Configuration

    private var token: NotificationToken?

    init(
        specification: SpecificationType,
        realmConfiguration: Realm.Configuration = .defaultConfiguration
    ) throws {
        self.specification = specification
        self.realmConfiguration = realmConfiguration

        let realm = try Realm(configuration: realmConfiguration)

        let realmObjects = realm.objects(M.self).apply(specification)

        self.count = realmObjects.count

        self.startObserving()
    }

    private func startObserving() {
        RealmNotificationThreadWrapper.shared.runAsync { [weak self] in
            guard let self = self else { return }

            do {
                let realm = try Realm(configuration: self.realmConfiguration)
                let objects = realm.objects(M.self).apply(self.specification)

                self.token = objects.observe { [weak self] changeset in
                    guard let self = self else { return }

                    let realmObjects: Results<M>

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

                    let count = realmObjects.count

                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }

                        if self.count != count {
                            self.count = count
                        }
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
