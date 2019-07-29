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
            guard let value = reflection[$0] as? AnyDatabaseMappable else { return }
            if let oldObject = container[$0] as? AnyDatabaseContainer {
                value.update(oldObject)
            } else {
                container[$0] = try? value.container(with: nil)
            }
        }
    }
}


public extension DatabaseContainer where Self: Object {
    var encodedValue: [String: Any] {
        get {
            let properties = objectSchema.properties
            var encoded: [String: Any] = Dictionary(uniqueKeysWithValues: properties.filter { $0.objectClassName == nil }
                                                                                    .compactMap {
                                                                                        if let value = self[$0.name] {
                                                                                            return ($0.name, value)
                                                                                        } else {
                                                                                            return nil
                                                                                        }
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
            let properties = Set(objectSchema.properties.filter { $0.objectClassName == nil }.map { $0.name })

            newValue.forEach {
                if $0 != keyPath && properties.contains($0) {
                    self[$0] = $1
                }
            }

            properties.filter { newValue[$0] == nil && $0 != keyPath }.forEach { self[$0] = nil }
        }
    }
}
