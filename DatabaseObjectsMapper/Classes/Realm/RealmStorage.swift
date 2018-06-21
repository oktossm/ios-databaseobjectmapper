//
// Created by Mikhail Mulyar on 20/12/2017.
// Copyright (c) 2017 Mikhail Mulyar. All rights reserved.
//

import Foundation
import RealmSwift
import Realm


extension Results {
    func sort(_ sort: DatabaseSortType) -> Results<Element> {
        switch sort {
        case .unsorted: return self
        case .byKeyPath(let path, let ascending): return self.sorted(byKeyPath: path, ascending: ascending)
        case .sortDescriptors(let descriptors): return self.sorted(by: descriptors.compactMap {
            descriptor -> SortDescriptor? in
            guard let keyPath = descriptor.key else {
                return nil
            }
            return SortDescriptor(keyPath: keyPath, ascending: descriptor.ascending)
        })
        }
    }

    func filter(_ filter: DatabaseFilterType) -> Results<Element> {
        switch filter {
        case .unfiltered: return self
        case .query(let query): return self.filter(query)
        case .predicate(let predicate): return self.filter(predicate)
        }
    }
}


extension DatabaseUpdatesToken {
    public convenience init(notificationToken: NotificationToken) {
        self.init { notificationToken.invalidate() }
    }

    public func setNotificationToken(_ token: NotificationToken) {
        self.invalidation = { token.invalidate() }
    }
}


/// Provides an interface for performing various actions on a realm during a write transaction. This type should only every be used during a write call on a RealmOperator.
public struct RealmWriteTransaction {
    private let realm: Realm

    /// Creates a new WriteTransaction with the given Realm.
    public init(realm: Realm) {
        self.realm = realm
    }

    /// Adds or updates an existing DatabaseMappable type into the Realm.
    /// - parameter value: The value to be added to the realm.
    /// - parameter update: If true, the Realm will try to find a value with the same primary key and update it. Otherwise, the value will be added.
    public func add<T: DatabaseMappable>(_ value: T, update: Bool) throws where T.DatabaseType: Object {
        let object = try value.createObject(userInfo: nil)
        realm.add(object, update: update)
    }

    /// Updates an existing DatabaseMappable type in the Realm.
    /// - parameter value: The value to be added to the realm.
    public func update<T: DatabaseMappable>(_ value: T) throws where T.DatabaseType: Object {
        guard let object = realm.object(ofType: T.DatabaseType.self, forPrimaryKey: value.primaryKeyValue.value) else { return }
        value.update(object)
        realm.add(object, update: true)
    }

    /// Updates an existing sequence of DatabaseMappable types in the Realm.
    /// - parameter values: The sequence of values to be added to the realm.
    public func update<S: Sequence>(_ values: S) throws where S.Element: DatabaseMappable, S.Element.DatabaseType: Object {
        try values.forEach { try self.update($0) }
    }

    /// Updates an existing DatabaseMappable type in the Realm.
    /// - parameter objectOf: The type of the value to be updated.
    /// - parameter key: The primary key of the value.
    /// - parameter updates: Dictionary of values and keys to be updated
    public func update<T: DatabaseMappable>(objectOf type: T.Type,
                                            withPrimaryKey key: PrimaryKeyContainer,
                                            updates: T.DatabaseUpdates) where T.DatabaseType: Object {
        if case .none = key {
            assertionFailure("Key must exist")
            return
        }
        let primaryKey = T.primaryKeyMapped(for: key)
        guard let object = realm.object(ofType: T.DatabaseType.self, forPrimaryKey: primaryKey.value) else { return }
        guard var model = try? T.createMappable(from: object) else { return }

        model = model.updated(updates)

        guard let newObject = try? model.createObject(userInfo: nil) else { return }

        realm.add(newObject, update: true)
    }

    /// Updates an existing DatabaseMappable type in the Realm.
    /// - parameter objectOf: The type of the value to be updated.
    /// - parameter key: The primary key of the value.
    /// - parameter relationships: Relationships updates
    public func update<T: DatabaseMappable>(objectOf type: T.Type,
                                            withPrimaryKey key: PrimaryKeyContainer,
                                            relationships: [DatabaseRelationshipUpdate]) where T.DatabaseType: Object {
        if case .none = key {
            assertionFailure("Key must exist")
            return
        }
        guard let realmObject = realm.object(ofType: T.DatabaseType.self, forPrimaryKey: T.primaryKeyMapped(for: key).value) else { return }

        T.update(realmObject, with: relationships)
    }

