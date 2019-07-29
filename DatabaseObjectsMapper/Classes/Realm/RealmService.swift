//
// Created by Mikhail Mulyar on 02/01/2018.
// Copyright (c) 2018 Mikhail Mulyar. All rights reserved.
//

import RealmSwift


public typealias RealmObject = Object


open class RealmService {

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
    // MARK: Managing

    public func deleteAll() {
        self.writeWorker.execute {
            realmOperator in
            try? realmOperator.write {
                transaction in
                transaction.deleteAll()
            }
        }
    }

    public func simpleSave<T: DatabaseMappable>(model: T) where T.Container: RealmObject {
        self.simpleSave(models: [model])
    }

    public func simpleSave<T: DatabaseMappable>(models: [T]) where T.Container: RealmObject {
        self.writeWorker.execute {
            realmOperator in
            try? realmOperator.write {
                transaction in
                try? transaction.add(models, update: false)
            }
        }
    }

    public func save<T: UniquelyMappable>(model: T, update: Bool = true) where T.Container: RealmObject {
        self.save(models: [model])
    }

    public func save<T: UniquelyMappable>(models: [T], update: Bool = true) where T.Container: RealmObject {
        self.writeWorker.execute {
            realmOperator in
            try? realmOperator.write {
                transaction in
                try? transaction.add(models, update: update)
            }
        }
    }

    public func save<T: UniquelyMappable, R: UniquelyMappable>(model: T,
                                                               update: Bool = true,
                                                               relation: Relation<R>,
                                                               with relationUpdate: Relation<R>.Update)
            where T.Container: RealmObject, R.Container: RealmObject {
        self.writeWorker.execute {
            realmOperator in
            try? realmOperator.write {
                transaction in
                try? transaction.add([model], update: update)
                transaction.updateRelation(relation, in: model, with: relationUpdate)
            }
        }
    }


    public func update<T: UniquelyMappable>(model: T) where T.Container: RealmObject {
        self.update(models: [model])
    }

    public func update<T: UniquelyMappable>(models: [T]) where T.Container: RealmObject {
        self.writeWorker.execute {
            realmOperator in
            try? realmOperator.write {
                transaction in
                try? transaction.update(models)
            }
        }
    }

    public func update<T: UniquelyMappable>(modelOf type: T.Type, with key: T.ID, updates: [String: Any?]) where T.Container: RealmObject {
        self.writeWorker.execute {
            realmOperator in
            try? realmOperator.write {
                transaction in
                transaction.update(modelOf: type, with: key, updates: updates)
            }
        }
    }

    public func updateRelation<T: UniquelyMappable, R: UniquelyMappable>(_ relation: Relation<R>, in model: T, with update: Relation<R>.Update)
            where T.Container: RealmObject, R.Container: RealmObject {
        self.writeWorker.execute {
            realmOperator in
            try? realmOperator.write {
                transaction in
                transaction.updateRelation(relation, in: model, with: update)
            }
        }
    }

    public func delete<T: UniquelyMappable>(model: T) where T.Container: RealmObject {
        self.delete(models: [model])
    }

    public func delete<T: UniquelyMappable>(models: [T]) where T.Container: RealmObject {
        self.writeWorker.execute {
            realmOperator in
            try? realmOperator.write {
                transaction in
                transaction.delete(models)
            }
        }
    }

    public func deleteAll<T: DatabaseMappable>(modelsOf type: T.Type) where T.Container: RealmObject {
        self.writeWorker.execute {
            realmOperator in
            try? realmOperator.write {
                transaction in
                transaction.deleteAll(modelsOf: type)
            }
        }
    }

    // MARK: Fetching

    public func fetch<T: DatabaseMappable>(with filter: DatabaseFilterType = .unfiltered,
                                           with sort: DatabaseSortType = .unsorted,
                                           callback: @escaping ([T]) -> Void) where T.Container: RealmObject {
        let worker = self.nextWorker()

        worker.execute {
            realmOperator in
            let values = realmOperator.values(ofType: T.self).filter(filter).sort(sort).compactMap({ try? T.mappable(for: $0) })
            let result: [T] = Array(values)
            DispatchQueue.main.async {
                callback(result)
            }
        }
    }

    public func syncFetch<T: DatabaseMappable>(with filter: DatabaseFilterType = .unfiltered,
                                               with sort: DatabaseSortType = .unsorted) -> [T] where T.Container: RealmObject {
        let realm = try! Realm()
        let syncOperator = RealmOperator(realm: realm)
        let values = syncOperator.values(ofType: T.self).filter(filter).sort(sort).compactMap({ try? T.mappable(for: $0) })
        return Array(values)
    }

