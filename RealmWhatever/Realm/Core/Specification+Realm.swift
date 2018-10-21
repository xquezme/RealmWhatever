//
//  Specification+Realm.swift
//  RealmWhatever
//
//  Created by Sergey Pimenov on 04/03/2018.
//  Copyright © 2018 Sergey Pimenov. All rights reserved.
//

import Foundation
import RealmSwift

extension Results {
    private func filter(_ predicate: NSPredicate?) -> Results<Element> {
        guard let predicate = predicate else { return self }
        return self.filter(predicate)
    }

    private func sorted(_ sortDescriptor: NSSortDescriptor?) -> Results<Element> {
        guard let sortDescriptor = sortDescriptor else { return self }
        return self.sorted(byKeyPath: sortDescriptor.key!, ascending: sortDescriptor.ascending)
    }

    func apply(_ specification: SpecificationType) -> Results<Element> {
        return self
            .filter(specification.predicate())
            .sorted(specification.sortDescriptor())
    }

    func elementWithPolicy(policy: QueryOnePolicy) -> Element? {
        switch policy {
        case .first:
            return self.first
        case .last:
            return self.last
        }
    }
}