    /// Adds or updates an existing sequence of DatabaseMappable types into the Realm.
    /// - parameter values: The sequence of values to be added to the realm.
    /// - parameter update: If true, the Realm will try to find values with the same primary keys and update them. Otherwise, the values will be added.
    public func add<S: Sequence>(_ values: S, update: Bool) throws where S.Element: DatabaseMappable, S.Element.DatabaseType: Object {
        let mapped = try values.map { try $0.createObject(userInfo: nil) }
        realm.add(mapped, update: update)
    }

    /// Deletes a DatabaseMappable type from the Realm.
    /// - parameter value: The value to be deleted from the realm.
    /// - returns: Returns true if object found and deleted.
    public func delete<T: DatabaseMappable>(_ value: T) -> Bool where T.DatabaseType: Object {
        guard let container = realm.object(ofType: T.DatabaseType.self,
                                           forPrimaryKey: value.primaryKeyValue.value) else { return false }
        realm.delete(container)
        return true
    }

    /// Deletes a sequence of DatabaseMappable types from the Realm.
    /// - parameter values: The sequence of values to be deleted from the realm.
    public func delete<S: Sequence>(_ values: S) where S.Element: DatabaseMappable, S.Element.DatabaseType: Object {
        values.forEach { _ = delete($0) }
    }

    /// Deletes all DatabaseMappable objects of given type.
    /// - parameter ofType: The type of the values to be deleted.
    public func deleteAll<T: DatabaseMappable>(objectsOf type: T.Type) where T.DatabaseType: Object {
        var objects: Results<T.DatabaseType> = realm.objects(T.DatabaseType.self)

        if let predicate = T.internalPredicate() {
            objects = objects.filter(predicate)
        }

        realm.delete(objects)
    }

    /// Deletes all objects from the Realm.
    public func deleteAll() {
        realm.deleteAll()
    }
}


/// Provides an interface for performing various actions on a realm.
class RealmOperator: NSObject {
    private let realm: Realm

    /// Creates a new RealmOperator with the given Realm.
    public init(realm: Realm) {
        self.realm = realm
    }

    /// Performs actions on the Realm within a write transaction.
    /// - parameter block: The actions to perform.
    func write(_ block: (RealmWriteTransaction) throws -> Void) throws {
        let transaction = RealmWriteTransaction(realm: realm)
        try realm.write {
            try block(transaction)
        }
    }

    /// Performs actions on the Realm within a write transaction.
    /// - parameter blocks: The actions to perform.
    func write(_ blocks: [(RealmWriteTransaction) throws -> Void]) throws {
        let transaction = RealmWriteTransaction(realm: realm)
        try realm.write {
            try blocks.forEach {
                try $0(transaction)
            }
        }
    }

    /// Returns all values of the given type stored in the Realm.
    /// - parameter ofType: The type of the values to be returned.
    /// - returns: A `QPResults` containing all the values.
    func values<T: DatabaseMappable>(ofType: T.Type) -> Results<T.DatabaseType> where T.DatabaseType: Object {
        var objects: Results<T.DatabaseType> = realm.objects(T.DatabaseType.self)

        if let predicate = T.internalPredicate() {
            objects = objects.filter(predicate)
        }

        return objects
    }

    /// Returns a value with the given primary key stored in the Realm.
    /// - parameter ofType: The type of the value to be returned.
    /// - parameter key: The primary key of the value.
    /// - returns: The value or `nil` if no instance with the given primary key exists.
    func value<T: DatabaseMappable>(ofType: T.Type, withPrimaryKey key: PrimaryKeyContainer) -> T.DatabaseType? where T.DatabaseType: Object {
        if case .none = key {
            assertionFailure("Key must exist")
            return nil
        }
        guard let container = realm.object(ofType: T.DatabaseType.self, forPrimaryKey: T.primaryKeyMapped(for: key).value) else { return nil }
        return container
    }
}
