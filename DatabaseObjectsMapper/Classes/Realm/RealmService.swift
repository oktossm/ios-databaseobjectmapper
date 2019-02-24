//
// Created by Mikhail Mulyar on 02/01/2018.
// Copyright (c) 2018 Mikhail Mulyar. All rights reserved.
//

import RealmSwift


public typealias RealmObject = Object


public class RealmService {

    private let writeWorker: DatabaseRealmBackgroundWorker
    private var readWorkers: [DatabaseRealmBackgroundWorker]
    private let configuration: Realm.Configuration

    public init(configuration: Realm.Configuration = Realm.Configuration.defaultConfiguration) {
        self.configuration = configuration
        self.writeWorker = DatabaseRealmBackgroundWorker(configuration: configuration)
        self.readWorkers = []
    }

    deinit {
        self.writeWorker.stop()
        self.readWorkers.forEach { $0.stop() }
    }

    func nextWorker() -> DatabaseRealmBackgroundWorker {
        if let worker = self.readWorkers.first(where: { !$0.isWorking }) {
            return worker
        }
        let newWorker = DatabaseRealmBackgroundWorker(configuration: configuration)
        self.readWorkers.append(newWorker)
        return newWorker
    }
}


extension RealmService {
    public func deleteAll() {
        self.writeWorker.execute {
            realmOperator in
            try? realmOperator.write {
                transaction in
                transaction.deleteAll()
            }
        }
    }

    public func store<T: DatabaseMappable>(object: T, update: Bool = true) where T.DatabaseType: RealmObject {
        self.store(objects: [object])
    }

    public func store<T: DatabaseMappable>(objects: [T], update: Bool = true) where T.DatabaseType: RealmObject {
        self.writeWorker.execute {
            realmOperator in
            try? realmOperator.write {
                transaction in
                try? transaction.add(objects, update: update)
            }
        }
    }

    public func update<T: DatabaseMappable>(object: T) where T.DatabaseType: RealmObject {
        self.update(objects: [object])
    }

    public func update<T: DatabaseMappable>(objects: [T]) where T.DatabaseType: RealmObject {
        self.writeWorker.execute {
            realmOperator in
            try? realmOperator.write {
                transaction in
                try? transaction.update(objects)
            }
        }
    }

    public func update<T: DatabaseMappable>(objectOf type: T.Type,
                                            withPrimaryKey key: PrimaryKeyContainer,
                                            updates: T.DatabaseUpdates) where T.DatabaseType: RealmObject {
        self.writeWorker.execute {
            realmOperator in
            try? realmOperator.write {
                transaction in
                transaction.update(objectOf: type, withPrimaryKey: key, updates: updates)
            }
        }
    }

    public func update<T: DatabaseMappable>(objectOf type: T.Type,
                                            withPrimaryKey key: PrimaryKeyContainer,
                                            relationships: [DatabaseRelationshipUpdate]) where T.DatabaseType: RealmObject {
        self.writeWorker.execute {
            realmOperator in
            try? realmOperator.write {
                transaction in
                transaction.update(objectOf: type, withPrimaryKey: key, relationships: relationships)
            }
        }
    }

    public func update<T: DatabaseMappable>(objectOf type: T.Type,
                                            withPrimaryKey key: PrimaryKeyContainer,
                                            updates: T.DatabaseUpdates,
                                            relationships: [DatabaseRelationshipUpdate]) where T.DatabaseType: RealmObject {
        self.writeWorker.execute {
            realmOperator in
            try? realmOperator.write {
                transaction in
                transaction.update(objectOf: type, withPrimaryKey: key, updates: updates)
                transaction.update(objectOf: type, withPrimaryKey: key, relationships: relationships)
            }
        }
    }

    public func delete<T: DatabaseMappable>(object: T) where T.DatabaseType: RealmObject {
        self.delete(objects: [object])
    }

    public func delete<T: DatabaseMappable>(objects: [T]) where T.DatabaseType: RealmObject {
        self.writeWorker.execute {
            realmOperator in
            try? realmOperator.write {
                transaction in
                transaction.delete(objects)
            }
        }
    }

    public func deleteAll<T: DatabaseMappable>(objectsOf type: T.Type) where T.DatabaseType: RealmObject {
        self.writeWorker.execute {
            realmOperator in
            try? realmOperator.write {
                transaction in
                transaction.deleteAll(objectsOf: type)
            }
        }
    }

    public func fetch<T: DatabaseMappable>(objectsOf type: T.Type,
                                           with filter: DatabaseFilterType = .unfiltered,
                                           with sort: DatabaseSortType = .unsorted,
                                           callback: @escaping (Array<T>) -> Void) where T.DatabaseType: RealmObject {
        let worker = self.nextWorker()

        worker.execute {
            realmOperator in
            let values = realmOperator.values(ofType: type).filter(filter).sort(sort).compactMap({ try? T.createMappable(from: $0) })
            let result: Array<T> = Array(values)
            DispatchQueue.main.async {
                callback(result)
            }
        }
    }

