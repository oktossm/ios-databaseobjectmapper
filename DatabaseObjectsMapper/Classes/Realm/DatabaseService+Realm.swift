//
// Created by Mikhail Mulyar on 07/01/2018.
// Copyright (c) 2018 Mikhail Mulyar. All rights reserved.
//

import RealmSwift
import Realm


public extension DatabaseMappable where Container: Object {
    func container(with userInfo: Any?) throws -> Container {
        return try self.realmObject(with: userInfo)
    }

    func realmObject(with userInfo: Any?) throws -> Container {
        let object = Container()
        self.update(object)
        return object
    }
}


public extension DatabaseMappable where Container: Object & SharedDatabaseContainer {
    func container(with userInfo: Any?) throws -> Container {
        return try self.realmObject(with: userInfo)
    }

    func containerSkippingRelation(with userInfo: Any?) throws -> Container {
        let object = Container()
        self.updateSkippingRelations(object, updates: encodedValue)
        return object
    }

    func updateSkippingRelations(_ container: Container, updates: [String: Any]) {
        container.typeName = Self.typeName
        updateProperties(for: container, updates: updates)
        updateId(for: container)
    }

    func update(_ container: Container, updates: [String: Any]) {
        container.typeName = Self.typeName
        updateProperties(for: container, updates: updates)
        updateRelationships(for: container)
        updateId(for: container)
    }

    static func internalPredicate() -> NSPredicate? {
        return NSPredicate(format: "typeName == %@", argumentArray: [Self.typeName])
    }
}


public extension UniquelyMappable where Container: Object {
    func existingContainer(with userInfo: Any?) throws -> AnyDatabaseContainer? {
        let realm = (userInfo as? Realm) ?? (try! Realm())
        return realm.object(ofType: Container.self, forPrimaryKey: self.objectKeyValue)
    }

    func containerSkippingRelation(with userInfo: Any?) throws -> Container {
        let object = Container()
        self.updateSkippingRelations(object, updates: encodedValue)
        return object
    }

    func updateSkippingRelations(_ container: Container, updates: [String: Any]) {
        updateProperties(for: container, updates: updates)
        updateId(for: container)
    }

    func update(_ container: Container, updates: [String: Any]) {
        updateProperties(for: container, updates: updates)
        updateRelationships(for: container)
        updateId(for: container)
    }

    internal func updateId(for container: Container) {
        guard let keyPath = Container.idKey._kvcKeyPathString,
              container.realm == nil,
              Container.primaryKey() == keyPath else { return }
        container.setValue(objectKeyValue, forKey: keyPath)
    }
}


public extension UniquelyMappable where Container: Object & SharedDatabaseContainer {
    func update(_ container: Container, updates: [String: Any]) {
        container.typeName = Self.typeName
        updateProperties(for: container, updates: updates)
        updateRelationships(for: container)
        updateId(for: container)
    }

    internal func updateId(for container: Container) {
        guard let keyPath = Container.idKey._kvcKeyPathString,
              container.realm == nil,
              Container.primaryKey() == keyPath else { return }
        container.setValue(objectKeyValue, forKey: keyPath)
    }
}


public extension DatabaseMappable where Container: Object {
    func update(_ container: Container, updates: [String: Any]) {
        updateProperties(for: container, updates: updates)
        updateRelationships(for: container)
        updateId(for: container)
    }

    internal func updateId(for container: Container) {
        guard let keyPath = Container.idKey._kvcKeyPathString,
              Container.ID.self == String.self,
              container.realm == nil,
              Container.primaryKey() == keyPath else { return }
        container.setValue(UUID().uuidString, forKey: keyPath)
    }

    internal func updateProperties(for container: Container, updates: [String: Any]) {
        container.encodedValue = updates
    }

    internal func updateRelationships(for container: Container) {
        let relations = Set(container.objectSchema.properties.filter { $0.objectClassName != nil && !$0.isArray }.map { $0.name })
        guard !relations.isEmpty else { return }
        let reflection = Dictionary(uniqueKeysWithValues: Mirror(reflecting: self).children.compactMap {
            (key, value) -> (String, Any)? in
            guard let string = key else { return nil }
            return (string, unwrapUsingProtocol(value))
        })
        relations.forEach {
            guard let value = reflection[$0] as? AnyDatabaseMappable else {
                container[$0] = nil
                return
            }
            if let oldObject = try? value.existingContainer(with: container.realm) {
                value.update(oldObject)
                container[$0] = oldObject
            } else {
                container[$0] = try? value.container(with: container.realm)
            }
        }
    }
}


public extension DatabaseContainer where Self: Object {
    var propertiesValue: [String: Any] {
        let properties = objectSchema.properties
        let encoded: [String: Any] = Dictionary(uniqueKeysWithValues: properties
            .filter { $0.objectClassName == nil }
            .compactMap {
                guard let value = self[$0.name] else {
                    return nil
                }
                return ($0.name, value)
            })
        return encoded
    }
    var encodedValue: [String: Any] {
        get {
            let properties = objectSchema.properties
            var encoded: [String: Any] = Dictionary(uniqueKeysWithValues: properties
                .filter { $0.objectClassName == nil }
                .compactMap {
                    guard let value = self[$0.name] else {
                        return nil
                    }
                    if $0.type == .data, let data = value as? Data {
                        if let archived: [String: Any] = Dictionary(archive: data) {
                            return ($0.name, archived)
                        } else if let archived: [Any] = Array(archive: data) {
                            return ($0.name, archived)
                        }
                    }
                    return ($0.name, value)
                })
            properties.filter { $0.objectClassName != nil && !$0.isArray && $0.type != .linkingObjects }.forEach {
                if let object = self[$0.name] as? AnyDatabaseContainer {
                    encoded[$0.name] = object.encodedValue
                }
            }
            return encoded
        }
        set {
            let keyPath = Container.idKey._kvcKeyPathString
            let properties = Dictionary(uniqueKeysWithValues: objectSchema.properties.filter { $0.objectClassName == nil }.map { ($0.name, $0) })
            newValue.forEach {
                guard $0 != keyPath, let property = properties[$0] else { return }
                if property.type == .data {
                    // Processing codable properties
                    if let dictValue = $1 as? [String: Any] {
                        self[$0] = dictValue.archived
                    } else if let arrayValue = $1 as? [Any] {
                        self[$0] = arrayValue.archived
                    } else {
                        self[$0] = $1
                    }
                } else if let codable = $1 as? DictionaryCodable {
                    self[$0] = codable.encodedValue
                } else {
                    self[$0] = $1
                }
            }

            properties.filter { newValue[$0.key] == nil && $0.key != keyPath }.forEach { self[$0.key] = nil }
        }
    }
}
