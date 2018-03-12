//
// Created by Mikhail Mulyar on 07/01/2018.
// Copyright (c) 2018 Mikhail Mulyar. All rights reserved.
//

import Foundation


internal class DatabaseBackgroundWorker: NSObject {

    private var thread: Thread!

    typealias Block = @convention(block) () -> Void

    @objc private func run(block: Block) {
        block()
    }

    internal func execute(block: Block) {
        perform(#selector(run(block:)),
                on: thread,
                with: block,
                waitUntilDone: false,
                modes: [RunLoopMode.defaultRunLoopMode.rawValue])
    }

    internal func start(_ block: @escaping () -> Void) {
        let threadName = "mm.databaseService.databaseServiceWorkThread"

        thread = Thread {
            [weak self] in
            while (self != nil && !self!.thread.isCancelled) {
                RunLoop.current.run(
                        mode: RunLoopMode.defaultRunLoopMode,
                        before: Date.distantPast)
            }
            Thread.exit()
        }
        thread.qualityOfService = .utility
        thread.name = "\(threadName)-\(UUID().uuidString)"
        thread.start()

        self.execute(block: block)
    }

    internal func stop() {
        thread.cancel()
    }
}