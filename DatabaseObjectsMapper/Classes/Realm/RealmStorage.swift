//
// Created by Mikhail Mulyar on 20/12/2017.
// Copyright (c) 2017 Mikhail Mulyar. All rights reserved.
//

import Foundation
import RealmSwift
import Realm


extension AnyRealmCollection {
    func sort(_ sort: DatabaseSortType) -> AnyRealmCollection<Element> {
        switch sort {
        case .unsorted: return self
        case .byKeyPath(let path, let ascending): return AnyRealmCollection(self.sorted(byKeyPath: path, ascending: ascending))
        case .sortDescriptors(let descriptors): return AnyRealmCollection(self.sorted(by: descriptors.compactMap {
            descriptor -> RealmSwift.SortDescriptor? in
            guard let keyPath = descriptor.key else {
                return nil
            }
            return RealmSwift.SortDescriptor(keyPath: keyPath, ascending: descriptor.ascending)
        }))
        }
    }

    func filter(_ filter: DatabaseFilterType) -> AnyRealmCollection<Element> {
        switch filter {
        case .unfiltered: return self
        case .query(let query): return AnyRealmCollection(self.filter(query))
        case .predicate(let predicate): return AnyRealmCollection(self.filter(predicate))
        }
    }

    func limited(_ limit: Index?) -> [Element] {
        guard let limit = limit else { return Array(self) }
        return Array(self[0..<Swift.min(self.endIndex, limit)])
    }

    func limited(in range: Range<Index>?) -> [Element] {
        guard let range = range else { return Array(self) }
        guard range.lowerBound < self.endIndex, range.upperBound > self.startIndex else { return [] }
        let lower = Swift.max(self.startIndex, range.lowerBound)
        let upper = Swift.min(self.endIndex, range.upperBound)
        return Array(self[lower..<upper])
    }
}


extension DatabaseUpdatesToken {
    convenience init(notificationToken: NotificationToken) {
        self.init(invalidation: { notificationToken.invalidate() })
    }

