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

    func syncOperator() -> RealmOperator {
        let realm = try! Realm(configuration: self.configuration)
        return RealmOperator(realm: realm)
    }
}


extension RealmService {
    // MARK: Managing

    public func deleteAll(sync: Bool = false) {
        let block: RealmBlock = {
            realmOperator in
            try? realmOperator.write {
                transaction in
                transaction.deleteAll()
            }
        }
        sync ? block(syncOperator()) : self.writeWorker.execute(realmBlock: block)
    }

    public func simpleSave<T: DatabaseMappable>(model: T, sync: Bool = false) where T.Container: RealmObject {
        self.simpleSave(models: [model], sync: sync)
    }

    public func simpleSave<T: DatabaseMappable>(models: [T], sync: Bool = false) where T.Container: RealmObject {
        let block: RealmBlock = {
            realmOperator in
            try? realmOperator.write {
                transaction in
                try? transaction.add(models, update: false)
            }
        }
        sync ? block(syncOperator()) : self.writeWorker.execute(realmBlock: block)
    }

    public func save<T: UniquelyMappable>(model: T, update: Bool = true, sync: Bool = false) where T.Container: RealmObject {
        self.save(models: [model], update: update, sync: sync)
    }

    public func save<T: UniquelyMappable>(models: [T], update: Bool = true, sync: Bool = false) where T.Container: RealmObject {
        let block: RealmBlock = {
            realmOperator in
            try? realmOperator.write {
                transaction in
                try? transaction.add(models, update: update)
            }
        }
        sync ? block(syncOperator()) : self.writeWorker.execute(realmBlock: block)
    }

    public func saveSkippingRelations<T: UniquelyMappable>(model: T, sync: Bool = false) where T.Container: RealmObject {
        self.saveSkippingRelations(models: [model], sync: sync)
    }

    public func saveSkippingRelations<T: UniquelyMappable>(models: [T], sync: Bool = false) where T.Container: RealmObject {
        let block: RealmBlock = {
            realmOperator in
            try? realmOperator.write {
                transaction in
                try? transaction.addSkippingRelations(models)
            }
        }
        sync ? block(syncOperator()) : self.writeWorker.execute(realmBlock: block)
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
        sync ? block(syncOperator()) : self.writeWorker.execute(realmBlock: block)
    }

    public func update<T: UniquelyMappable>(model: T, sync: Bool = false) where T.Container: RealmObject {
        self.update(models: [model], sync: sync)
    }

    public func update<T: UniquelyMappable>(model: T, sync: Bool = false, skipRelations: Bool = false) where T.Container: RealmObject {
        self.update(models: [model], sync: sync, skipRelations: skipRelations)
    }

    public func update<T: UniquelyMappable>(models: [T], sync: Bool = false, skipRelations: Bool = false) where T.Container: RealmObject {
        let block: RealmBlock = {
            realmOperator in
            try? realmOperator.write {
                transaction in
                try? transaction.update(models, skipRelations: skipRelations)
            }
        }
        sync ? block(syncOperator()) : self.writeWorker.execute(realmBlock: block)
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
        sync ? block(syncOperator()) : self.writeWorker.execute(realmBlock: block)
    }

    public func update<T: UniquelyMappable & KeyPathConvertible>(modelOf type: T.Type,
                                                                 with key: T.ID,
                                                                 updates: [RootKeyPathUpdate<T>],
                                                                 sync: Bool = false) where T.Container: RealmObject {
        let updates = Dictionary(updates.map { $0.update }) { _, last in last }
        self.update(modelOf: type, with: key, updates: updates, sync: sync)
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
        sync ? block(syncOperator()) : self.writeWorker.execute(realmBlock: block)
    }
    public func updateSingleRelation<T: UniquelyMappable & KeyPathConvertible, R: UniquelyMappable>(in model: T,
                                                                                                    for keyPath: KeyPath<T, R?>,
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
        sync ? block(syncOperator()) : self.writeWorker.execute(realmBlock: block)
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
        sync ? block(syncOperator()) : self.writeWorker.execute(realmBlock: block)
    }

    public func delete<T: UniquelyMappable>(model: T, sync: Bool = false) where T.Container: RealmObject {
        self.delete(models: [model], sync: sync)
    }

    public func delete<T: UniquelyMappable>(models: [T], sync: Bool = false) where T.Container: RealmObject {
        let block: RealmBlock = {
            realmOperator in
            try? realmOperator.write {
                transaction in
                transaction.delete(models)
            }
        }
        sync ? block(syncOperator()) : self.writeWorker.execute(realmBlock: block)
    }

