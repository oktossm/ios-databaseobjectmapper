//
// Created by Mikhail Mulyar on 02/01/2018.
// Copyright (c) 2018 Mikhail Mulyar. All rights reserved.
//

import RealmSwift


public typealias RealmObject = Object
public typealias MinMaxType = RealmSwift.MinMaxType
public typealias AddableType = RealmSwift.AddableType


public extension DatabaseMappable {
    typealias Query = (RealmSwift.Query<Container>) -> RealmSwift.Query<Bool>
}


open class RealmService {

    fileprivate let configuration: Realm.Configuration

    fileprivate lazy var writeWorker = DatabaseRealmBackgroundWorker(configuration: configuration,
                                                                     queue: DispatchQueue(label: "mm.databaseService.writeQueue"))
    private lazy var readWorkers = (1...3).map {
        _ in
        DatabaseRealmBackgroundWorker(configuration: configuration, queue: DispatchQueue(label: "mm.databaseService.readQueue"))
    }

    private var readWorker: DatabaseRealmBackgroundWorker {
        readWorkers.randomElement()!
    }

    fileprivate var isBatchWriting = false
    fileprivate var batchBlocks = [RealmBlock]()

    fileprivate let batchQueue = DispatchQueue(label: "mm.databaseService.writeQueue")

    public init(configuration: Realm.Configuration = Realm.Configuration.defaultConfiguration) {
        self.configuration = configuration
    }

    func syncOperator() -> RealmOperator {
        let realm = try! Realm(configuration: configuration)
        return RealmOperator(realm: realm)
    }

    func processRealmBlock(_ block: @escaping RealmBlock, sync: Bool = false) {
        if isBatchWriting {
            batchQueue.sync {
                batchBlocks.append(block)
            }
        } else if sync {
            block(syncOperator())
        } else {
            writeWorker.execute(realmBlock: block)
        }
    }
}


// MARK: Batch writes
open class RealmBatchService: RealmService {
    fileprivate func beginBatchWrites() {
        batchQueue.sync {
            isBatchWriting = true
        }
    }

    public func commitBatchWrites(sync: Bool = false) {
        batchQueue.sync {
            isBatchWriting = false
            if sync {
                let syncOperator = syncOperator()
                syncOperator.beginWrite()
                batchBlocks.forEach { $0(syncOperator) }
                try? syncOperator.commitWrite()
            } else {
                writeWorker.execute(realmBlocks: batchBlocks)
                writeWorker.execute { _ in
                    // retain self until writes completed
                    _ = self
                }
            }
            batchBlocks.removeAll()
        }
    }
}


extension RealmService {
    // MARK: Batch writes
    public func startBatchService() -> RealmBatchService {
        let service = RealmBatchService(configuration: configuration)
        service.beginBatchWrites()

        return service
    }

    public func withBatchWrites(_ batchWrites: (RealmService) -> Void, sync: Bool = false) {
        let batchService = startBatchService()
        batchWrites(batchService)
        batchService.commitBatchWrites(sync: sync)
    }

    // MARK: Managing
    public func deleteAll(sync: Bool = false) {
        let block: RealmBlock = {
            realmOperator in
            try? realmOperator.write {
                transaction in
                transaction.deleteAll()
            }
        }
        processRealmBlock(block, sync: sync)
    }

    public func simpleSave<T: DatabaseMappable>(model: T, sync: Bool = false) where T.Container: RealmObject {
        simpleSave(models: [model], sync: sync)
    }

    public func simpleSave<T: DatabaseMappable>(models: [T], sync: Bool = false) where T.Container: RealmObject {
        let block: RealmBlock = {
            realmOperator in
            try? realmOperator.write {
                transaction in
                try? transaction.add(models, update: false)
            }
        }
        processRealmBlock(block, sync: sync)
    }

    public func save<T: UniquelyMappable>(model: T, update: Bool = true, sync: Bool = false) where T.Container: RealmObject {
        save(models: [model], update: update, sync: sync)
    }

    public func save<T: UniquelyMappable>(models: [T], update: Bool = true, sync: Bool = false) where T.Container: RealmObject {
        let block: RealmBlock = {
            realmOperator in
            try? realmOperator.write {
                transaction in
                try? transaction.add(models, update: update)
            }
        }
        processRealmBlock(block, sync: sync)
    }

    public func saveSkippingRelations<T: UniquelyMappable>(model: T, sync: Bool = false) where T.Container: RealmObject {
        saveSkippingRelations(models: [model], sync: sync)
    }

    public func saveSkippingRelations<T: UniquelyMappable>(models: [T], sync: Bool = false) where T.Container: RealmObject {
        let block: RealmBlock = {
            realmOperator in
            try? realmOperator.write {
                transaction in
                try? transaction.addSkippingRelations(models)
            }
        }
        processRealmBlock(block, sync: sync)
    }

    public func save<T: UniquelyMappable, R: UniquelyMappable>(model: T,
                                                               update: Bool = true,
                                                               relation: Relation<R>,
                                                               with relationUpdate: Relation<R>.Update,
                                                               sync: Bool = false)
        where T.Container: RealmObject, R.Container: RealmObject {

        let block: RealmBlock = {
            realmOperator in
            try? realmOperator.write {
                transaction in
                try? transaction.add([model], update: update)
                transaction.updateRelation(relation, in: model, with: relationUpdate)
            }
        }
        processRealmBlock(block, sync: sync)
    }

    public func update<T: UniquelyMappable>(model: T, sync: Bool = false) where T.Container: RealmObject {
        update(models: [model], sync: sync)
    }

    public func update<T: UniquelyMappable>(model: T, sync: Bool = false, skipRelations: Bool = false) where T.Container: RealmObject {
        update(models: [model], sync: sync, skipRelations: skipRelations)
    }

    public func update<T: UniquelyMappable>(models: [T], sync: Bool = false, skipRelations: Bool = false) where T.Container: RealmObject {

        let block: RealmBlock = {
            realmOperator in
            try? realmOperator.write {
                transaction in
                try? transaction.update(models, skipRelations: skipRelations)
            }
        }
        processRealmBlock(block, sync: sync)
    }

    public func update<T: UniquelyMappable>(modelOf type: T.Type,
                                            with key: T.ID,
                                            updates: [String: Any?],
                                            sync: Bool = false) where T.Container: RealmObject {

        let block: RealmBlock = {
            realmOperator in
            try? realmOperator.write {
                transaction in
                transaction.update(modelOf: type, with: key, updates: updates)
            }
        }
        processRealmBlock(block, sync: sync)
    }

    public func update<T: UniquelyMappable & KeyPathConvertible>(modelOf type: T.Type,
                                                                 with key: T.ID,
                                                                 updates: [RootKeyPathUpdate<T>],
                                                                 sync: Bool = false) where T.Container: RealmObject {

        let updates = Dictionary(updates.map { $0.update }) { _, last in last }
        update(modelOf: type, with: key, updates: updates, sync: sync)
    }

    public func updateSingleRelation<T: UniquelyMappable & KeyPathConvertible, R: UniquelyMappable>(in model: T,
                                                                                                    for keyPath: KeyPath<T, R>,
                                                                                                    relationId: R.ID?,
                                                                                                    sync: Bool = false)
        where T.Container: RealmObject, R.Container: RealmObject {

        let block: RealmBlock = {
            realmOperator in
            try? realmOperator.write {
                transaction in
                transaction.updateSingleRelation(in: model, for: keyPath, relationOf: R.self, relationId: relationId)
            }
        }
        processRealmBlock(block, sync: sync)
    }