    public func fetch<T: DatabaseMappable>(with filter: DatabaseFilterType = .unfiltered,
                                           with sort: DatabaseSortType = .unsorted,
                                           callback: @escaping ([T]) -> Void,
                                           updates: @escaping (DatabaseObserveUpdate<T>) -> Void)
                    -> DatabaseUpdatesToken where T.Container: RealmObject {
        let token = DatabaseUpdatesToken {}

        let worker = self.nextWorker()

        worker.execute {
            realmOperator in

            if token.isInvalidated { return }

            let results = realmOperator.values(ofType: T.self).filter(filter).sort(sort)

            let rToken = results.observe {
                change in

                switch change {
                case let .initial(newResults):
                    let values = Array(newResults.compactMap({ try? T.mappable(for: $0) }))
                    let result: [T] = Array(values)
                    DispatchQueue.main.async {
                        callback(result)
                    }
                case let .update(newResults, deletions, insertions, modifications):
                    let values = Array(newResults.compactMap({ try? T.mappable(for: $0) }))
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

    public func fetch<T: UniquelyMappable>(with key: T.ID, callback: @escaping (T?) -> Void) where T.Container: RealmObject {

        let worker = self.nextWorker()

        worker.execute {
            realmOperator in
            let value = realmOperator.value(ofType: T.self, with: key).flatMap({ try? T.mappable(for: $0) })
            DispatchQueue.main.async {
                callback(value)
            }
        }
    }

    public func syncFetchUnique<T: UniquelyMappable>(with key: T.ID) -> T? where T.Container: RealmObject {
        let realm = try! Realm()
        let syncOperator = RealmOperator(realm: realm)
        let value = syncOperator.value(ofType: T.self, with: key).flatMap({ try? T.mappable(for: $0) })
        return value
    }

    public func fetch<T: UniquelyMappable>(with key: T.ID, callback: @escaping (T?) -> Void, updates: @escaping (DatabaseModelUpdate<T>) -> Void)
                    -> DatabaseUpdatesToken where T.Container: RealmObject {

        let token = DatabaseUpdatesToken {}

        let worker = self.nextWorker()

        worker.execute {
            realmOperator in

            if token.isInvalidated { return }

            let value = realmOperator.value(ofType: T.self, with: key)
            let object: T? = value.flatMap { try? T.mappable(for: $0) }
            DispatchQueue.main.async {
                callback(object)
            }

            let rToken = value?.observe {
                change in
                switch change {
                case .change:
                    guard let object = value.flatMap({ try? T.mappable(for: $0) }) else { return }
                    DispatchQueue.main.async {
                        updates(DatabaseModelUpdate.update(model: object))
                    }
                case .deleted:
                    DispatchQueue.main.async {
                        updates(DatabaseModelUpdate.delete)
                    }
                case .error:
                    break
                }
            }

            token.invalidation = { rToken?.invalidate() }
        }

        return token
    }

    // MARK: Relations

    public func fetchRelation<T: UniquelyMappable, R: UniquelyMappable>(_ relation: Relation<R>,
                                                                        in model: T,
                                                                        with filter: DatabaseFilterType = .unfiltered,
                                                                        with sort: DatabaseSortType = .unsorted,
                                                                        callback: @escaping ([R]) -> Void)
            where T.Container: Object, R.Container: Object {
        let worker = self.nextWorker()

        worker.execute {
            realmOperator in
            guard let values = realmOperator.relationValues(relation, in: model)?
                                            .filter(filter)
                                            .sort(sort)
                                            .compactMap({ try? R.mappable(for: $0) }) else {
                DispatchQueue.main.async {
                    callback([])
                }
                return
            }
            let result: Array<R> = Array(values)
            DispatchQueue.main.async {
                relation.cachedValue = result
                callback(result)
            }
        }
    }

    public func syncFetchRelation<T: UniquelyMappable, R: UniquelyMappable>(_ relation: Relation<R>,
                                                                            in model: T,
                                                                            with filter: DatabaseFilterType = .unfiltered,
                                                                            with sort: DatabaseSortType = .unsorted) -> [R]
            where T.Container: Object, R.Container: Object {
        let realm = try! Realm()
        let syncOperator = RealmOperator(realm: realm)
        guard let values = syncOperator.relationValues(relation, in: model)?
                                       .filter(filter)
                                       .sort(sort)
                                       .compactMap({ try? R.mappable(for: $0) }) else {
            return []
        }
        let result = Array(values)
        relation.cachedValue = result
        return result
    }

    public func fetchRelation<T: UniquelyMappable, R: UniquelyMappable>(_ relation: Relation<R>,
                                                                        in model: T,
                                                                        with filter: DatabaseFilterType = .unfiltered,
                                                                        with sort: DatabaseSortType = .unsorted,
                                                                        callback: @escaping ([R]) -> Void,
                                                                        updates: @escaping (DatabaseObserveUpdate<R>) -> Void) -> DatabaseUpdatesToken
            where T.Container: Object, R.Container: Object {
        let token = DatabaseUpdatesToken {}

        let worker = self.nextWorker()

        worker.execute {
            realmOperator in

            if token.isInvalidated { return }

            guard let results = realmOperator.relationValues(relation, in: model)?.filter(filter).sort(sort) else {
                DispatchQueue.main.async {
                    callback([])
                }
                return
            }

            let rToken = results.observe {
                change in

                switch change {
                case let .initial(newResults):
                    let values = Array(newResults.compactMap({ try? R.mappable(for: $0) }))
                    let result: [R] = Array(values)
                    DispatchQueue.main.async {
                        relation.cachedValue = result
                        callback(result)
                    }
                case let .update(newResults, deletions, insertions, modifications):
                    let values = Array(newResults.compactMap({ try? R.mappable(for: $0) }))
                    DispatchQueue.main.async {
                        let update = DatabaseObserveUpdate(values: values,
                                                           deletions: deletions,
                                                           insertions: insertions,
                                                           modifications: modifications)
                        relation.cachedValue = values
                        updates(update)
                    }
                case .error: break
                }
            }

            token.invalidation = { rToken.invalidate() }
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
                modes: [RunLoop.Mode.default.rawValue])
    }
}