    public func deleteAll<T: DatabaseMappable>(modelsOf type: T.Type, sync: Bool = false) where T.Container: RealmObject {
        let block: RealmBlock = {
            realmOperator in
            try? realmOperator.write {
                transaction in
                transaction.deleteAll(modelsOf: type)
            }
        }
        sync ? block(syncOperator()) : self.writeWorker.execute(realmBlock: block)
    }


    // MARK: Fetching

    public func fetch<T: DatabaseMappable>(with filter: DatabaseFilterType = .unfiltered,
                                           sorted sort: DatabaseSortType = .unsorted,
                                           limit: Int? = nil,
                                           callback: @escaping ([T]) -> Void) where T.Container: RealmObject {
        let worker = self.nextWorker()

        worker.execute {
            realmOperator in
            let values = realmOperator.values(ofType: T.self).filter(filter).sort(sort).limited(limit).compactMap({ try? T.mappable(for: $0) })
            DispatchQueue.main.async {
                callback(values)
            }
        }
    }

    public func syncFetch<T: DatabaseMappable>(with filter: DatabaseFilterType = .unfiltered,
                                               sorted sort: DatabaseSortType = .unsorted,
                                               limit: Int? = nil) -> [T] where T.Container: RealmObject {
        let values = syncOperator().values(ofType: T.self).filter(filter).sort(sort).limited(limit).compactMap({ try? T.mappable(for: $0) })
        return values
    }