    public func updateRelation<T: UniquelyMappable, R: UniquelyMappable>(_ relation: Relation<R>,
                                                                         in model: T,
                                                                         with update: Relation<R>.Update,
                                                                         sync: Bool = false)
        where T.Container: RealmObject, R.Container: RealmObject {

        let block: RealmBlock = {
            realmOperator in
            try? realmOperator.write {
                transaction in
                transaction.updateRelation(relation, in: model, with: update)
            }
        }
        processRealmBlock(block, sync: sync)
    }

    public func updateRelation<T: UniquelyMappable, R: DatabaseMappable>(_ relation: EmbeddedRelation<R>,
                                                                         in model: T,
                                                                         with update: EmbeddedRelation<R>.Update,
                                                                         sync: Bool = false)
        where T.Container: RealmObject, R.Container: ObjectBase & RealmCollectionValue {

        let block: RealmBlock = {
            realmOperator in
            try? realmOperator.write {
                transaction in
                transaction.updateRelation(relation, in: model, with: update)
            }
        }
        processRealmBlock(block, sync: sync)
    }

    public func delete<T: UniquelyMappable>(model: T, sync: Bool = false) where T.Container: RealmObject {
        delete(models: [model], sync: sync)
    }

    public func delete<T: UniquelyMappable>(models: [T], sync: Bool = false) where T.Container: RealmObject {

        let block: RealmBlock = {
            realmOperator in
            try? realmOperator.write {
                transaction in
                transaction.delete(models)
            }
        }
        processRealmBlock(block, sync: sync)
    }

    public func deleteAll<T: DatabaseMappable>(modelsOf type: T.Type, sync: Bool = false) where T.Container: RealmObject {

        let block: RealmBlock = {
            realmOperator in
            try? realmOperator.write {
                transaction in
                transaction.deleteAll(modelsOf: type)
            }
        }
        processRealmBlock(block, sync: sync)
    }


    // MARK: Fetching
    public func count<T: DatabaseMappable>
        (for model: T.Type,
         with filter: DatabaseFilterType<T> = .unfiltered,
         callback: @escaping (Int) -> Void) where T.Container: RealmObject {

        readWorker.execute {
            realmOperator in
            let value = realmOperator.values(ofType: T.self).filter(filter).count
            DispatchQueue.main.async {
                callback(value)
            }
        }
    }

    public func count<T: DatabaseMappable>
        (for model: T.Type,
         with filter: DatabaseFilterType<T> = .unfiltered,
         callback: @escaping (Int) -> Void,
         updates: @escaping (Int) -> Void) -> DatabaseUpdatesToken where T.Container: RealmObject {
        objects(for: model, with: filter, callback: {
            let count = $0.count
            DispatchQueue.main.async {
                callback(count)
            }
        }, updates: {
            let count = $0.count
            DispatchQueue.main.async {
                updates(count)
            }
        })
    }

    public func min<T: DatabaseMappable & KeyPathConvertible, R: _HasPersistedType>
        (with filter: DatabaseFilterType<T> = .unfiltered,
         for keyPath: KeyPath<T, R>,
         callback: @escaping (R?) -> Void) where T.Container: RealmObject, R.PersistedType: MinMaxType {

        readWorker.execute {
            realmOperator in
            let value: R? = realmOperator.values(ofType: T.self).filter(filter).min(ofProperty: T.key(for: keyPath))
            DispatchQueue.main.async {
                callback(value)
            }
        }
    }

    public func min<T: DatabaseMappable & KeyPathConvertible, R: _HasPersistedType>
        (with filter: DatabaseFilterType<T> = .unfiltered,
         for keyPath: KeyPath<T, R>,
         callback: @escaping (R?) -> Void,
         updates: @escaping (R?) -> Void) -> DatabaseUpdatesToken where T.Container: RealmObject, R.PersistedType: MinMaxType {
        objects(for: T.self, with: filter,
                callback: {
                    let value: R? = $0.min(ofProperty: T.key(for: keyPath))
                    DispatchQueue.main.async {
                        callback(value)
                    }
                },
                updates: {
                    let value: R? = $0.min(ofProperty: T.key(for: keyPath))
                    DispatchQueue.main.async {
                        updates(value)
                    }
                })
    }

    public func max<T: DatabaseMappable & KeyPathConvertible, R: _HasPersistedType>
        (with filter: DatabaseFilterType<T> = .unfiltered,
         for keyPath: KeyPath<T, R>,
         callback: @escaping (R?) -> Void) where T.Container: RealmObject, R.PersistedType: MinMaxType {

        readWorker.execute {
            realmOperator in
            let value: R? = realmOperator.values(ofType: T.self).filter(filter).max(ofProperty: T.key(for: keyPath))
            DispatchQueue.main.async {
                callback(value)
            }
        }
    }

    public func max<T: DatabaseMappable & KeyPathConvertible, R: _HasPersistedType>
        (with filter: DatabaseFilterType<T> = .unfiltered,
         for keyPath: KeyPath<T, R>,
         callback: @escaping (R?) -> Void,
         updates: @escaping (R?) -> Void) -> DatabaseUpdatesToken where T.Container: RealmObject, R.PersistedType: MinMaxType {
        objects(for: T.self, with: filter,
                callback: {
                    let value: R? = $0.max(ofProperty: T.key(for: keyPath))
                    DispatchQueue.main.async {
                        callback(value)
                    }
                },
                updates: {
                    let value: R? = $0.max(ofProperty: T.key(for: keyPath))
                    DispatchQueue.main.async {
                        updates(value)
                    }
                })
    }

    public func sum<T: DatabaseMappable & KeyPathConvertible, R: _HasPersistedType>
        (with filter: DatabaseFilterType<T> = .unfiltered,
         for keyPath: KeyPath<T, R>,
         callback: @escaping (R) -> Void) where T.Container: RealmObject, R.PersistedType: AddableType {

        readWorker.execute {
            realmOperator in
            let value: R = realmOperator.values(ofType: T.self).filter(filter).sum(ofProperty: T.key(for: keyPath))
            DispatchQueue.main.async {
                callback(value)
            }
        }
    }

    public func sum<T: DatabaseMappable & KeyPathConvertible, R: _HasPersistedType>
        (with filter: DatabaseFilterType<T> = .unfiltered,
         for keyPath: KeyPath<T, R>,
         callback: @escaping (R) -> Void,
         updates: @escaping (R) -> Void) -> DatabaseUpdatesToken where T.Container: RealmObject, R.PersistedType: AddableType {
        objects(for: T.self, with: filter,
                callback: {
                    let value: R = $0.sum(ofProperty: T.key(for: keyPath))
                    DispatchQueue.main.async {
                        callback(value)
                    }
                },
                updates: {
                    let value: R = $0.sum(ofProperty: T.key(for: keyPath))
                    DispatchQueue.main.async {
                        updates(value)
                    }
                })
    }

