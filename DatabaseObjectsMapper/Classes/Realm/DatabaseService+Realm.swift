//
// Created by Mikhail Mulyar on 07/01/2018.
// Copyright (c) 2018 Mikhail Mulyar. All rights reserved.
//

import RealmSwift
import Realm


public extension DatabaseMappable where Container: AnyRealmObject {
    func container(with userInfo: Any?) throws -> Container {
        try realmObject(with: userInfo)
    }

    func realmObject(with userInfo: Any?) throws -> Container {
        let object = Container()
        self.update(object)
        return object
    }
}


public extension DatabaseMappable where Container: AnyRealmObject & SharedDatabaseContainer {
    func container(with userInfo: Any?) throws -> Container {
        try realmObject(with: userInfo)
    }

    func containerSkippingRelation(with userInfo: Any?) throws -> Container {
        let object = Container()
        updateSkippingRelations(object, updates: encodedValue)
        return object
    }

    func updateSkippingRelations(_ container: Container, updates: [String: Any?]) {
        container.typeName = Self.typeName
        updateProperties(for: container, updates: updates)
        updateId(for: container)
    }

    func update(_ container: Container, updates: [String: Any?]) {
        container.typeName = Self.typeName
        updateProperties(for: container, updates: updates)
        updateRelationships(for: container)
        updateId(for: container)
    }

    static func internalPredicate() -> NSPredicate? {
        NSPredicate(format: "typeName == %@", argumentArray: [Self.typeName])
    }
}


public extension UniquelyMappable where Container: AnyRealmObject {
    func existingContainer(with userInfo: Any?) throws -> AnyDatabaseContainer? where Container: Object {
        guard let realm = (userInfo as? Realm) else { return nil }
        return realm.object(ofType: Container.self, forPrimaryKey: self.objectKeyValue)
    }

    func containerSkippingRelation(with userInfo: Any?) throws -> Container {
        let object = Container()
        updateSkippingRelations(object, updates: encodedValue)
        return object
    }

    func updateSkippingRelations(_ container: Container, updates: [String: Any?]) {
        updateProperties(for: container, updates: updates)
        updateId(for: container)
    }

    func update(_ container: Container, updates: [String: Any?]) {
        updateProperties(for: container, updates: updates)
        updateRelationships(for: container)
        updateId(for: container)
    }

    internal func updateId(for container: Container) {
        guard let keyPath = container.objectSchema.primaryKeyProperty?.name,
              container.realm == nil else { return }
        container.setValue(objectKeyValue, forKey: keyPath)
    }
}


public extension UniquelyMappable where Container: AnyRealmObject & SharedDatabaseContainer {
    func update(_ container: Container, updates: [String: Any?]) {
        container.typeName = Self.typeName
        updateProperties(for: container, updates: updates)
        updateRelationships(for: container)
        updateId(for: container)
    }

    internal func updateId(for container: Container) {
        guard let keyPath = container.objectSchema.primaryKeyProperty?.name,
              container.realm == nil else { return }
        container.setValue(objectKeyValue, forKey: keyPath)
    }
}


public extension DatabaseMappable where Container: AnyRealmObject {
    func update(_ container: Container, updates: [String: Any?]) {
        updateProperties(for: container, updates: updates)
        updateRelationships(for: container)
        updateId(for: container)
    }

    internal func updateId(for container: Container) {
        // update id required only for UniquelyMappable
    }

    internal func updateProperties(for container: Container, updates: [String: Any?]) {
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


typealias ObjCHashable = _ObjcBridgeable & Hashable


public protocol AnyRealmObject: NSObject {
    init()
    var realm: Realm? { get }
    var objectSchema: ObjectSchema { get }
    subscript(key: String) -> Any? { get set }
}


extension Object: AnyRealmObject {}


extension EmbeddedObject: AnyRealmObject {}


public extension DatabaseContainer where Self: AnyRealmObject {
    var propertiesValue: [String: Any?] {
        let properties = objectSchema.properties
        let encoded: [String: Any?] = Dictionary(uniqueKeysWithValues: properties
                .filter { $0.objectClassName == nil }
                .compactMap {
                    guard let value = self[$0.name] else {
                        return nil
                    }
                    return ($0.name, value)
                })
        return encoded
    }
    var encodedValue: [String: Any?] {
        get {
            let properties = objectSchema.properties
            var encoded: [String: Any?] = Dictionary(uniqueKeysWithValues: properties
                    .filter { $0.objectClassName == nil }
                    .compactMap {
                        guard let value = self[$0.name] else {
                            return nil
                        }
                        if $0.isArray,
                           let array = self[$0.name] as? RLMSwiftCollectionBase,
                           let arrayValue = array._rlmCollection.value(forKey: "self") {
                            return ($0.name, arrayValue)
                        }
                        if $0.isSet,
                           let set = self[$0.name] as? RLMSwiftCollectionBase,
                           let setValue = set._rlmCollection.value(forKey: "self") as? NSSet {
                            return ($0.name, setValue.allObjects)
                        }
                        if $0.isMap,
                           let set = self[$0.name] as? RLMSwiftCollectionBase,
                           let dictValue = set._rlmCollection as? RLMDictionary<NSString, AnyObject> {
                            return ($0.name, Dictionary(uniqueKeysWithValues: zip(dictValue.allKeys, dictValue.allValues)))
                        }
                        if $0.type == .data, let data = value as? Data {
                            if let archived: [String: Any?] = Dictionary(archive: data) {
                                return ($0.name, archived)
                            } else if let archived: [Any?] = Array(archive: data) {
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
            let keyPath = objectSchema.primaryKeyProperty?.name
            let properties = Dictionary(uniqueKeysWithValues: objectSchema.properties.filter { $0.objectClassName == nil }.map { ($0.name, $0) })
            newValue.forEach {
                guard $0 != keyPath, let property = properties[$0] else { return }
                if property.type == .data {
                    // Processing codable properties
                    if let dictValue = $1 as? [String: Any?] {
                        self[$0] = dictValue.archived
                    } else if let arrayValue = $1 as? [Any?] {
                        self[$0] = arrayValue.archived
                    } else {
                        self[$0] = $1
                    }
                } else if property.isArray,
                          property.objectClassName == nil,
                          let rlmArray = self[$0] as? RLMArray<NSObject>,
                          let array = $1 as? NSArray {
                    rlmArray.removeAllObjects()
                    rlmArray.addObjects(array)
                } else if property.isSet,
                          let rlmSet = self[$0] as? RLMSet<NSObject>,
                          let array = $1 as? Array<NSObject> {
                    rlmSet.removeAllObjects()
                    rlmSet.addObjects(array as NSArray)
                } else if property.isMap,
                          let rlmDict = self[$0] as? RLMDictionary<NSString, NSObject>,
                          let dict = $1 as? NSDictionary {
                    rlmDict.removeAllObjects()
                    rlmDict.setDictionary(dict)
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
