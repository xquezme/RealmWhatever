//
//  RxRealmNotificationThreadWrapper.swift
//  RealmWhatever
//
//  Created by Sergey Pimenov on 02/03/2018.
//  Copyright © 2018 Sergey Pimenov. All rights reserved.
//

import Foundation

final class RxRealmNotificationThreadWrapper: NSObject {
    static let shared = RxRealmNotificationThreadWrapper()
    private override init() { super.init() }

    private lazy var thread: Thread = {
        let thread = Thread(
            target: self,
            selector: #selector(self.loop),
            object: nil
        )
        thread.name = "RxRealmWhateverNotificationThread"
        thread.start()
        return thread
    }()

    private var block: (() -> Void)!

    @objc
    private func loop() {
        while self.thread.isCancelled == false {
            RunLoop.current.run(
                mode: RunLoopMode.defaultRunLoopMode,
                before: .distantFuture
            )
        }
        Thread.exit()
    }

    @objc
    private func runBlock() {
        self.block()
    }

    func runSync(_ block: @escaping () -> Void) {
        self.block = block

        perform(
            #selector(self.runBlock),
            on: self.thread,
            with: nil,
            waitUntilDone: true,
            modes: [RunLoopMode.defaultRunLoopMode.rawValue]
        )
    }

    func runAsync(_ block: @escaping () -> Void) {
        self.block = block

        perform(
            #selector(self.runBlock),
            on: self.thread,
            with: nil,
            waitUntilDone: false,
            modes: [RunLoopMode.defaultRunLoopMode.rawValue]
        )
    }
}
