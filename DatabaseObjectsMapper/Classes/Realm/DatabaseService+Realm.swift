//
// Created by Mikhail Mulyar on 07/01/2018.
// Copyright (c) 2018 Mikhail Mulyar. All rights reserved.
//

import RealmSwift


public extension DatabaseMappable where DatabaseType: Object {
    public func createObject(userInfo: Any?) throws -> DatabaseType {
        return try self.createRealmObject(userInfo: userInfo)
    }

    public func createRealmObject(userInfo: Any?) throws -> DatabaseType {
        let object = DatabaseType()
        self.update(object)
        return object
    }
}


public extension DatabaseMappable where DatabaseType: Object & DatabaseContainerProtocol {
    public func createObject(userInfo: Any?) throws -> DatabaseType {
        return try self.createRealmObject(userInfo: userInfo)
    }
}


public protocol RealmDatabaseServiceProtocol: DatabaseServiceProtocol {

    func store<T: DatabaseMappable>(object: T, update: Bool) where T.DatabaseType: Object

    func store<T: DatabaseMappable>(objects: [T], update: Bool) where T.DatabaseType: Object

    func update<T: DatabaseMappable>(object: T) where T.DatabaseType: Object

    func update<T: DatabaseMappable>(objects: [T]) where T.DatabaseType: Object

    func update<T: DatabaseMappable>(objectOf type: T.Type,
                                     withPrimaryKey key: PrimaryKeyValue,
                                     updates: T.DatabaseUpdates) where T.DatabaseType: Object

    func update<T: DatabaseMappable>(objectOf type: T.Type,
                                     withPrimaryKey key: PrimaryKeyValue,
                                     relationships: [DatabaseRelationshipUpdate]) where T.DatabaseType: Object

    func update<T: DatabaseMappable>(objectOf type: T.Type,
                                     withPrimaryKey key: PrimaryKeyValue,
                                     updates: T.DatabaseUpdates,
                                     relationships: [DatabaseRelationshipUpdate]) where T.DatabaseType: Object

    func delete<T: DatabaseMappable>(object: T) where T.DatabaseType: Object

    func delete<T: DatabaseMappable>(objects: [T]) where T.DatabaseType: Object

    func deleteAll<T: DatabaseMappable>(objectsOf type: T.Type) where T.DatabaseType: Object

    func fetch<T: DatabaseMappable>(objectsOf type: T.Type,
                                    with filter: DatabaseFilterType,
                                    with sort: DatabaseSortType,
                                    callback: @escaping (Array<T>) -> Void) where T.DatabaseType: Object

    func syncFetch<T: DatabaseMappable>(objectsOf type: T.Type,
                                        with filter: DatabaseFilterType,
                                        with sort: DatabaseSortType) -> Array<T> where T.DatabaseType: Object

    func fetch<T: DatabaseMappable>(objectsOf type: T.Type,
                                    with filter: DatabaseFilterType,
                                    with sort: DatabaseSortType,
                                    callback: @escaping (Array<T>) -> Void,
                                    updates: @escaping (DatabaseObserveUpdate<T>) -> Void) -> DatabaseUpdatesToken where T.DatabaseType: Object

    func fetch<T: DatabaseMappable>(objectOf type: T.Type,
                                    withPrimaryKey key: PrimaryKeyValue,
                                    callback: @escaping (T?) -> Void) where T.DatabaseType: Object

    func syncFetch<T: DatabaseMappable>(objectOf type: T.Type,
                                        withPrimaryKey key: PrimaryKeyValue) -> T? where T.DatabaseType: Object

    func fetch<T: DatabaseMappable>(objectOf type: T.Type,
                                    withPrimaryKey key: PrimaryKeyValue,
                                    callback: @escaping (T?) -> Void,
                                    updates: @escaping (DatabaseObjectUpdate<T>) -> Void) -> DatabaseUpdatesToken where T.DatabaseType: Object
}


extension DatabaseService: RealmDatabaseServiceProtocol {
    public func store<T: DatabaseMappable>(object: T, update: Bool) where T.DatabaseType: Object {
        guard let service = self.realmService else {
            fatalError("RealmService is not set up properly")
        }
        service.store(object: object, update: update)
    }

    public func store<T: DatabaseMappable>(objects: [T], update: Bool) where T.DatabaseType: Object {
        guard let service = self.realmService else {
            fatalError("RealmService is not set up properly")
        }
        service.store(objects: objects, update: update)
    }

    public func update<T: DatabaseMappable>(object: T) where T.DatabaseType: Object {
        guard let service = self.realmService else {
            fatalError("RealmService is not set up properly")
        }
        service.update(object: object)
    }

    public func update<T: DatabaseMappable>(objects: [T]) where T.DatabaseType: Object {
        guard let service = self.realmService else {
            fatalError("RealmService is not set up properly")
        }
        service.update(objects: objects)
    }