    public func average<T: DatabaseMappable & KeyPathConvertible, R: _HasPersistedType>
        (with filter: DatabaseFilterType<T> = .unfiltered,
         for keyPath: KeyPath<T, R>,
         callback: @escaping (Double?) -> Void)
        where T.Container: RealmObject, R.PersistedType: AddableType {

        readWorker.execute {
            realmOperator in
            let value: Double? = realmOperator.values(ofType: T.self).filter(filter).average(ofProperty: T.key(for: keyPath))
            DispatchQueue.main.async {
                callback(value)
            }
        }
    }

    public func average<T: DatabaseMappable & KeyPathConvertible, R: _HasPersistedType>
        (with filter: DatabaseFilterType<T> = .unfiltered,
         for keyPath: KeyPath<T, R>,
         callback: @escaping (Double?) -> Void,
         updates: @escaping (Double?) -> Void) -> DatabaseUpdatesToken where T.Container: RealmObject, R.PersistedType: AddableType {
        objects(for: T.self, with: filter,
                callback: {
                    let value: Double? = $0.average(ofProperty: T.key(for: keyPath))
                    DispatchQueue.main.async {
                        callback(value)
                    }
                },
                updates: {
                    let value: Double? = $0.average(ofProperty: T.key(for: keyPath))
                    DispatchQueue.main.async {
                        updates(value)
                    }
                })
    }

    public func countSync<T: DatabaseMappable>(for model: T.Type,
                                               with filter: DatabaseFilterType<T> = .unfiltered) -> Int where T.Container: RealmObject {
        syncOperator().values(ofType: T.self).filter(filter).count
    }

    public func minSync<T: DatabaseMappable & KeyPathConvertible, R: _HasPersistedType>(with filter: DatabaseFilterType<T> = .unfiltered,
                                                                                        for keyPath: KeyPath<T, R>) -> R?
        where T.Container: RealmObject, R.PersistedType: MinMaxType {
        syncOperator().values(ofType: T.self).filter(filter).min(ofProperty: T.key(for: keyPath))
    }

    public func maxSync<T: DatabaseMappable & KeyPathConvertible, R: _HasPersistedType>(with filter: DatabaseFilterType<T> = .unfiltered,
                                                                                        for keyPath: KeyPath<T, R>) -> R?
        where T.Container: RealmObject, R.PersistedType: MinMaxType {
        syncOperator().values(ofType: T.self).filter(filter).max(ofProperty: T.key(for: keyPath))
    }

    public func sumSync<T: DatabaseMappable & KeyPathConvertible, R: _HasPersistedType>(with filter: DatabaseFilterType<T> = .unfiltered,
                                                                                        for keyPath: KeyPath<T, R>) -> R
        where T.Container: RealmObject, R.PersistedType: AddableType {
        syncOperator().values(ofType: T.self).filter(filter).sum(ofProperty: T.key(for: keyPath))
    }

    public func averageSync<T: DatabaseMappable & KeyPathConvertible, R: _HasPersistedType>(with filter: DatabaseFilterType<T> = .unfiltered,
                                                                                            for keyPath: KeyPath<T, R>) -> Double?
        where T.Container: RealmObject, R.PersistedType: AddableType {
        syncOperator().values(ofType: T.self).filter(filter).average(ofProperty: T.key(for: keyPath))
    }

    public func fetch<T: DatabaseMappable>(with filter: DatabaseFilterType<T> = .unfiltered,
                                           sorted sort: DatabaseSortType = .unsorted,
                                           limit: Int? = nil,
                                           callback: @escaping ([T]) -> Void) where T.Container: RealmObject {

        readWorker.execute {
            realmOperator in
            let values = realmOperator.values(ofType: T.self).filter(filter).sort(sort).limited(limit).compactMap({
                try? T.mappable(for: $0)
            })
            DispatchQueue.main.async {
                callback(values)
            }
        }
    }

    public func syncFetch<T: DatabaseMappable>(with filter: DatabaseFilterType<T> = .unfiltered,
                                               sorted sort: DatabaseSortType = .unsorted,
                                               limit: Int? = nil) -> [T] where T.Container: RealmObject {
        let values = syncOperator().values(ofType: T.self).filter(filter).sort(sort).limited(limit).compactMap({
            try? T.mappable(for: $0)
        })
        return values
    }

    public func fetch<T: DatabaseMappable>
        (with filter: DatabaseFilterType<T> = .unfiltered,
         sorted sort: DatabaseSortType = .unsorted,
         limit: Int? = nil,
         callback: @escaping ([T]) -> Void,
         next: (([T], Bool) -> Void)? = nil,
         updates: @escaping (DatabaseObserveUpdate<T>) -> Void) -> DatabaseUpdatesToken where T.Container: RealmObject {

        let token = DatabaseUpdatesToken()
        token.limit = limit

        let worker = readWorker

        worker.execute {
            [weak worker, weak self] realmOperator in

            if token.isInvalidated { return }

            let results = realmOperator.values(ofType: T.self).filter(filter).sort(sort)

            let rToken = results.observe {
                change in

                switch change {
                case let .initial(newResults):
                    let values = newResults.limited(token.limit).compactMap({
                        try? T.mappable(for: $0)
                    })
                    let result: [T] = Array(values)
                    DispatchQueue.main.async {
                        callback(result)
                    }
                case let .update(newResults, deletions, insertions, modifications):
                    let deletionsInLimit = deletions.filter { token.limit == nil || $0 < (token.limit ?? 0) }
                    let insertionsInLimit = insertions.filter { token.limit == nil || $0 < (token.limit ?? 0) }
                    let modificationsInLimit = modifications.filter { token.limit == nil || $0 < (token.limit ?? 0) }
                    let newLimit = token.limit.flatMap { $0 + (Swift.max(0, insertionsInLimit.count - deletionsInLimit.count)) }
                    let values = newResults.limited(newLimit).compactMap({
                        try? T.mappable(for: $0)
                    })
                    if (token.limit ?? Int.max) < newResults.count {
                        token.updateLimit(newLimit)
                    }
                    DispatchQueue.main.async {
                        let update = DatabaseObserveUpdate(values: values,
                                                           deletions: deletionsInLimit,
                                                           insertions: insertionsInLimit,
                                                           modifications: modificationsInLimit)
                        updates(update)
                    }
                case .error(_):
                    break
                }
            }

            token.invalidation = { rToken.invalidate() }
            guard let worker = worker else { return }
            self?.setupLimitation(for: token, worker: worker, results: results, next: next, updates: updates)
        }

        return token
    }

    public func fetchUnique<T: UniquelyMappable>(with key: T.ID, callback: @escaping (T?) -> Void) where T.Container: RealmObject {

        readWorker.execute {
            realmOperator in
            let value = realmOperator.value(ofType: T.self, with: key).flatMap({
                try? T.mappable(for: $0)
            })
            DispatchQueue.main.async {
                callback(value)
            }
        }
    }

    public func syncFetchUnique<T: UniquelyMappable>(with key: T.ID) -> T? where T.Container: RealmObject {

        let value = syncOperator().value(ofType: T.self, with: key).flatMap({
            try? T.mappable(for: $0)
        })
        return value
    }

