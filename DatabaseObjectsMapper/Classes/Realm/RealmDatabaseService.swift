//
// Created by Mikhail Mulyar on 02/01/2018.
// Copyright (c) 2018 Mikhail Mulyar. All rights reserved.
//

import RealmSwift


typealias RealmObject = Object


public class RealmDatabaseService {
    private var realm: Realm!
    private var realm2: Realm!
    private var realm3: Realm!

    private lazy var realmOperator: RealmOperator = {
        return RealmOperator(realm: self.realm)
    }()
    private lazy var realmOperator2: RealmOperator = {
        return RealmOperator(realm: self.realm2)
    }()
    private lazy var realmOperator3: RealmOperator = {
        return RealmOperator(realm: self.realm3)
    }()


    private let worker = DatabaseBackgroundWorker()
    private let worker2 = DatabaseBackgroundWorker()
    private let worker3 = DatabaseBackgroundWorker()

    init(configuration: Realm.Configuration = Realm.Configuration.defaultConfiguration) {
        self.worker.start {
            self.realm = try! Realm(configuration: configuration)
        }
        self.worker2.start {
            self.realm2 = try! Realm(configuration: configuration)
        }
        self.worker3.start {
            self.realm3 = try! Realm(configuration: configuration)
        }
    }

    deinit {

    }

    private var counter = 0

    func nextWorker() -> (DatabaseBackgroundWorker, RealmOperator) {
        counter += 1
        if counter > 2 { counter == 0 }

        switch counter {
        case 1:
            return (self.worker2, self.realmOperator2)
        case 2:
            return (self.worker3, self.realmOperator3)
        default:
            return (self.worker, self.realmOperator)
        }
    }

    func deleteAll() {
        self.worker.execute {
            [unowned self] in
            try? self.realmOperator.write {
                transaction in
                transaction.deleteAll()
            }
        }
    }

    func store<T: DatabaseMappable>(object: T, update: Bool = true) where T.DatabaseType: Object {
        self.store(objects: [object])
    }

    func store<T: DatabaseMappable>(objects: [T], update: Bool = true) where T.DatabaseType: Object {
        self.worker.execute {
            [unowned self] in
            try? self.realmOperator.write {
                transaction in
                try? transaction.add(objects, update: update)
            }
        }
    }

    func update<T: DatabaseMappable>(object: T) where T.DatabaseType: Object {
        self.update(objects: [object])
    }

    func update<T: DatabaseMappable>(objects: [T]) where T.DatabaseType: Object {
        self.worker.execute {
            [unowned self] in
            try? self.realmOperator.write {
                transaction in
                try? transaction.update(objects)
            }
        }
    }

    func update<T: DatabaseMappable>(objectOf type: T.Type,
                                     withPrimaryKey key: PrimaryKeyValue,
                                     updates: T.DatabaseUpdates) where T.DatabaseType: Object {
        self.worker.execute {
            [unowned self] in
            try? self.realmOperator.write {
                transaction in
                transaction.update(objectOf: type, withPrimaryKey: key, updates: updates)
            }
        }
    }

    func update<T: DatabaseMappable>(objectOf type: T.Type,
                                     withPrimaryKey key: PrimaryKeyValue,
                                     relationships: [DatabaseRelationshipUpdate]) where T.DatabaseType: Object {
        self.worker.execute {
            [unowned self] in
            try? self.realmOperator.write {
                transaction in
                transaction.update(objectOf: type, withPrimaryKey: key, relationships: relationships)
            }
        }
    }

    func update<T: DatabaseMappable>(objectOf type: T.Type,
                                     withPrimaryKey key: PrimaryKeyValue,
                                     updates: T.DatabaseUpdates,
                                     relationships: [DatabaseRelationshipUpdate]) where T.DatabaseType: Object {
        self.worker.execute {
            [unowned self] in
            try? self.realmOperator.write {
                transaction in
                transaction.update(objectOf: type, withPrimaryKey: key, updates: updates)
                transaction.update(objectOf: type, withPrimaryKey: key, relationships: relationships)
            }
        }
    }

    func delete<T: DatabaseMappable>(object: T) where T.DatabaseType: Object {
        self.delete(objects: [object])
    }

