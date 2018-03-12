//
// Created by Mikhail Mulyar on 16/12/2017.
// Copyright (c) 2017 Mikhail Mulyar. All rights reserved.
//

import Foundation


public class DatabaseService: DatabaseServiceProtocol {

    internal let realmService: RealmDatabaseService?
    internal let coreDataService: CoreDataService?

    //sourcery: swinjectInitializer
    public convenience init() {
        self.init(realmService: RealmDatabaseService())
    }

    public init(realmService: RealmDatabaseService? = nil, coreDataService: CoreDataService? = nil) {
        self.realmService = realmService
        self.coreDataService = coreDataService
    }

    public func deleteAll() {
        self.realmService?.deleteAll()
        self.coreDataService?.deleteAll()
    }

    public func store<T: DatabaseMappable>(object: T, update: Bool) {
        fatalError("store(object:update:) has not been implemented for this type")
    }

    public func store<T: DatabaseMappable>(objects: [T], update: Bool) {
        fatalError("store(objects:update:) has not been implemented for this type")
    }

    public func update<T: DatabaseMappable>(object: T) {
        fatalError("update(object:) has not been implemented for this type")
    }

    public func update<T: DatabaseMappable>(objects: [T]) {
        fatalError("update(objects:) has not been implemented for this type")
    }

    public func update<T: DatabaseMappable>(objectOf type: T.Type, withPrimaryKey key: PrimaryKeyValue, updates: T.DatabaseUpdates) {
        fatalError("update(type:key:updates:) has not been implemented for this type")
    }

    public func update<T: DatabaseMappable>(objectOf type: T.Type, withPrimaryKey key: PrimaryKeyValue, relationships: [DatabaseRelationshipUpdate]) {
        fatalError("update(type:key:relationships:) has not been implemented for this type")
    }

    public func update<T: DatabaseMappable>(objectOf type: T.Type,
                                            withPrimaryKey key: PrimaryKeyValue,
                                            updates: T.DatabaseUpdates,
                                            relationships: [DatabaseRelationshipUpdate]) {
        fatalError("update(type:key:updates:relationships:) has not been implemented for this type")
    }

    public func delete<T: DatabaseMappable>(object: T) {
        fatalError("delete(object:) has not been implemented for this type")
    }

    public func delete<T: DatabaseMappable>(objects: [T]) {
        fatalError("delete(objects:) has not been implemented for this type")
    }

    public func deleteAll<T: DatabaseMappable>(objectsOf type: T.Type) {
        fatalError("deleteAll(type:) has not been implemented for this type")
    }

    public func fetch<T: DatabaseMappable>(objectsOf type: T.Type,
                                           with filter: DatabaseFilterType,
                                           with sort: DatabaseSortType,
                                           callback: @escaping (Array<T>) -> Void) {
        fatalError("fetch(type:filter:sort:callback:) has not been implemented for this type")
    }

    public func syncFetch<T: DatabaseMappable>(objectsOf type: T.Type,
                                               with filter: DatabaseFilterType,
                                               with sort: DatabaseSortType) -> Array<T> {
        fatalError("syncFetch(type:filter:sort:) has not been implemented for this type")
    }

    public func fetch<T: DatabaseMappable>(objectsOf type: T.Type,
                                           with filter: DatabaseFilterType,
                                           with sort: DatabaseSortType,
                                           callback: @escaping (Array<T>) -> Void,
                                           updates: @escaping (DatabaseObserveUpdate<T>) -> Void) -> DatabaseUpdatesToken {
        fatalError("fetch(type:filter:sort:callback:updates:) has not been implemented for this type")
    }

    public func fetch<T: DatabaseMappable>(objectOf type: T.Type, withPrimaryKey key: PrimaryKeyValue, callback: @escaping (T?) -> Void) {
        fatalError("fetch(type:key:callback:) has not been implemented for this type")
    }

    public func syncFetch<T: DatabaseMappable>(objectOf type: T.Type, withPrimaryKey key: PrimaryKeyValue) -> T? {
        fatalError("syncFetch(type:key:) has not been implemented for this type")
    }


    public func fetch<T: DatabaseMappable>(objectOf type: T.Type,
                                           withPrimaryKey key: PrimaryKeyValue,
                                           callback: @escaping (T?) -> Void,
                                           updates: @escaping (DatabaseObjectUpdate<T>) -> Void) -> DatabaseUpdatesToken {
        fatalError("fetch(type:key:callback:updates:) has not been implemented for this type")
    }
}
