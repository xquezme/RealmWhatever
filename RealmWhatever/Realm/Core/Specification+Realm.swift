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

    private func sorted(_ sortDescriptors: [NSSortDescriptor]?) -> Results<Element> {
        guard let sortDescriptors = sortDescriptors else { return self }

        let rlmSortDescriptors: [SortDescriptor] = sortDescriptors.map {
            SortDescriptor(keyPath: $0.key!, ascending: $0.ascending)
        }

        return self.sorted(by: rlmSortDescriptors)
    }

    func apply(_ specification: SpecificationType) -> Results<Element> {
        return self
            .filter(specification.predicate)
            .sorted(specification.sortDescriptors)
    }
}
