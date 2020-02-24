//
//  Cursor+Realm.swift
//  RealmWhatever
//
//  Created by Sergey Pimenov on 26/10/2018.
//  Copyright © 2018 Sergey Pimenov. All rights reserved.
//

import Foundation
import RealmSwift

extension Results {
    func apply(_ cursor: Cursor) -> [Element] {
        let count = self.count

        switch (cursor.limit, cursor.offset) {
        case (nil, nil):
            switch cursor.pinPolicy {
            case .beginning:
                return Array(self)
            case .end:
                return Array(self).reversed()
            }
        case (let limit?, nil):
            switch cursor.pinPolicy {
            case .beginning:
                let start = 0
                let end = Swift.min(limit, count)

                var result = [Element]()

                for i in stride(from: start, to: end, by: 1) {
                    result.append(self[i])
                }

                return result
            case .end:
                let start = count
                let end = Swift.max(start - limit, 0)

                var result = [Element]()

                for i in stride(from: start - 1, through: end, by: -1) {
                    result.append(self[i])
                }

                return result
            }
        case (nil, let offset?):
            if offset > count {
                return []
            }

            switch cursor.pinPolicy {
            case .beginning:
                var result = [Element]()

                let start = offset
                let end = count

                for i in stride(from: start, to: end, by: 1) {
                    result.append(self[i])
                }

                return result
            case .end:
                let start = count - offset
                let end = 0

                var result = [Element]()

                for i in stride(from: start - 1, through: end, by: -1) {
                    result.append(self[i])
                }

                return result
            }
        case let (limit?, offset?):
            if offset > count {
                return []
            }

            switch cursor.pinPolicy {
            case .beginning:
                var result = [Element]()

                let start = offset
                let end = Swift.min(limit + offset, count)

                for i in stride(from: start, to: end, by: 1) {
                    result.append(self[i])
                }

                return result
            case .end:
                let start = count - offset
                let end = Swift.max(start - limit, 0)

                var result = [Element]()

                for i in stride(from: start - 1, through: end, by: -1) {
                    result.append(self[i])
                }

                return result
            }
        }
    }
}