    public func fetchUnique<T: UniquelyMappable>
        (with key: T.ID,
         callback: @escaping (T?) -> Void,
         updates: @escaping (DatabaseModelUpdate<T>) -> Void) -> DatabaseUpdatesToken where T.Container: RealmObject {

        let token = DatabaseUpdatesToken()

        readWorker.execute {
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

    public func count<T: UniquelyMappable, R: UniquelyMappable>
        (_ relation: Relation<R>,
         in model: T,
         with filter: DatabaseFilterType<R> = .unfiltered,
         callback: @escaping (Int) -> Void) where T.Container: RealmObject, R.Container: RealmObject {

        readWorker.execute {
            realmOperator in
            let value = realmOperator.relationValues(relation, in: model)?.filter(filter).count ?? 0
            DispatchQueue.main.async {
                callback(value)
            }
        }
    }

    public func count<T: UniquelyMappable, R: UniquelyMappable>
        (_ relation: Relation<R>,
         in model: T,
         with filter: DatabaseFilterType<R> = .unfiltered,
         callback: @escaping (Int) -> Void,
         updates: @escaping (Int) -> Void) -> DatabaseUpdatesToken where T.Container: RealmObject, R.Container: RealmObject {
        fetchRelationObjects(relation, in: model, with: filter, callback: {
            let count = $0?.count ?? 0
            DispatchQueue.main.async {
                callback(count)
            }
        }, updates: {
            let count = $0?.count ?? 0
            DispatchQueue.main.async {
                updates(count)
            }
        })
    }

    public func min<T: UniquelyMappable, R: UniquelyMappable & KeyPathConvertible, V: _HasPersistedType>
        (_ relation: Relation<R>,
         in model: T,
         with filter: DatabaseFilterType<R> = .unfiltered,
         for keyPath: KeyPath<R, V>,
         callback: @escaping (V?) -> Void) where T.Container: RealmObject, R.Container: RealmObject, V.PersistedType: MinMaxType {

        readWorker.execute {
            realmOperator in
            let value: V? = realmOperator.relationValues(relation, in: model)?.filter(filter).min(ofProperty: R.key(for: keyPath))
            DispatchQueue.main.async {
                callback(value)
            }
        }
    }

    public func min<T: UniquelyMappable, R: UniquelyMappable & KeyPathConvertible, V: _HasPersistedType>
        (_ relation: Relation<R>,
         in model: T,
         with filter: DatabaseFilterType<R> = .unfiltered,
         for keyPath: KeyPath<R, V>,
         callback: @escaping (V?) -> Void,
         updates: @escaping (V?) -> Void) -> DatabaseUpdatesToken
        where T.Container: RealmObject, R.Container: RealmObject, V.PersistedType: MinMaxType {
        fetchRelationObjects(relation, in: model, with: filter, callback: {
            let value: V? = $0?.min(ofProperty: R.key(for: keyPath))
            DispatchQueue.main.async {
                callback(value)
            }
        }, updates: {
            let value: V? = $0?.min(ofProperty: R.key(for: keyPath))
            DispatchQueue.main.async {
                updates(value)
            }
        })
    }

    public func max<T: UniquelyMappable, R: UniquelyMappable & KeyPathConvertible, V: _HasPersistedType>
        (_ relation: Relation<R>,
         in model: T,
         with filter: DatabaseFilterType<R> = .unfiltered,
         for keyPath: KeyPath<R, V>,
         callback: @escaping (V?) -> Void) where T.Container: RealmObject, R.Container: RealmObject, V.PersistedType: MinMaxType {

        readWorker.execute {
            realmOperator in
            let value: V? = realmOperator.relationValues(relation, in: model)?.filter(filter).max(ofProperty: R.key(for: keyPath))
            DispatchQueue.main.async {
                callback(value)
            }
        }
    }

    public func max<T: UniquelyMappable, R: UniquelyMappable & KeyPathConvertible, V: _HasPersistedType>
        (_ relation: Relation<R>,
         in model: T,
         with filter: DatabaseFilterType<R> = .unfiltered,
         for keyPath: KeyPath<R, V>,
         callback: @escaping (V?) -> Void,
         updates: @escaping (V?) -> Void) -> DatabaseUpdatesToken
        where T.Container: RealmObject, R.Container: RealmObject, V.PersistedType: MinMaxType {
        fetchRelationObjects(relation, in: model, with: filter, callback: {
            let value: V? = $0?.max(ofProperty: R.key(for: keyPath))
            DispatchQueue.main.async {
                callback(value)
            }
        }, updates: {
            let value: V? = $0?.max(ofProperty: R.key(for: keyPath))
            DispatchQueue.main.async {
                updates(value)
            }
        })
    }

    public func sum<T: UniquelyMappable, R: UniquelyMappable & KeyPathConvertible, V: _HasPersistedType>
        (_ relation: Relation<R>,
         in model: T,
         with filter: DatabaseFilterType<R> = .unfiltered,
         for keyPath: KeyPath<R, V>,
         callback: @escaping (V?) -> Void) where T.Container: RealmObject, R.Container: RealmObject, V.PersistedType: AddableType {

        readWorker.execute {
            realmOperator in
            let value: V? = realmOperator.relationValues(relation, in: model)?.filter(filter).sum(ofProperty: R.key(for: keyPath))
            DispatchQueue.main.async {
                callback(value)
            }
        }
    }

    public func sum<T: UniquelyMappable, R: UniquelyMappable & KeyPathConvertible, V: _HasPersistedType>
        (_ relation: Relation<R>,
         in model: T,
         with filter: DatabaseFilterType<R> = .unfiltered,
         for keyPath: KeyPath<R, V>,
         callback: @escaping (V?) -> Void,
         updates: @escaping (V?) -> Void) -> DatabaseUpdatesToken
        where T.Container: RealmObject, R.Container: RealmObject, V.PersistedType: AddableType {
        fetchRelationObjects(relation, in: model, with: filter, callback: {
            let value: V? = $0?.sum(ofProperty: R.key(for: keyPath))
            DispatchQueue.main.async {
                callback(value)
            }
        }, updates: {
            let value: V? = $0?.sum(ofProperty: R.key(for: keyPath))
            DispatchQueue.main.async {
                updates(value)
            }
        })
    }

    public func average<T: UniquelyMappable, R: UniquelyMappable & KeyPathConvertible, V: _HasPersistedType>
        (_ relation: Relation<R>,
         in model: T,
         with filter: DatabaseFilterType<R> = .unfiltered,
         for keyPath: KeyPath<R, V>,
         callback: @escaping (Double?) -> Void) where T.Container: RealmObject, R.Container: RealmObject, V.PersistedType: AddableType {

        readWorker.execute {
            realmOperator in
            let value: Double? = realmOperator.relationValues(relation, in: model)?.filter(filter).average(ofProperty: R.key(for: keyPath))
            DispatchQueue.main.async {
                callback(value)
            }
        }
    }

    public func average<T: UniquelyMappable, R: UniquelyMappable & KeyPathConvertible, V: _HasPersistedType>
        (_ relation: Relation<R>,
         in model: T,
         with filter: DatabaseFilterType<R> = .unfiltered,
         for keyPath: KeyPath<R, V>,
         callback: @escaping (Double?) -> Void,
         updates: @escaping (Double?) -> Void) -> DatabaseUpdatesToken
        where T.Container: RealmObject, R.Container: RealmObject, V.PersistedType: AddableType {
        fetchRelationObjects(relation, in: model, with: filter, callback: {
            let value: Double? = $0?.average(ofProperty: R.key(for: keyPath))
            DispatchQueue.main.async {
                callback(value)
            }
        }, updates: {
            let value: Double? = $0?.average(ofProperty: R.key(for: keyPath))
            DispatchQueue.main.async {
                updates(value)
            }
        })
    }

    public func countSync<T: UniquelyMappable, R: UniquelyMappable>
        (_ relation: Relation<R>,
         in model: T,
         with filter: DatabaseFilterType<R> = .unfiltered) -> Int where T.Container: RealmObject, R.Container: RealmObject {

        syncOperator().relationValues(relation, in: model)?.filter(filter).count ?? 0
    }

    public func minSync<T: UniquelyMappable, R: UniquelyMappable & KeyPathConvertible, V: _HasPersistedType>
        (_ relation: Relation<R>,
         in model: T,
         with filter: DatabaseFilterType<R> = .unfiltered,
         for keyPath: KeyPath<R, V>) -> V? where T.Container: RealmObject, R.Container: RealmObject, V.PersistedType: MinMaxType {

        syncOperator().relationValues(relation, in: model)?.filter(filter).min(ofProperty: R.key(for: keyPath))
    }

    public func maxSync<T: UniquelyMappable, R: UniquelyMappable & KeyPathConvertible, V: _HasPersistedType>
        (_ relation: Relation<R>,
         in model: T,
         with filter: DatabaseFilterType<R> = .unfiltered,
         for keyPath: KeyPath<R, V>) -> V? where T.Container: RealmObject, R.Container: RealmObject, V.PersistedType: MinMaxType {

        syncOperator().relationValues(relation, in: model)?.filter(filter).max(ofProperty: R.key(for: keyPath))
    }

    public func sumSync<T: UniquelyMappable, R: UniquelyMappable & KeyPathConvertible, V: _HasPersistedType>
        (_ relation: Relation<R>,
         in model: T,
         with filter: DatabaseFilterType<R> = .unfiltered,
         for keyPath: KeyPath<R, V>) -> V? where T.Container: RealmObject, R.Container: RealmObject, V.PersistedType: AddableType {

        syncOperator().relationValues(relation, in: model)?.filter(filter).sum(ofProperty: R.key(for: keyPath))
    }

    public func averageSync<T: UniquelyMappable, R: UniquelyMappable & KeyPathConvertible, V: _HasPersistedType>
        (_ relation: Relation<R>,
         in model: T,
         with filter: DatabaseFilterType<R> = .unfiltered,
         for keyPath: KeyPath<R, V>) -> Double? where T.Container: RealmObject, R.Container: RealmObject, V.PersistedType: AddableType {

        syncOperator().relationValues(relation, in: model)?.filter(filter).average(ofProperty: R.key(for: keyPath))
    }

    public func fetchRelation<T: UniquelyMappable, R: UniquelyMappable>
        (_ relation: Relation<R>,
         in model: T,
         with filter: DatabaseFilterType<R> = .unfiltered,
         sorted sort: DatabaseSortType = .unsorted,
         limit: Int? = nil,
         callback: @escaping ([R]) -> Void) where T.Container: Object, R.Container: Object {

        readWorker.execute {
            realmOperator in
            guard let values = realmOperator.relationValues(relation, in: model)?
                                            .filter(filter)
                                            .sort(sort)
                                            .limited(limit)
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

    public func fetchRelation<T: UniquelyMappable, R: DatabaseMappable>
        (_ relation: EmbeddedRelation<R>,
         in model: T,
         with filter: DatabaseFilterType<R> = .unfiltered,
         sorted sort: DatabaseSortType = .unsorted,
         limit: Int? = nil,
         callback: @escaping ([R]) -> Void) where T.Container: Object, R.Container: ObjectBase & RealmCollectionValue {

        readWorker.execute {
            realmOperator in
            guard let values = realmOperator.relationValues(relation, in: model)?
                                            .filter(filter)
                                            .sort(sort)
                                            .limited(limit)
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

    public func syncFetchRelation<T: UniquelyMappable, R: UniquelyMappable>
        (_ relation: Relation<R>,
         in model: T,
         with filter: DatabaseFilterType<R> = .unfiltered,
         sorted sort: DatabaseSortType = .unsorted,
         limit: Int? = nil) -> [R] where T.Container: Object, R.Container: Object {

        guard let values = syncOperator().relationValues(relation, in: model)?
                                         .filter(filter)
                                         .sort(sort)
                                         .limited(limit)
                                         .compactMap({ try? R.mappable(for: $0) }) else {
            return []
        }
        let result = Array(values)
        relation.cachedValue = result
        return result
    }

    public func fetchRelation<T: UniquelyMappable, R: UniquelyMappable>
        (_ relation: Relation<R>,
         in model: T,
         with filter: DatabaseFilterType<R> = .unfiltered,
         sorted sort: DatabaseSortType = .unsorted,
         limit: Int? = nil,
         callback: @escaping ([R]) -> Void,
         next: (([R], Bool) -> Void)? = nil,
         updates: @escaping (DatabaseObserveUpdate<R>) -> Void) -> DatabaseUpdatesToken where T.Container: Object, R.Container: Object {

        let token = DatabaseUpdatesToken()
        token.limit = limit

        // Listen for item deletes
        let innerToken = fetchUnique(with: model.idValue, callback: {
            [weak token] (item: T?) in
            guard item == nil else { return }
            token?.invalidate()
        }, updates: {
            [weak token] update in
            switch update {
            case .delete:
                DispatchQueue.main.async {
                    updates(DatabaseObserveUpdate(values: [], deletions: [], insertions: [], modifications: []))
                }
                token?.invalidate()
            default:
                break
            }
        })

        let worker = readWorker

        worker.execute {
            [weak worker, weak self] realmOperator in

            if token.isInvalidated { return }

            guard let results = realmOperator.relationValues(relation, in: model)?.filter(filter).sort(sort) else {
                DispatchQueue.main.async {
                    callback([])
                }
                return
            }

            let rToken = results.observe {
                change in

                if token.isInvalidated { return }

                // Check if item still exists
                guard let _: T.Container = realmOperator.value(ofType: T.self, with: model.idValue) else {
                    return
                }

                switch change {
                case let .initial(newResults):
                    let values = Array(newResults.limited(token.limit).compactMap({
                        try? R.mappable(for: $0)
                    }))
                    let result: [R] = Array(values)
                    DispatchQueue.main.async {
                        relation.cachedValue = result
                        callback(result)
                    }
                case let .update(newResults, deletions, insertions, modifications):
                    let deletionsInLimit = deletions.filter { token.limit == nil || $0 < (token.limit ?? 0) }
                    let insertionsInLimit = insertions.filter { token.limit == nil || $0 < (token.limit ?? 0) }
                    let modificationsInLimit = modifications.filter { token.limit == nil || $0 < (token.limit ?? 0) }
                    let newLimit = token.limit.flatMap { $0 + (Swift.max(0, insertionsInLimit.count - deletionsInLimit.count)) }
                    let values = newResults.limited(newLimit).compactMap({
                        try? R.mappable(for: $0)
                    })
                    if (token.limit ?? Int.max) < newResults.count {
                        token.updateLimit(newLimit)
                    }
                    DispatchQueue.main.async {
                        let update = DatabaseObserveUpdate(values: values,
                                                           deletions: deletionsInLimit,
                                                           insertions: insertionsInLimit,
                                                           modifications: modificationsInLimit)
                        relation.cachedValue = values
                        updates(update)
                    }
                case .error: break
                }
            }

            token.invalidation = {
                rToken.invalidate()
                innerToken.invalidate()
            }
            guard let worker = worker else { return }
            self?.setupLimitation(for: token, worker: worker, results: results, next: next, updates: updates)
        }

        return token
    }

    // MARK: Type safe Fetching
    public func fetch<T: DatabaseMappable>
        (_ query: @escaping T.Query,
         sorted sort: [SortDescriptor<T>] = [],
         limit: Int? = nil,
         callback: @escaping ([T]) -> Void) where T.Container: RealmObject {

        fetch(with: .safeQuery(query: query),
              sorted: sort.isEmpty ? .unsorted : .init(sortDescriptors: sort),
              limit: limit,
              callback: callback)
    }

    public func fetch<T: DatabaseMappable & KeyPathConvertible>
        (sorted sort: [SortDescriptor<T>] = [],
         limit: Int? = nil,
         callback: @escaping ([T]) -> Void) where T.Container: RealmObject {

        fetch(with: .unfiltered,
              sorted: sort.isEmpty ? .unsorted : .init(sortDescriptors: sort),
              limit: limit,
              callback: callback)
    }

    public func syncFetch<T: DatabaseMappable>
        (_ query: @escaping T.Query,
         sorted sort: [SortDescriptor<T>] = [],
         limit: Int? = nil) -> [T] where T.Container: RealmObject {

        syncFetch(with: .safeQuery(query: query),
                  sorted: sort.isEmpty ? .unsorted : .init(sortDescriptors: sort),
                  limit: limit)
    }

    public func syncFetch<T: DatabaseMappable & KeyPathConvertible>
        (sorted sort: [SortDescriptor<T>] = [],
         limit: Int? = nil) -> [T] where T.Container: RealmObject {

        syncFetch(with: .unfiltered,
                  sorted: sort.isEmpty ? .unsorted : .init(sortDescriptors: sort),
                  limit: limit)
    }

    public func fetch<T: DatabaseMappable>
        (_ query: @escaping T.Query,
         sorted sort: [SortDescriptor<T>] = [],
         limit: Int? = nil,
         callback: @escaping ([T]) -> Void,
         next: (([T], Bool) -> Void)? = nil,
         updates: @escaping (DatabaseObserveUpdate<T>) -> Void) -> DatabaseUpdatesToken where T.Container: RealmObject {

        fetch(with: .safeQuery(query: query),
              sorted: sort.isEmpty ? .unsorted : .init(sortDescriptors: sort),
              limit: limit,
              callback: callback,
              next: next,
              updates: updates)
    }

    public func fetch<T: DatabaseMappable & KeyPathConvertible>
        (sorted sort: [SortDescriptor<T>] = [],
         limit: Int? = nil,
         callback: @escaping ([T]) -> Void,
         next: (([T], Bool) -> Void)? = nil,
         updates: @escaping (DatabaseObserveUpdate<T>) -> Void) -> DatabaseUpdatesToken where T.Container: RealmObject {

        fetch(with: .unfiltered,
              sorted: sort.isEmpty ? .unsorted : .init(sortDescriptors: sort),
              limit: limit,
              callback: callback,
              next: next,
              updates: updates)
    }

    public func fetchRelation<T: UniquelyMappable, R: UniquelyMappable>
        (_ relation: Relation<R>,
         in model: T,
         query: @escaping R.Query,
         sorted sort: [SortDescriptor<R>] = [],
         limit: Int? = nil,
         callback: @escaping ([R]) -> Void) where T.Container: Object, R.Container: Object {

        fetchRelation(relation,
                      in: model,
                      with: .safeQuery(query: query),
                      sorted: sort.isEmpty ? .unsorted : .init(sortDescriptors: sort),
                      limit: limit,
                      callback: callback)
    }

    public func fetchRelation<T: UniquelyMappable, R: UniquelyMappable & KeyPathConvertible>
        (_ relation: Relation<R>,
         in model: T,
         sorted sort: [SortDescriptor<R>] = [],
         limit: Int? = nil,
         callback: @escaping ([R]) -> Void) where T.Container: Object, R.Container: Object {

        fetchRelation(relation,
                      in: model,
                      with: .unfiltered,
                      sorted: sort.isEmpty ? .unsorted : .init(sortDescriptors: sort),
                      limit: limit,
                      callback: callback)
    }

    public func syncFetchRelation<T: UniquelyMappable, R: UniquelyMappable>
        (_ relation: Relation<R>,
         in model: T,
         query: @escaping R.Query,
         sorted sort: [SortDescriptor<R>] = [],
         limit: Int? = nil) -> [R] where T.Container: Object, R.Container: Object {

        syncFetchRelation(relation,
                          in: model,
                          with: .safeQuery(query: query),
                          sorted: sort.isEmpty ? .unsorted : .init(sortDescriptors: sort),
                          limit: limit)
    }

    public func syncFetchRelation<T: UniquelyMappable, R: UniquelyMappable & KeyPathConvertible>
        (_ relation: Relation<R>,
         in model: T,
         sorted sort: [SortDescriptor<R>] = [],
         limit: Int? = nil) -> [R] where T.Container: Object, R.Container: Object {

        syncFetchRelation(relation,
                          in: model,
                          with: .unfiltered,
                          sorted: sort.isEmpty ? .unsorted : .init(sortDescriptors: sort),
                          limit: limit)
    }

    public func fetchRelation<T: UniquelyMappable, R: UniquelyMappable>
        (_ relation: Relation<R>,
         in model: T,
         query: @escaping R.Query,
         sorted sort: [SortDescriptor<R>] = [],
         limit: Int? = nil,
         callback: @escaping ([R]) -> Void,
         next: (([R], Bool) -> Void)? = nil,
         updates: @escaping (DatabaseObserveUpdate<R>) -> Void) -> DatabaseUpdatesToken where T.Container: Object, R.Container: Object {

        fetchRelation(relation,
                      in: model,
                      with: .safeQuery(query: query),
                      sorted: sort.isEmpty ? .unsorted : .init(sortDescriptors: sort),
                      limit: limit,
                      callback: callback,
                      next: next,
                      updates: updates)
    }

    public func fetchRelation<T: UniquelyMappable, R: UniquelyMappable & KeyPathConvertible>
        (_ relation: Relation<R>,
         in model: T,
         sorted sort: [SortDescriptor<R>] = [],
         limit: Int? = nil,
         callback: @escaping ([R]) -> Void,
         next: (([R], Bool) -> Void)? = nil,
         updates: @escaping (DatabaseObserveUpdate<R>) -> Void) -> DatabaseUpdatesToken where T.Container: Object, R.Container: Object {

        fetchRelation(relation,
                      in: model,
                      with: .unfiltered,
                      sorted: sort.isEmpty ? .unsorted : .init(sortDescriptors: sort),
                      limit: limit,
                      callback: callback,
                      next: next,
                      updates: updates)
    }
}


// MARK: - Optional key paths support
extension RealmService {
    public func updateSingleRelation<T: UniquelyMappable & KeyPathConvertible, R: UniquelyMappable>
        (in model: T,
         for keyPath: KeyPath<T, R?>,
         relationId: R.ID?,
         sync: Bool = false) where T.Container: RealmObject, R.Container: RealmObject {

        let block: RealmBlock = {
            realmOperator in
            try? realmOperator.write {
                transaction in
                transaction.updateSingleRelation(in: model, for: keyPath, relationOf: R.self, relationId: relationId)
            }
        }

        processRealmBlock(block, sync: sync)
    }

    public func min<T: DatabaseMappable & KeyPathConvertible, R: _HasPersistedType>
        (with filter: DatabaseFilterType<T> = .unfiltered,
         for keyPath: KeyPath<T, R?>,
         callback: @escaping (R?) -> Void) where T.Container: RealmObject, R.PersistedType: MinMaxType {

        readWorker.execute {
            realmOperator in
            let value: R? = realmOperator.values(ofType: T.self).filter(filter).min(ofProperty: T.key(for: keyPath))
            DispatchQueue.main.async {
                callback(value)
            }
        }
    }

    public func max<T: DatabaseMappable & KeyPathConvertible, R: _HasPersistedType>
        (with filter: DatabaseFilterType<T> = .unfiltered,
         for keyPath: KeyPath<T, R?>,
         callback: @escaping (R?) -> Void) where T.Container: RealmObject, R.PersistedType: MinMaxType {

        readWorker.execute {
            realmOperator in
            let value: R? = realmOperator.values(ofType: T.self).filter(filter).max(ofProperty: T.key(for: keyPath))
            DispatchQueue.main.async {
                callback(value)
            }
        }
    }

    public func sum<T: DatabaseMappable & KeyPathConvertible, R: _HasPersistedType>
        (with filter: DatabaseFilterType<T> = .unfiltered,
         for keyPath: KeyPath<T, R?>,
         callback: @escaping (R) -> Void) where T.Container: RealmObject, R.PersistedType: AddableType {

        readWorker.execute {
            realmOperator in
            let value: R = realmOperator.values(ofType: T.self).filter(filter).sum(ofProperty: T.key(for: keyPath))
            DispatchQueue.main.async {
                callback(value)
            }
        }
    }

    public func average<T: DatabaseMappable & KeyPathConvertible, R: _HasPersistedType>
        (with filter: DatabaseFilterType<T> = .unfiltered,
         for keyPath: KeyPath<T, R?>,
         callback: @escaping (Double?) -> Void) where T.Container: RealmObject, R.PersistedType: AddableType {

        readWorker.execute {
            realmOperator in
            let value: Double? = realmOperator.values(ofType: T.self).filter(filter).average(ofProperty: T.key(for: keyPath))
            DispatchQueue.main.async {
                callback(value)
            }
        }
    }

    public func minSync<T: DatabaseMappable & KeyPathConvertible, R: _HasPersistedType>
        (with filter: DatabaseFilterType<T> = .unfiltered,
         for keyPath: KeyPath<T, R?>) -> R? where T.Container: RealmObject, R.PersistedType: MinMaxType {

        syncOperator().values(ofType: T.self).filter(filter).min(ofProperty: T.key(for: keyPath))
    }

    public func maxSync<T: DatabaseMappable & KeyPathConvertible, R: _HasPersistedType>
        (with filter: DatabaseFilterType<T> = .unfiltered,
         for keyPath: KeyPath<T, R?>) -> R? where T.Container: RealmObject, R.PersistedType: MinMaxType {

        syncOperator().values(ofType: T.self).filter(filter).max(ofProperty: T.key(for: keyPath))
    }

    public func sumSync<T: DatabaseMappable & KeyPathConvertible, R: _HasPersistedType>
        (with filter: DatabaseFilterType<T> = .unfiltered,
         for keyPath: KeyPath<T, R?>) -> R where T.Container: RealmObject, R.PersistedType: AddableType {

        syncOperator().values(ofType: T.self).filter(filter).sum(ofProperty: T.key(for: keyPath))
    }

    public func averageSync<T: DatabaseMappable & KeyPathConvertible, R: _HasPersistedType>
        (with filter: DatabaseFilterType<T> = .unfiltered,
         for keyPath: KeyPath<T, R?>) -> Double? where T.Container: RealmObject, R.PersistedType: AddableType {

        syncOperator().values(ofType: T.self).filter(filter).average(ofProperty: T.key(for: keyPath))
    }

    public func min<T: UniquelyMappable, R: UniquelyMappable & KeyPathConvertible, V: _HasPersistedType>
        (_ relation: Relation<R>,
         in model: T,
         with filter: DatabaseFilterType<R> = .unfiltered,
         for keyPath: KeyPath<R, V?>,
         callback: @escaping (V?) -> Void) where T.Container: RealmObject, R.Container: RealmObject, V.PersistedType: MinMaxType {

        readWorker.execute {
            realmOperator in
            let value: V? = realmOperator.relationValues(relation, in: model)?.filter(filter).min(ofProperty: R.key(for: keyPath))
            DispatchQueue.main.async {
                callback(value)
            }
        }
    }

    public func max<T: UniquelyMappable, R: UniquelyMappable & KeyPathConvertible, V: _HasPersistedType>
        (_ relation: Relation<R>,
         in model: T,
         with filter: DatabaseFilterType<R> = .unfiltered,
         for keyPath: KeyPath<R, V?>,
         callback: @escaping (V?) -> Void) where T.Container: RealmObject, R.Container: RealmObject, V.PersistedType: MinMaxType {

        readWorker.execute {
            realmOperator in
            let value: V? = realmOperator.relationValues(relation, in: model)?.filter(filter).max(ofProperty: R.key(for: keyPath))
            DispatchQueue.main.async {
                callback(value)
            }
        }
    }

    public func sum<T: UniquelyMappable, R: UniquelyMappable & KeyPathConvertible, V: _HasPersistedType>
        (_ relation: Relation<R>,
         in model: T,
         with filter: DatabaseFilterType<R> = .unfiltered,
         for keyPath: KeyPath<R, V?>,
         callback: @escaping (V?) -> Void) where T.Container: RealmObject, R.Container: RealmObject, V.PersistedType: AddableType {

        readWorker.execute {
            realmOperator in
            let value: V? = realmOperator.relationValues(relation, in: model)?.filter(filter).sum(ofProperty: R.key(for: keyPath))
            DispatchQueue.main.async {
                callback(value)
            }
        }
    }

    public func average<T: UniquelyMappable, R: UniquelyMappable & KeyPathConvertible, V: _HasPersistedType>
        (_ relation: Relation<R>,
         in model: T,
         with filter: DatabaseFilterType<R> = .unfiltered,
         for keyPath: KeyPath<R, V?>,
         callback: @escaping (Double?) -> Void) where T.Container: RealmObject, R.Container: RealmObject, V.PersistedType: AddableType {

        readWorker.execute {
            realmOperator in
            let value: Double? = realmOperator.relationValues(relation, in: model)?.filter(filter).average(ofProperty: R.key(for: keyPath))
            DispatchQueue.main.async {
                callback(value)
            }
        }
    }

    public func minSync<T: UniquelyMappable, R: UniquelyMappable & KeyPathConvertible, V: _HasPersistedType>
        (_ relation: Relation<R>,
         in model: T,
         with filter: DatabaseFilterType<R> = .unfiltered,
         for keyPath: KeyPath<R, V?>) -> V? where T.Container: RealmObject, R.Container: RealmObject, V.PersistedType: MinMaxType {

        syncOperator().relationValues(relation, in: model)?.filter(filter).min(ofProperty: R.key(for: keyPath))
    }

    public func maxSync<T: UniquelyMappable, R: UniquelyMappable & KeyPathConvertible, V: _HasPersistedType>
        (_ relation: Relation<R>,
         in model: T,
         with filter: DatabaseFilterType<R> = .unfiltered,
         for keyPath: KeyPath<R, V?>) -> V? where T.Container: RealmObject, R.Container: RealmObject, V.PersistedType: MinMaxType {

        syncOperator().relationValues(relation, in: model)?.filter(filter).max(ofProperty: R.key(for: keyPath))
    }

    public func sumSync<T: UniquelyMappable, R: UniquelyMappable & KeyPathConvertible, V: _HasPersistedType>
        (_ relation: Relation<R>,
         in model: T,
         with filter: DatabaseFilterType<R> = .unfiltered,
         for keyPath: KeyPath<R, V?>) -> V? where T.Container: RealmObject, R.Container: RealmObject, V.PersistedType: AddableType {

        syncOperator().relationValues(relation, in: model)?.filter(filter).sum(ofProperty: R.key(for: keyPath))
    }

    public func averageSync<T: UniquelyMappable, R: UniquelyMappable & KeyPathConvertible, V: _HasPersistedType>
        (_ relation: Relation<R>,
         in model: T,
         with filter: DatabaseFilterType<R> = .unfiltered,
         for keyPath: KeyPath<R, V?>) -> Double? where T.Container: RealmObject, R.Container: RealmObject, V.PersistedType: AddableType {

        syncOperator().relationValues(relation, in: model)?.filter(filter).average(ofProperty: R.key(for: keyPath))
    }
}


extension RealmService {
    private func objects<T: DatabaseMappable>
        (for model: T.Type,
         with filter: DatabaseFilterType<T> = .unfiltered,
         callback: @escaping (AnyRealmCollection<T.Container>) -> Void,
         updates: @escaping (AnyRealmCollection<T.Container>) -> Void) -> DatabaseUpdatesToken where T.Container: RealmObject {

        let token = DatabaseUpdatesToken()

        let worker = readWorker

        worker.execute {
            realmOperator in

            if token.isInvalidated { return }

            let results = realmOperator.values(ofType: T.self).filter(filter)

            let rToken = results.observe {
                change in

                switch change {
                case let .initial(newResults):
                    let values = newResults
                    callback(values)
                case let .update(newResults, _, _, _):
                    updates(newResults)
                case .error(_):
                    break
                }
            }

            token.invalidation = { rToken.invalidate() }
        }

        return token
    }

    private func fetchRelationObjects<T: UniquelyMappable, R: UniquelyMappable>
        (_ relation: Relation<R>,
         in model: T,
         with filter: DatabaseFilterType<R> = .unfiltered,
         callback: @escaping (AnyRealmCollection<R.Container>?) -> Void,
         updates: @escaping (AnyRealmCollection<R.Container>?) -> Void) -> DatabaseUpdatesToken where T.Container: Object, R.Container: Object {

        let token = DatabaseUpdatesToken()

        // Listen for item deletes
        let innerToken = fetchUnique(with: model.idValue, callback: {
            [weak token] (item: T?) in
            guard item == nil else { return }
            token?.invalidate()
        }, updates: {
            [weak token] update in
            switch update {
            case .delete:
                updates(nil)
                token?.invalidate()
            default:
                break
            }
        })

        let worker = readWorker

        worker.execute {
            realmOperator in

            if token.isInvalidated { return }

            guard let results = realmOperator.relationValues(relation, in: model)?.filter(filter) else {
                callback(nil)
                return
            }

            let rToken = results.observe {
                change in

                if token.isInvalidated { return }

                // Check if item still exists
                guard let _: T.Container = realmOperator.value(ofType: T.self, with: model.idValue) else {
                    return
                }

                switch change {
                case let .initial(newResults):
                    callback(newResults)
                case let .update(newResults, _, _, _):
                    updates(newResults)
                case .error: break
                }
            }

            token.invalidation = {
                rToken.invalidate()
                innerToken.invalidate()
            }
        }

        return token
    }

    private func setupLimitation<T: DatabaseMappable>(for token: DatabaseUpdatesToken,
                                                      worker: DatabaseRealmBackgroundWorker,
                                                      results: AnyRealmCollection<T.Container>,
                                                      next: (([T], Bool) -> Void)? = nil,
                                                      updates: @escaping (DatabaseObserveUpdate<T>) -> Void) where T.Container: RealmObject {
        token.limitation = {
            [weak worker] oldLimit, newLimit in
            worker?.execute {
                _ in
                guard oldLimit != newLimit, (oldLimit ?? Int.max) < results.count || (newLimit ?? Int.max) < results.count else { return }
                let values = results.limited(newLimit).compactMap({
                    try? T.mappable(for: $0)
                })
                let old = Swift.min(results.count, oldLimit ?? Int.max)
                let new = Swift.min(results.count, newLimit ?? Int.max)
                let deletions = old > new ? Array(new..<old) : []
                let insertions = old < new ? Array(old..<new) : []
                DispatchQueue.main.async {
                    let update = DatabaseObserveUpdate(values: values,
                                                       deletions: deletions,
                                                       insertions: insertions,
                                                       modifications: [])
                    updates(update)
                }
            }
        }
        token.nextPage = {
            [weak token, weak worker] count in
            worker?.execute {
                _ in
                guard let oldLimit = token?.limit, results.count > oldLimit else {
                    DispatchQueue.main.async {
                        next?([], true)
                    }
                    return
                }
                let newLimit = oldLimit + count
                let values = results.limited(in: oldLimit..<newLimit).compactMap({
                    try? T.mappable(for: $0)
                })
                let isLast = newLimit >= results.count
                token?.updateLimit(newLimit)
                DispatchQueue.main.async {
                    next?(values, isLast)
                }
            }
        }
    }
}


typealias RealmBlock = @convention(block) (RealmOperator) -> Void


class DatabaseRealmBackgroundWorker {
    private let configuration: Realm.Configuration
    private let queue: DispatchQueue


    init(configuration: Realm.Configuration, queue: DispatchQueue) {
        self.configuration = configuration
        self.queue = queue
    }

    internal func execute(realmBlock: @escaping RealmBlock) {
        queue.async {
            [weak self] in
            guard let `self` = self,
                  let realm = try? Realm(configuration: self.configuration, queue: self.queue) else { return }
            let realmOperator = RealmOperator(realm: realm)
            realmBlock(realmOperator)
        }
    }

    internal func execute(realmBlocks: [RealmBlock]) {
        queue.async {
            [weak self] in
            guard let `self` = self,
                  let realm = try? Realm(configuration: self.configuration, queue: self.queue) else { return }
            let realmOperator = RealmOperator(realm: realm)
            realmOperator.beginWrite()
            realmBlocks.forEach { $0(realmOperator) }
            try? realmOperator.commitWrite()
        }
    }
}