    public func fetch<T: DatabaseMappable>(with filter: DatabaseFilterType = .unfiltered,
                                           sorted sort: DatabaseSortType = .unsorted,
                                           limit: Int? = nil,
                                           callback: @escaping ([T]) -> Void,
                                           next: (([T], Bool) -> Void)? = nil,
                                           updates: @escaping (DatabaseObserveUpdate<T>) -> Void)
            -> DatabaseUpdatesToken where T.Container: RealmObject {
        let token = DatabaseUpdatesToken()
        token.limit = limit

        let worker = self.nextWorker()

        worker.execute {
            [weak worker, weak self] realmOperator in

            if token.isInvalidated { return }

            let results = realmOperator.values(ofType: T.self).filter(filter).sort(sort)

            let rToken = results.observe {
                change in

                switch change {
                case let .initial(newResults):
                    let values = newResults.limited(token.limit).compactMap({ try? T.mappable(for: $0) })
                    let result: [T] = Array(values)
                    DispatchQueue.main.async {
                        callback(result)
                    }
                case let .update(newResults, deletions, insertions, modifications):
                    let deletionsInLimit = deletions.filter { token.limit == nil || $0 < (token.limit ?? 0) }
                    let insertionsInLimit = insertions.filter { token.limit == nil || $0 < (token.limit ?? 0) }
                    let modificationsInLimit = modifications.filter { token.limit == nil || $0 < (token.limit ?? 0) }
                    let newLimit = token.limit.flatMap { $0 + (max(0, insertionsInLimit.count - deletionsInLimit.count)) }
                    let values = newResults.limited(newLimit).compactMap({ try? T.mappable(for: $0) })
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
        let value = syncOperator().value(ofType: T.self, with: key).flatMap({ try? T.mappable(for: $0) })
        return value
    }

    public func fetchUnique<T: UniquelyMappable>(with key: T.ID,
                                                 callback: @escaping (T?) -> Void,
                                                 updates: @escaping (DatabaseModelUpdate<T>) -> Void)
            -> DatabaseUpdatesToken where T.Container: RealmObject {

        let token = DatabaseUpdatesToken()

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
                                                                        sorted sort: DatabaseSortType = .unsorted,
                                                                        limit: Int? = nil,
                                                                        callback: @escaping ([R]) -> Void)
        where T.Container: Object, R.Container: Object {
        let worker = self.nextWorker()

        worker.execute {
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

    public func syncFetchRelation<T: UniquelyMappable, R: UniquelyMappable>(_ relation: Relation<R>,
                                                                            in model: T,
                                                                            with filter: DatabaseFilterType = .unfiltered,
                                                                            sorted sort: DatabaseSortType = .unsorted,
                                                                            limit: Int? = nil) -> [R]
        where T.Container: Object, R.Container: Object {
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

    public func fetchRelation<T: UniquelyMappable, R: UniquelyMappable>(_ relation: Relation<R>,
                                                                        in model: T,
                                                                        with filter: DatabaseFilterType = .unfiltered,
                                                                        sorted sort: DatabaseSortType = .unsorted,
                                                                        limit: Int? = nil,
                                                                        callback: @escaping ([R]) -> Void,
                                                                        next: (([R], Bool) -> Void)? = nil,
                                                                        updates: @escaping (DatabaseObserveUpdate<R>) -> Void) -> DatabaseUpdatesToken
        where T.Container: Object, R.Container: Object {
        let token = DatabaseUpdatesToken()
        token.limit = limit

        // Listen for item deletes
        let innerToken = self.fetchUnique(with: model.idValue, callback: {
            [weak token] (item: T?) in
            guard item == nil else { return }
            token?.invalidate()
        }, updates: {
            [weak token] updates in
            switch updates {
            case .delete:
                token?.invalidate()
            default:
                break
            }
        })

        let worker = self.nextWorker()

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
                    let values = Array(newResults.limited(token.limit).compactMap({ try? R.mappable(for: $0) }))
                    let result: [R] = Array(values)
                    DispatchQueue.main.async {
                        relation.cachedValue = result
                        callback(result)
                    }
                case let .update(newResults, deletions, insertions, modifications):
                    let deletionsInLimit = deletions.filter { token.limit == nil || $0 < (token.limit ?? 0) }
                    let insertionsInLimit = insertions.filter { token.limit == nil || $0 < (token.limit ?? 0) }
                    let modificationsInLimit = modifications.filter { token.limit == nil || $0 < (token.limit ?? 0) }
                    let newLimit = token.limit.flatMap { $0 + (max(0, insertionsInLimit.count - deletionsInLimit.count)) }
                    let values = newResults.limited(newLimit).compactMap({ try? R.mappable(for: $0) })
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

    public func fetch<T: DatabaseMappable, P: Predicate>(_ predicate: P,
                                                         sorted sort: [SortDescriptor<T>] = [],
                                                         limit: Int? = nil,
                                                         callback: @escaping ([T]) -> Void)
        where T.Container: RealmObject, P.ModelType == T {
        fetch(with: .predicate(predicate: predicate.predicate),
              sorted: sort.isEmpty ? .unsorted : .init(sortDescriptors: sort),
              limit: limit,
              callback: callback)
    }

    public func fetch<T: DatabaseMappable & KeyPathConvertible>(sorted sort: [SortDescriptor<T>] = [],
                                                                limit: Int? = nil,
                                                                callback: @escaping ([T]) -> Void)
        where T.Container: RealmObject {
        fetch(with: .unfiltered,
              sorted: sort.isEmpty ? .unsorted : .init(sortDescriptors: sort),
              limit: limit,
              callback: callback)
    }

    public func syncFetch<T: DatabaseMappable, P: Predicate>(_ predicate: P,
                                                             sorted sort: [SortDescriptor<T>] = [],
                                                             limit: Int? = nil) -> [T] where T.Container: RealmObject, P.ModelType == T {
        return syncFetch(with: .predicate(predicate: predicate.predicate),
                         sorted: sort.isEmpty ? .unsorted : .init(sortDescriptors: sort),
                         limit: limit)
    }

    public func syncFetch<T: DatabaseMappable & KeyPathConvertible>(sorted sort: [SortDescriptor<T>] = [],
                                                                    limit: Int? = nil) -> [T] where T.Container: RealmObject {
        return syncFetch(with: .unfiltered,
                         sorted: sort.isEmpty ? .unsorted : .init(sortDescriptors: sort),
                         limit: limit)
    }

    public func fetch<T: DatabaseMappable, P: Predicate>(_ predicate: P,
                                                         sorted sort: [SortDescriptor<T>] = [],
                                                         limit: Int? = nil,
                                                         callback: @escaping ([T]) -> Void,
                                                         next: (([T], Bool) -> Void)? = nil,
                                                         updates: @escaping (DatabaseObserveUpdate<T>) -> Void) -> DatabaseUpdatesToken
        where T.Container: RealmObject, P.ModelType == T {
        return fetch(with: .predicate(predicate: predicate.predicate),
                     sorted: sort.isEmpty ? .unsorted : .init(sortDescriptors: sort),
                     limit: limit,
                     callback: callback,
                     next: next,
                     updates: updates)
    }

    public func fetch<T: DatabaseMappable & KeyPathConvertible>(sorted sort: [SortDescriptor<T>] = [],
                                                                limit: Int? = nil,
                                                                callback: @escaping ([T]) -> Void,
                                                                next: (([T], Bool) -> Void)? = nil,
                                                                updates: @escaping (DatabaseObserveUpdate<T>) -> Void) -> DatabaseUpdatesToken
        where T.Container: RealmObject {
        return fetch(with: .unfiltered,
                     sorted: sort.isEmpty ? .unsorted : .init(sortDescriptors: sort),
                     limit: limit,
                     callback: callback,
                     next: next,
                     updates: updates)
    }

    public func fetchRelation<T: UniquelyMappable, R: UniquelyMappable, P: Predicate>(_ relation: Relation<R>,
                                                                                      in model: T,
                                                                                      predicate: P,
                                                                                      sorted sort: [SortDescriptor<R>] = [],
                                                                                      limit: Int? = nil,
                                                                                      callback: @escaping ([R]) -> Void)
        where T.Container: Object, R.Container: Object, P.ModelType == R {
        fetchRelation(relation,
                      in: model,
                      with: .predicate(predicate: predicate.predicate),
                      sorted: sort.isEmpty ? .unsorted : .init(sortDescriptors: sort),
                      limit: limit,
                      callback: callback)
    }

    public func fetchRelation<T: UniquelyMappable, R: UniquelyMappable & KeyPathConvertible>(_ relation: Relation<R>,
                                                                                             in model: T,
                                                                                             sorted sort: [SortDescriptor<R>] = [],
                                                                                             limit: Int? = nil,
                                                                                             callback: @escaping ([R]) -> Void)
        where T.Container: Object, R.Container: Object {
        fetchRelation(relation,
                      in: model,
                      with: .unfiltered,
                      sorted: sort.isEmpty ? .unsorted : .init(sortDescriptors: sort),
                      limit: limit,
                      callback: callback)
    }

    public func syncFetchRelation<T: UniquelyMappable, R: UniquelyMappable, P: Predicate>(_ relation: Relation<R>,
                                                                                          in model: T,
                                                                                          predicate: P,
                                                                                          sorted sort: [SortDescriptor<R>] = [],
                                                                                          limit: Int? = nil) -> [R]
        where T.Container: Object, R.Container: Object, P.ModelType == R {
        return syncFetchRelation(relation,
                                 in: model,
                                 with: .predicate(predicate: predicate.predicate),
                                 sorted: sort.isEmpty ? .unsorted : .init(sortDescriptors: sort),
                                 limit: limit)
    }

    public func syncFetchRelation<T: UniquelyMappable, R: UniquelyMappable & KeyPathConvertible>(_ relation: Relation<R>,
                                                                                                 in model: T,
                                                                                                 sorted sort: [SortDescriptor<R>] = [],
                                                                                                 limit: Int? = nil) -> [R]
        where T.Container: Object, R.Container: Object {
        return syncFetchRelation(relation,
                                 in: model,
                                 with: .unfiltered,
                                 sorted: sort.isEmpty ? .unsorted : .init(sortDescriptors: sort),
                                 limit: limit)
    }

    public func fetchRelation<T: UniquelyMappable, R: UniquelyMappable, P: Predicate>(_ relation: Relation<R>,
                                                                                      in model: T,
                                                                                      predicate: P,
                                                                                      sorted sort: [SortDescriptor<R>] = [],
                                                                                      limit: Int? = nil,
                                                                                      callback: @escaping ([R]) -> Void,
                                                                                      next: (([R], Bool) -> Void)? = nil,
                                                                                      updates: @escaping (DatabaseObserveUpdate<R>) -> Void)
            -> DatabaseUpdatesToken where T.Container: Object, R.Container: Object, P.ModelType == R {
        return fetchRelation(relation,
                             in: model,
                             with: .predicate(predicate: predicate.predicate),
                             sorted: sort.isEmpty ? .unsorted : .init(sortDescriptors: sort),
                             limit: limit,
                             callback: callback,
                             next: next,
                             updates: updates)
    }

    public func fetchRelation<T: UniquelyMappable, R: UniquelyMappable & KeyPathConvertible>(_ relation: Relation<R>,
                                                                                             in model: T,
                                                                                             sorted sort: [SortDescriptor<R>] = [],
                                                                                             limit: Int? = nil,
                                                                                             callback: @escaping ([R]) -> Void,
                                                                                             next: (([R], Bool) -> Void)? = nil,
                                                                                             updates: @escaping (DatabaseObserveUpdate<R>) -> Void)
            -> DatabaseUpdatesToken where T.Container: Object, R.Container: Object {
        return fetchRelation(relation,
                             in: model,
                             with: .unfiltered,
                             sorted: sort.isEmpty ? .unsorted : .init(sortDescriptors: sort),
                             limit: limit,
                             callback: callback,
                             next: next,
                             updates: updates)
    }
}


extension RealmService {
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
                let values = results.limited(newLimit).compactMap({ try? T.mappable(for: $0) })
                let old = min(results.count, oldLimit ?? Int.max)
                let new = min(results.count, newLimit ?? Int.max)
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
                let values = results.limited(in: oldLimit..<newLimit).compactMap({ try? T.mappable(for: $0) })
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