    public func syncFetch<T: DatabaseMappable>(objectsOf type: T.Type,
                                               with filter: DatabaseFilterType = .unfiltered,
                                               with sort: DatabaseSortType = .unsorted) -> Array<T> where T.DatabaseType: RealmObject {
        let realm = try! Realm()
        let syncOperator = RealmOperator(realm: realm)
        let values = syncOperator.values(ofType: type).filter(filter).sort(sort).compactMap({ try? T.createMappable(from: $0) })
        return Array(values)
    }

    public func fetch<T: DatabaseMappable>(objectsOf type: T.Type,
                                           with filter: DatabaseFilterType = .unfiltered,
                                           with sort: DatabaseSortType = .unsorted,
                                           callback: @escaping (Array<T>) -> Void,
                                           updates: @escaping (DatabaseObserveUpdate<T>) -> Void) -> DatabaseUpdatesToken where T.DatabaseType: RealmObject {
        let token = DatabaseUpdatesToken {}

        let worker = self.nextWorker()

        worker.execute {
            realmOperator in

            if token.isInvalidated { return }

            let results = realmOperator.values(ofType: type).filter(filter).sort(sort)

            let rToken = results.observe {
                change in

                switch change {
                case let .initial(newResults):
                    let values = Array(newResults.compactMap({ try? T.createMappable(from: $0) }))
                    let result: Array<T> = Array(values)
                    DispatchQueue.main.async {
                        callback(result)
                    }
                case let .update(newResults, deletions, insertions, modifications):
                    let values = Array(newResults.compactMap({ try? T.createMappable(from: $0) }))
                    DispatchQueue.main.async {
                        let update = DatabaseObserveUpdate(values: values,
                                                           deletions: deletions,
                                                           insertions: insertions,
                                                           modifications: modifications)
                        updates(update)
                    }
                case .error(_):
                    break
                }
            }

            token.invalidation = { rToken.invalidate() }
        }

        return token
    }

    public func fetch<T: DatabaseMappable>(objectOf type: T.Type,
                                           withPrimaryKey key: PrimaryKeyContainer,
                                           callback: @escaping (T?) -> Void) where T.DatabaseType: RealmObject {

        let worker = self.nextWorker()

        worker.execute {
            realmOperator in
            let value = realmOperator.value(ofType: type, withPrimaryKey: key).flatMap({ try? T.createMappable(from: $0) })
            DispatchQueue.main.async {
                callback(value)
            }
        }
    }

    public func syncFetch<T: DatabaseMappable>(objectOf type: T.Type,
                                               withPrimaryKey key: PrimaryKeyContainer) -> T? where T.DatabaseType: RealmObject {
        let realm = try! Realm()
        let syncOperator = RealmOperator(realm: realm)
        let value = syncOperator.value(ofType: type, withPrimaryKey: key).flatMap({ try? T.createMappable(from: $0) })
        return value
    }

    public func fetch<T: DatabaseMappable>(objectOf type: T.Type,
                                           withPrimaryKey key: PrimaryKeyContainer,
                                           callback: @escaping (T?) -> Void,
                                           updates: @escaping (DatabaseObjectUpdate<T>) -> Void) -> DatabaseUpdatesToken where T.DatabaseType: RealmObject {

        let token = DatabaseUpdatesToken {}

        let worker = self.nextWorker()

        worker.execute {
            realmOperator in

            if token.isInvalidated { return }

            let value = realmOperator.value(ofType: type, withPrimaryKey: key)
            let object: T? = value.flatMap { try? T.createMappable(from: $0) }
            DispatchQueue.main.async {
                callback(object)
            }

            let rToken = value?.observe {
                change in
                switch change {
                case .change:
                    guard let object = value.flatMap({ try? T.createMappable(from: $0) }) else { return }
                    DispatchQueue.main.async {
                        updates(DatabaseObjectUpdate.update(object: object))
                    }
                case .deleted:
                    DispatchQueue.main.async {
                        updates(DatabaseObjectUpdate.delete)
                    }
                case .error:
                    break
                }
            }

            token.invalidation = { rToken?.invalidate() }
        }

        return token
    }
}


class DatabaseRealmBackgroundWorker: DatabaseBackgroundWorker {
    private lazy var realm: Realm = {
        return try! Realm(configuration: self.configuration)
    }()

    private lazy var realmOperator: RealmOperator = {
        return RealmOperator(realm: self.realm)
    }()

    private let configuration: Realm.Configuration

    private var runningCount = 0
    private let runningCountQueue = DispatchQueue(label: "mm.databaseService.runningCountQueue", qos: .utility)

    var isWorking: Bool {
        return runningCount > 0
    }

    init(configuration: Realm.Configuration) {
        self.configuration = configuration
        super.init()
    }

    typealias RealmBlock = @convention(block) (RealmOperator) -> Void

    @objc private func run(realmBlock: RealmBlock) {
        realmBlock(self.realmOperator)
        runningCountQueue.async { self.runningCount -= 1 }
    }

    internal func execute(realmBlock: @escaping RealmBlock) {
        runningCountQueue.async { self.runningCount += 1 }
        perform(#selector(run(realmBlock:)),
                on: thread,
                with: realmBlock,
                waitUntilDone: false,
                modes: [RunLoopMode.defaultRunLoopMode.rawValue])
    }
}