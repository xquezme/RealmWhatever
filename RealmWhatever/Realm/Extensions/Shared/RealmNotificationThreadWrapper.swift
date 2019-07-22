//
//  RealmNotificationThreadWrapper.swift
//  RealmWhatever
//
//  Created by Sergey Pimenov on 02/03/2018.
//  Copyright © 2018 Sergey Pimenov. All rights reserved.
//

import Foundation

final class RealmNotificationThreadWrapper: NSObject {
    static let shared = RealmNotificationThreadWrapper()

    private override init() {
        super.init()
        self.thread.start()
    }

    private lazy var thread: Thread = {
        let thread = Thread(target: self, selector: #selector(self.loop), object: nil)

        thread.name = "RealmWhatever-Thread-\(UUID().uuidString)"

        return thread
    }()

    private var block: (() -> Void)!

    @objc private func loop() {
        while self.thread.isCancelled == false {
            RunLoop.current.run(
                mode: .default,
                before: .distantFuture
            )
        }

        Thread.exit()
    }

    @objc private func runBlock() { self.block() }

    func runSync(_ block: @escaping () -> Void) {
        self.block = block

        self.perform(
            #selector(self.runBlock),
            on: self.thread,
            with: nil,
            waitUntilDone: true,
            modes: [RunLoop.Mode.default.rawValue]
        )
    }

    func runAsync(_ block: @escaping () -> Void) {
        self.block = block

        self.perform(
            #selector(runBlock),
            on: self.thread,
            with: nil,
            waitUntilDone: false,
            modes: [RunLoop.Mode.default.rawValue]
        )
    }

    deinit {
        self.thread.cancel()
    }
}
