//
// Created by Mikhail Mulyar on 07/01/2018.
// Copyright (c) 2018 Mikhail Mulyar. All rights reserved.
//

import Foundation


internal class DatabaseWorker: NSObject {
    typealias Block = @convention(block) () -> Void

    internal func execute(block: @escaping Block) {
        DispatchQueue.main.async {
            block()
        }
    }

    internal func start(_ block: @escaping () -> Void) {
        self.execute(block: block)
    }

    internal func stop() {

    }
}


internal class DatabaseBackgroundWorker: DatabaseWorker {

    lazy var thread: Thread = {
        let threadName = "mm.databaseService.workThread"

        let thread = Thread {
            [weak self] in
            while let `self` = self, !self.thread.isCancelled {
                RunLoop.current.run(mode: RunLoop.Mode.default, before: Date.distantPast)
            }
            Thread.exit()
        }
        thread.qualityOfService = .utility
        thread.name = "\(threadName)-\(UUID().uuidString)"
        thread.start()
        return thread
    }()

    @objc private func run(block: Block) {
        block()
    }

    override internal func execute(block: @escaping Block) {
        perform(#selector(run(block:)),
                on: thread,
                with: block,
                waitUntilDone: false,
                modes: [RunLoop.Mode.default.rawValue])
    }

    override internal func start(_ block: @escaping () -> Void) {
        self.execute(block: block)
    }

    override internal func stop() {
        thread.cancel()
    }
}
