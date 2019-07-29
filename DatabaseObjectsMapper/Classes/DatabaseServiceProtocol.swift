//
// Created by Mikhail Mulyar on 20/12/2017.
// Copyright (c) 2017 Mikhail Mulyar. All rights reserved.
//

import Foundation


public enum DatabaseSortType {
    case unsorted
    case byKeyPath(keyPath: String, ascending: Bool)
    case sortDescriptors(sortDescriptors: [NSSortDescriptor])

    var sortDescriptors: [NSSortDescriptor]? {
        switch self {
        case .unsorted: return nil
        case .byKeyPath(let keyPath, let ascending): return [NSSortDescriptor(key: keyPath, ascending: ascending)]
        case .sortDescriptors(let sortDescriptors): return sortDescriptors
        }
    }
}


public enum DatabaseFilterType {
    case unfiltered
    case query(query: String)
    case predicate(predicate: NSPredicate)

    var predicate: NSPredicate? {
        switch self {
        case .unfiltered: return nil
        case .query(let query): return NSPredicate(format: query, argumentArray: nil)
        case .predicate(let predicate): return predicate
        }
    }
}


public struct DatabaseObserveUpdate<T> {
    public let values: Array<T>
    public let deletions: [Int]
    public let insertions: [Int]
    public let modifications: [Int]
}


public enum DatabaseModelUpdate<T> {
    case delete
    case update(model: T)
}


public class DatabaseUpdatesToken {
    var invalidation: (() -> Void)

    public var isInvalidated: Bool = false

    public init(invalidation: @escaping (() -> Void)) {
        self.invalidation = invalidation
    }

    public func invalidate() {
        self.isInvalidated = true
        self.invalidation()
    }
}


public protocol DatabaseServiceProtocol {

    // MARK: Managing

    /// Deletes all models in database
    func deleteAll()

    /// Create and stores new model in database. Function for non unique models
    func simpleSave<T: DatabaseMappable>(model: T)

    /// Create and stores new models in database. Function for non unique models
    func simpleSave<T: DatabaseMappable>(models: [T])

    /// Create and stores new model in database. By default updates if model with same id already exists.
    func save<T: UniquelyMappable>(model: T, update: Bool)

    /// Create and stores new model in database. By default updates if model with same id already exists.
    func save<T: UniquelyMappable, R: UniquelyMappable>(model: T, update: Bool, relation: Relation<R>, with relationUpdate: Relation<R>.Update)

    /// Create and stores new models in database. By default updates if model with same id already exists.
    func save<T: UniquelyMappable>(models: [T], update: Bool)

    /// Fully updates model by id if it is already exists. If model not found nothing happens.
    func update<T: UniquelyMappable>(model: T)

    /// Fully updates models by id if they are already exist. If model not found nothing happens.
    func update<T: UniquelyMappable>(models: [T])

    /// Updates model of given type by id if its already exists. Updates only properties listed in updates.
    func update<T: UniquelyMappable>(modelOf type: T.Type, with key: T.ID, updates: [String: Any?])

    ///  Updates model by id if it is already exists with relation updates. If model not found nothing happens.
    func updateRelation<T: UniquelyMappable, R: UniquelyMappable>(_ relation: Relation<R>, in model: T, with update: Relation<R>.Update)

    /// Deletes model by id.
    func delete<T: UniquelyMappable>(model: T)

    /// Deletes models by id.
    func delete<T: UniquelyMappable>(models: [T])

    /// Deletes all models of given type.
    func deleteAll<T: DatabaseMappable>(modelsOf type: T.Type)

    // MARK: Fetching

    /// Fetches models of given type with optional filter and sorting. Objects returns async in `callback`.
    func fetch<T: DatabaseMappable>(with filter: DatabaseFilterType, with sort: DatabaseSortType, callback: @escaping (Array<T>) -> Void)

    /// Fetches models of given type with optional filter and sorting. Returns models array.
    func syncFetch<T: DatabaseMappable>(with filter: DatabaseFilterType, with sort: DatabaseSortType) -> Array<T>

    /// Fetches models of given type with optional filter and sorting and subscribes on their updates. First fetch returns async in `callback`.
    /// Next updates send in `updates` closure.
    /// - returns: `DatabaseUpdatesToken` to stop observing `updates`.
    func fetch<T: DatabaseMappable>(with filter: DatabaseFilterType,
                                    with sort: DatabaseSortType,
                                    callback: @escaping (Array<T>) -> Void,
                                    updates: @escaping (DatabaseObserveUpdate<T>) -> Void) -> DatabaseUpdatesToken

    /// Fetches model of given type and id. Object or nil returns async in callback.
    func fetch<T: UniquelyMappable>(modelOf type: T.Type, with key: T.ID, callback: @escaping (T?) -> Void)

    /// Fetches model of given type and id. Returns model.
    func syncFetch<T: UniquelyMappable>(modelOf type: T.Type, with key: T.ID) -> T?

    /// Fetches model of given type and id. Object or nil returns async in callback.
    /// Next updates send in `updates` closure.
    /// - returns: `DatabaseUpdatesToken` to stop observing `updates`.
    func fetch<T: UniquelyMappable>(with key: T.ID,
                                    callback: @escaping (T?) -> Void,
                                    updates: @escaping (DatabaseModelUpdate<T>) -> Void) -> DatabaseUpdatesToken

    // MARK: Relations

    /// Fetches relation models of given type with optional filter and sorting. Objects returns async in `callback`.
    func fetchRelation<T: UniquelyMappable, R: UniquelyMappable>(_ relation: Relation<R>,
                                                                 in model: T,
                                                                 with filter: DatabaseFilterType,
                                                                 with sort: DatabaseSortType,
                                                                 callback: @escaping (Array<R>) -> Void)

    /// Fetches relation models of given type with optional filter and sorting. Returns models array.
    func syncFetchRelation<T: UniquelyMappable, R: UniquelyMappable>(_ relation: Relation<R>,
                                                                     in model: T,
                                                                     with filter: DatabaseFilterType,
                                                                     with sort: DatabaseSortType) -> Array<R>

    /// Fetches relation models of given type with optional filter and sorting and subscribes on their updates.
    /// First fetch returns async in `callback`. Next updates send in `updates` closure.
    /// - returns: `DatabaseUpdatesToken` to stop observing `updates`.
    func fetchRelation<T: UniquelyMappable, R: UniquelyMappable>(_ relation: Relation<R>,
                                                                 in model: T,
                                                                 with filter: DatabaseFilterType,
                                                                 with sort: DatabaseSortType,
                                                                 callback: @escaping (Array<R>) -> Void,
                                                                 updates: @escaping (DatabaseObserveUpdate<R>) -> Void) -> DatabaseUpdatesToken
}
