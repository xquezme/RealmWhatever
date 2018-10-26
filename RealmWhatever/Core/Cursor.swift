//
//  Cursor.swift
//  RealmWhatever
//
//  Created by Sergey Pimenov on 26/10/2018.
//  Copyright © 2018 Sergey Pimenov. All rights reserved.
//

import Foundation

public struct Cursor {
    public static let `default` = Cursor()
    public let limit: Int?
    public let offset: Int?
    public let pinPolicy: PinPolicy

    public init(limit: Int? = nil, offset: Int? = nil, pinPolicy: PinPolicy = .beginning) {
        self.limit = limit
        self.offset = offset
        self.pinPolicy = pinPolicy
    }
}