    func delete<T: DatabaseMappable>(objects: [T]) where T.DatabaseType: Object {
        self.worker.execute {
            [unowned self] in
            try? self.realmOperator.write {
                transaction in
                transaction.delete(objects)
            }
        }
    }

    func deleteAll<T: DatabaseMappable>(objectsOf type: T.Type) where T.DatabaseType: Object {
        self.worker.execute {
            [unowned self] in
            try? self.realmOperator.write {
                transaction in
                transaction.deleteAll(objectsOf: type)
            }
        }
    }

    func fetch<T: DatabaseMappable>(objectsOf type: T.Type,
                                    with filter: DatabaseFilterType = .unfiltered,
                                    with sort: DatabaseSortType = .unsorted,
                                    callback: @escaping (Array<T>) -> Void) where T.DatabaseType: Object {
        self.worker.execute {
            [unowned self] in
            let values = self.realmOperator.values(ofType: type).filter(filter).sort(sort).flatMap({ try? T.createMappable(from: $0) })
            DispatchQueue.main.async {
                callback(Array(values))
            }
        }
    }

    func syncFetch<T: DatabaseMappable>(objectsOf type: T.Type,
                                        with filter: DatabaseFilterType = .unfiltered,
                                        with sort: DatabaseSortType = .unsorted) -> Array<T> where T.DatabaseType: Object {
        let syncOperator = RealmOperator(realm: try! Realm())
        let values = syncOperator.values(ofType: type).filter(filter).sort(sort).flatMap({ try? T.createMappable(from: $0) })
        return Array(values)
    }

    func fetch<T: DatabaseMappable>(objectsOf type: T.Type,
                                    with filter: DatabaseFilterType,
                                    with sort: DatabaseSortType,
                                    callback: @escaping (Array<T>) -> Void,
                                    updates: @escaping (DatabaseObserveUpdate<T>) -> Void) -> DatabaseUpdatesToken where T.DatabaseType: Object {
        let token = DatabaseUpdatesToken {}

        let nextWorker: (DatabaseBackgroundWorker, RealmOperator) = self.nextWorker()

        nextWorker.0.execute {
            [unowned self] in
            if token.isInvalidated { return }

            let results = nextWorker.1.values(ofType: type).filter(filter).sort(sort)

            let rToken = results.observe {
                change in

                switch change {
                case let .initial(newResults):
                    let values = Array(newResults.flatMap({ try? T.createMappable(from: $0) }))
                    DispatchQueue.main.async {
                        callback(values)
                    }
                case let .update(newResults, deletions, insertions, modifications):
                    let values = Array(newResults.flatMap({ try? T.createMappable(from: $0) }))
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

    func fetch<T: DatabaseMappable>(objectOf type: T.Type,
                                    withPrimaryKey key: PrimaryKeyValue,
                                    callback: @escaping (T?) -> Void) where T.DatabaseType: Object {
        self.worker.execute {
            [unowned self] in
            let value = self.realmOperator.value(ofType: type, withPrimaryKey: key).flatMap({ try? T.createMappable(from: $0) })
            DispatchQueue.main.async {
                callback(value)
            }
        }
    }

    func syncFetch<T: DatabaseMappable>(objectOf type: T.Type,
                                        withPrimaryKey key: PrimaryKeyValue) -> T? where T.DatabaseType: Object {
        let syncOperator = RealmOperator(realm: try! Realm())
        let value = syncOperator.value(ofType: type, withPrimaryKey: key).flatMap({ try? T.createMappable(from: $0) })
        return value
    }

    func fetch<T: DatabaseMappable>(objectOf type: T.Type,
                                    withPrimaryKey key: PrimaryKeyValue,
                                    callback: @escaping (T?) -> Void,
                                    updates: @escaping (DatabaseObjectUpdate<T>) -> Void) -> DatabaseUpdatesToken where T.DatabaseType: Object {

        let token = DatabaseUpdatesToken {}

        self.worker.execute {
            [unowned self] in
            if token.isInvalidated { return }

            let value = self.realmOperator.value(ofType: type, withPrimaryKey: key)
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