    public func update<T: DatabaseMappable>(objectOf type: T.Type,
                                            withPrimaryKey key: PrimaryKeyValue,
                                            updates: T.DatabaseUpdates) where T.DatabaseType: Object {
        guard let service = self.realmService else {
            fatalError("RealmService is not set up properly")
        }
        service.update(objectOf: type, withPrimaryKey: key, updates: updates)
    }

    public func update<T: DatabaseMappable>(objectOf type: T.Type,
                                            withPrimaryKey key: PrimaryKeyValue,
                                            relationships: [DatabaseRelationshipUpdate]) where T.DatabaseType: Object {
        guard let service = self.realmService else {
            fatalError("RealmService is not set up properly")
        }
        service.update(objectOf: type, withPrimaryKey: key, relationships: relationships)
    }

    public func update<T: DatabaseMappable>(objectOf type: T.Type,
                                            withPrimaryKey key: PrimaryKeyValue,
                                            updates: T.DatabaseUpdates,
                                            relationships: [DatabaseRelationshipUpdate]) where T.DatabaseType: Object {
        guard let service = self.realmService else {
            fatalError("RealmService is not set up properly")
        }
        service.update(objectOf: type, withPrimaryKey: key, updates: updates, relationships: relationships)
    }

    public func delete<T: DatabaseMappable>(object: T) where T.DatabaseType: Object {
        guard let service = self.realmService else {
            fatalError("RealmService is not set up properly")
        }
        service.delete(object: object)
    }

    public func delete<T: DatabaseMappable>(objects: [T]) where T.DatabaseType: Object {
        guard let service = self.realmService else {
            fatalError("RealmService is not set up properly")
        }
        service.delete(objects: objects)
    }

    public func deleteAll<T: DatabaseMappable>(objectsOf type: T.Type) where T.DatabaseType: Object {
        guard let service = self.realmService else {
            fatalError("RealmService is not set up properly")
        }
        service.deleteAll(objectsOf: type)
    }

    public func fetch<T: DatabaseMappable>(objectsOf type: T.Type,
                                           with filter: DatabaseFilterType,
                                           with sort: DatabaseSortType,
                                           callback: @escaping (Array<T>) -> Void) where T.DatabaseType: Object {
        guard let service = self.realmService else {
            fatalError("RealmService is not set up properly")
        }
        service.fetch(objectsOf: type, with: filter, with: sort, callback: callback)
    }

    public func syncFetch<T: DatabaseMappable>(objectsOf type: T.Type,
                                               with filter: DatabaseFilterType,
                                               with sort: DatabaseSortType) -> Array<T> where T.DatabaseType: Object {
        guard let service = self.realmService else {
            fatalError("RealmService is not set up properly")
        }
        return service.syncFetch(objectsOf: type, with: filter, with: sort)
    }

    public func fetch<T: DatabaseMappable>(objectsOf type: T.Type,
                                           with filter: DatabaseFilterType,
                                           with sort: DatabaseSortType,
                                           callback: @escaping (Array<T>) -> Void,
                                           updates: @escaping (DatabaseObserveUpdate<T>) -> Void) -> DatabaseUpdatesToken where T.DatabaseType: Object {
        guard let service = self.realmService else {
            fatalError("RealmService is not set up properly")
        }
        return service.fetch(objectsOf: type, with: filter, with: sort, callback: callback, updates: updates)
    }

    public func fetch<T: DatabaseMappable>(objectOf type: T.Type,
                                           withPrimaryKey key: PrimaryKeyValue,
                                           callback: @escaping (T?) -> Void) where T.DatabaseType: Object {
        guard let service = self.realmService else {
            fatalError("RealmService is not set up properly")
        }
        service.fetch(objectOf: type, withPrimaryKey: key, callback: callback)

    }

    public func syncFetch<T: DatabaseMappable>(objectOf type: T.Type,
                                               withPrimaryKey key: PrimaryKeyValue) -> T? where T.DatabaseType: Object {
        guard let service = self.realmService else {
            fatalError("RealmService is not set up properly")
        }
        return service.syncFetch(objectOf: type, withPrimaryKey: key)
    }

    public func fetch<T: DatabaseMappable>(objectOf type: T.Type,
                                           withPrimaryKey key: PrimaryKeyValue,
                                           callback: @escaping (T?) -> Void,
                                           updates: @escaping (DatabaseObjectUpdate<T>) -> Void) -> DatabaseUpdatesToken where T.DatabaseType: Object {
        guard let service = self.realmService else {
            fatalError("RealmService is not set up properly")
        }
        return service.fetch(objectOf: type, withPrimaryKey: key, callback: callback, updates: updates)
    }
}