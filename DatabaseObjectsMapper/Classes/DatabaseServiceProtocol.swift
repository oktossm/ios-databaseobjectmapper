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
    let values: Array<T>
    let deletions: [Int]
    let insertions: [Int]
    let modifications: [Int]
}


public enum DatabaseObjectUpdate<T> {
    case delete
    case update(object: T)
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

    /// Deletes all objects in database
    func deleteAll()

    /// Create and stores new object in database. By default updates if object with same primary key already exists.
    func store<T: DatabaseMappable>(object: T, update: Bool)

    /// Create and stores new objects in database. By default updates if object with same primary key already exists.
    func store<T: DatabaseMappable>(objects: [T], update: Bool)

    /// Fully updates object by primary key if it is already exists. If object not found nothing happens.
    func update<T: DatabaseMappable>(object: T)

    /// Fully updates objects by primary key if they are already exist. If object not found nothing happens.
    func update<T: DatabaseMappable>(objects: [T])

    /// Updates object of given type by primary key if its already exists. Updates only properties listed in updates.
    func update<T: DatabaseMappable>(objectOf type: T.Type, withPrimaryKey key: PrimaryKeyValue, updates: T.DatabaseUpdates)

    /// Updates relationships of object of given type by primary key if its already exists. Updates only relationships listed in updates.
    func update<T: DatabaseMappable>(objectOf type: T.Type, withPrimaryKey key: PrimaryKeyValue, relationships: [DatabaseRelationshipUpdate])

    /// Updates properties and relationships of object of given type by primary key if its already exists.
    func update<T: DatabaseMappable>(objectOf type: T.Type,
                                     withPrimaryKey key: PrimaryKeyValue,
                                     updates: T.DatabaseUpdates,
                                     relationships: [DatabaseRelationshipUpdate])

    /// Deletes object by primary key.
    func delete<T: DatabaseMappable>(object: T)

    /// Deletes objects by primary key.
    func delete<T: DatabaseMappable>(objects: [T])

    /// Deletes all objects of given type.
    func deleteAll<T: DatabaseMappable>(objectsOf type: T.Type)

    /// Fetches objects of given type with optional filter and sorting. Objects returns async in `callback`.
    func fetch<T: DatabaseMappable>(objectsOf type: T.Type,
                                    with filter: DatabaseFilterType,
                                    with sort: DatabaseSortType,
                                    callback: @escaping (Array<T>) -> Void)

    /// Fetches objects of given type with optional filter and sorting. Returns objects array.
    func syncFetch<T: DatabaseMappable>(objectsOf type: T.Type,
                                        with filter: DatabaseFilterType,
                                        with sort: DatabaseSortType) -> Array<T>

    /// Fetches objects of given type with optional filter and sorting and subscribes on their updates. First fetch returns async in `callback`.
    /// Next updates send in `updates` closure.
    /// - returns: `DatabaseUpdatesToken` to stop observing `updates`.
    func fetch<T: DatabaseMappable>(objectsOf type: T.Type,
                                    with filter: DatabaseFilterType,
                                    with sort: DatabaseSortType,
                                    callback: @escaping (Array<T>) -> Void,
                                    updates: @escaping (DatabaseObserveUpdate<T>) -> Void) -> DatabaseUpdatesToken

    /// Fetches object of given type and primary key. Object or nil returns async in callback.
    func fetch<T: DatabaseMappable>(objectOf type: T.Type, withPrimaryKey key: PrimaryKeyValue, callback: @escaping (T?) -> Void)

    /// Fetches object of given type and primary key. Returns object.
    func syncFetch<T: DatabaseMappable>(objectOf type: T.Type, withPrimaryKey key: PrimaryKeyValue) -> T?

    /// Fetches object of given type and primary key. Object or nil returns async in callback.
    /// Next updates send in `updates` closure.
    /// - returns: `DatabaseUpdatesToken` to stop observing `updates`.
    func fetch<T: DatabaseMappable>(objectOf type: T.Type,
                                    withPrimaryKey key: PrimaryKeyValue,
                                    callback: @escaping (T?) -> Void,
                                    updates: @escaping (DatabaseObjectUpdate<T>) -> Void) -> DatabaseUpdatesToken
}
