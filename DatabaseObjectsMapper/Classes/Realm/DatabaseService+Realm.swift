//
// Created by Mikhail Mulyar on 07/01/2018.
// Copyright (c) 2018 Mikhail Mulyar. All rights reserved.
//

import RealmSwift
import Realm


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

    public func update(_ object: DatabaseType, primaryKey: PrimaryKeyContainer, data: Data, updates: DatabaseUpdates) {
        object.update(for: Self.typeName, primaryKey: primaryKey, data: data)
    }

    public static func internalPredicate() -> NSPredicate? {
        return NSPredicate(format: "typeName == %@", argumentArray: [Self.typeName])
    }
}


public extension DatabaseMappable where DatabaseType: Object {
    public func update(_ object: DatabaseType, primaryKey: PrimaryKeyContainer, data: Data, updates: DatabaseUpdates) {
        let updatedModel = self.updated(updates)

        guard let encoded = try? updatedModel.encoded() else { return }
        var anObject = object
        anObject.encoded = encoded

        Self.updateProperties(for: object, using: updatedModel, updates: updates)
        Self.updateRelationships(for: object, updates: updates)
    }

    internal static func updateProperties(for object: DatabaseType, using model: Self, updates: DatabaseUpdates) {
        var properties = [String: Any]()

        for (key, value) in updates.dictionaryRepresentation() {
            if let _ = value as? DatabaseRelationshipMappable {
            } else if let _ = value as? [DatabaseRelationshipMappable] {
            } else {
                properties[key] = value
            }
        }

        let primaryKey = model.primaryKeyValue

        if object.realm == nil {
            properties[primaryKey.key] = primaryKey.value
        } else {
            properties.removeValue(forKey: primaryKey.key)
        }

        properties.forEach { key, value in object.setValue(value, forKey: key) }
    }

    internal static func updateRelationships(for object: DatabaseType, updates: DatabaseUpdates) {
        var relationships = [DatabaseRelationshipUpdate]()

        for (key, value) in updates.dictionaryRepresentation() {
            if let relation = value as? DatabaseRelationshipMappable {
                relationships.append(.toOne(key: key, object: relation, createNew: true))
            } else if let relations = value as? [DatabaseRelationshipMappable] {
                relationships.append(.toManySet(key: key, objects: relations, createNew: true))
            }
        }

        if !relationships.isEmpty {
            self.update(object, with: relationships)
        }
    }

    internal static func update(_ realmObject: Object, with relationships: [DatabaseRelationshipUpdate]) {
        let realm = try! Realm()

        for relationship in relationships {
            switch relationship {
            case .toOne(let key, let item, let create):
                let relationObject: Object
                if create {
                    guard let rObject = (try? item?.createRelationObject(userInfo: nil)) as? Object else {
                        realmObject.setValue(nil, forKey: key)
                        continue
                    }
                    relationObject = rObject
                } else {
                    guard let typeName = item?.databaseTypeName(),
                          let primaryKey = item?.primaryKeyValue(),
                          let rObject = realm.dynamicObject(ofType: typeName, forPrimaryKey: primaryKey) else {
                        realmObject.setValue(nil, forKey: key)
                        continue
                    }
                    relationObject = rObject
                }

                realmObject.setValue(relationObject, forKey: key)
            case .toManySet(let key, let objects, let create):
                guard let list = realmObject.value(forKey: key) as? RLMListBase else { continue }
                list._rlmArray.removeAllObjects()
                guard let objects = objects else { continue }
                self.addRelationships(objects, to: list, create: create)
            case .toManyAdd(let key, let objects, let create):
                guard let list = realmObject.value(forKey: key) as? RLMListBase else { continue }
                self.addRelationships(objects, to: list, create: create)
            case .toManyRemove(let key, let objects):
                guard let list = realmObject.value(forKey: key) as? RLMListBase else { continue }
                guard let primaryKeyName = objects.first?.primaryKey.key, let typeName = objects.first?.databaseTypeName() else { continue }
                let values = realm.dynamicObjects(typeName).filter("%K IN %@", primaryKeyName, objects.map { $0.primaryKeyValue() })
                for value in values {
                    let index = list._rlmArray.index(of: value)
                    if index != NSNotFound {
                        list._rlmArray.removeObject(at: index)
                    }
                }
            }
        }
    }

    internal static func addRelationships(_ relationships: [DatabaseRelationshipMappable], to list: RLMListBase, create: Bool) {
        let realm = try! Realm()
        if create {
            let values = relationships.compactMap {
                object -> Object? in
                let realmObject = (try? object.createRelationObject(userInfo: nil)) as? Object
                return realmObject
            }
            for value in values { list._rlmArray.add(value) }
        } else {
            guard let typeName = relationships.first?.databaseTypeName() else { return }
            let values = relationships.compactMap {
                object -> DynamicObject? in
                guard let v = object.primaryKeyValue() else { return nil }
                return realm.dynamicObject(ofType: typeName, forPrimaryKey: v)
            }
            for value in values { list._rlmArray.add(value) }
        }
    }

}


public extension DatabaseTypeProtocol where Self: Object {
    public static var primaryKeyPath: String? {
        return self.primaryKey()
    }
}