    func setNotificationToken(_ token: NotificationToken) {
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
    public func add<T: DatabaseMappable>(_ value: T, update: Bool) throws where T.Container: Object {
        let object = try value.container(with: nil)
        realm.add(object, update: update ? .all : .error)
    }

    /// Updates an existing DatabaseMappable type in the Realm.
    /// - parameter value: The value to be added to the realm.
    public func update<T: UniquelyMappable>(_ value: T) throws where T.Container: Object {
        guard let object = realm.object(ofType: T.Container.self, forPrimaryKey: value.objectKeyValue) else { return }
        value.update(object)
        realm.add(object, update: .all)
    }

    /// Updates an existing sequence of DatabaseMappable types in the Realm.
    /// - parameter values: The sequence of values to be added to the realm.
    public func update<S: Sequence>(_ values: S) throws where S.Element: UniquelyMappable, S.Element.Container: Object {
        try values.forEach { try self.update($0) }
    }

    /// Updates an existing DatabaseMappable type in the Realm.
    /// - parameter objectOf: The type of the value to be updated.
    /// - parameter key: The primary key of the value.
    /// - parameter updates: Dictionary of values and keys to be updated
    public func update<T: UniquelyMappable>(modelOf type: T.Type,
                                            with key: T.ID,
                                            updates: [String: Any?]) where T.Container: Object {
        let updates: [String: Any?] = updates.mapValues {
            if let mappable = $0 as? DictionaryCodable {
                return mappable.encodedValue
            } else {
                return $0
            }
        }
        guard let object = realm.object(ofType: T.Container.self, forPrimaryKey: T.idMapping(key)),
              let model = try? T.mappable(for: object) else { return }
        var encoded = model.encodedValue.merging(updates.compactMapValues { $0 }) { $1 }
        updates.filter { $0.value == nil }.forEach { encoded[$0.key] = nil }
        guard let new = T(encoded) else { return }
        new.update(object)
    }

    /// Updates relation in existing DatabaseMappable type in the Realm.
    /// - parameter relation: Relation instance.
    /// - parameter model: Model to update.
    /// - parameter update: Relation.Update value
    public func updateRelation<T: UniquelyMappable, R: UniquelyMappable>(_ relation: Relation<R>, in model: T, with update: Relation<R>.Update)
            where T.Container: Object, R.Container: Object {
        guard let key = Mirror(reflecting: model).children.first(where: { relation === (unwrapUsingProtocol($0.value) as AnyObject) })?.label,
              let object = realm.object(ofType: T.Container.self, forPrimaryKey: model.objectKeyValue) else { return }
        guard relation.type == .direct, let list = object[key] as? List<R.Container> else { return }
        switch update {
        case .set(let keys):
            let objects = keys.compactMap { realm.object(ofType: R.Container.self, forPrimaryKey: R.idMapping($0)) }
            list.removeAll()
            list.append(objectsIn: objects)
        case .add(let keys):
            let objects = keys.compactMap { realm.object(ofType: R.Container.self, forPrimaryKey: R.idMapping($0)) }
            list.append(objectsIn: objects)
        case .remove(let keys):
            let objects = keys.compactMap { realm.object(ofType: R.Container.self, forPrimaryKey: R.idMapping($0)) }
            objects.forEach { list.index(of: $0).flatMap { list.remove(at: $0) } }
        case .addModels(let models):
            let objects = models.compactMap { try? $0.container(with: nil) }
            list.append(objectsIn: objects)
        case .setModels(let models):
            let objects = models.compactMap { try? $0.container(with: nil) }
            list.removeAll()
            list.append(objectsIn: objects)
        }
    }


    /// Adds or updates an existing sequence of DatabaseMappable types into the Realm.
    /// - parameter values: The sequence of values to be added to the realm.
    /// - parameter update: If true, the Realm will try to find values with the same primary keys and update them. Otherwise, the values will be added.
    public func add<S: Sequence>(_ values: S, update: Bool) throws where S.Element: DatabaseMappable, S.Element.Container: Object {
        let mapped = try values.map { try $0.container(with: nil) }
        realm.add(mapped, update: update ? .all : .error)
    }

    /// Deletes a DatabaseMappable type from the Realm.
    /// - parameter value: The value to be deleted from the realm.
    /// - returns: Returns true if object found and deleted.
    public func delete<T: UniquelyMappable>(_ value: T) -> Bool where T.Container: Object {
        guard let container = realm.object(ofType: T.Container.self, forPrimaryKey: value.objectKeyValue) else { return false }
        realm.delete(container)
        return true
    }

    /// Deletes a sequence of DatabaseMappable types from the Realm.
    /// - parameter values: The sequence of values to be deleted from the realm.
    public func delete<S: Sequence>(_ values: S) where S.Element: UniquelyMappable, S.Element.Container: Object {
        values.forEach { _ = delete($0) }
    }

    /// Deletes all DatabaseMappable objects of given type.
    /// - parameter ofType: The type of the values to be deleted.
    public func deleteAll<T: DatabaseMappable>(modelsOf type: T.Type) where T.Container: Object {
        var objects: Results<T.Container> = realm.objects(T.Container.self)

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
    func values<T: DatabaseMappable>(ofType: T.Type) -> AnyRealmCollection<T.Container> where T.Container: Object {
        var objects: Results<T.Container> = realm.objects(T.Container.self)
        if let predicate = T.internalPredicate() {
            objects = objects.filter(predicate)
        }
        return AnyRealmCollection(objects)
    }

    /// Returns a value with the given primary key stored in the Realm.
    /// - parameter ofType: The type of the value to be returned.
    /// - parameter key: The primary key of the value.
    /// - returns: The value or `nil` if no instance with the given primary key exists.
    func value<T: UniquelyMappable>(ofType: T.Type, with key: T.ID) -> T.Container? where T.Container: Object {
        guard let container = realm.object(ofType: T.Container.self, forPrimaryKey: T.idMapping(key)) else { return nil }
        return container
    }

    /// Returns all values of the given relation in model stored in the Realm.
    /// - parameter model: Model with relation.
    /// - parameter keyPath: KeyPath for relation.
    /// - returns: A `QPResults` containing all the values.
    func relationValues<T: UniquelyMappable, R: UniquelyMappable>(_ relation: Relation<R>, in model: T)
                    -> AnyRealmCollection<R.Container>? where T.Container: Object, R.Container: Object {
        guard let key = Mirror(reflecting: model).children.first(where: { relation === (unwrapUsingProtocol($0.value) as AnyObject) })?.label,
              let object = realm.object(ofType: T.Container.self, forPrimaryKey: model.objectKeyValue) else { return nil }
        switch relation.type {
        case .direct:
            guard let list = object[key] as? List<R.Container> else { return nil }
            return AnyRealmCollection(list)
        case .inverse:
            guard let linked = object[key] as? LinkingObjects<R.Container> else { return nil }
            return AnyRealmCollection(linked)
        }
    }
}
