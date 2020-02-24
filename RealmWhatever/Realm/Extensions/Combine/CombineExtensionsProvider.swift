//
//  dasd.swift
//  RealmWhatever
//
//  Created by Sergey Pimenov on 24.02.2020.
//  Copyright © 2020 Sergey Pimenov. All rights reserved.
//

import Foundation

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public protocol CombineExtensionsProvider {}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension CombineExtensionsProvider {
    public var combine: Combine<Self> {
        return Combine(self)
    }

    public static var combine: Combine<Self>.Type {
        return Combine<Self>.self
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct Combine<Base> {
    public let base: Base

    fileprivate init(_ base: Base) {
        self.base = base
    }
}
