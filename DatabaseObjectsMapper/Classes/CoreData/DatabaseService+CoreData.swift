//
// Created by Mikhail Mulyar on 07/01/2018.
// Copyright (c) 2018 Mikhail Mulyar. All rights reserved.
//

import CoreData


public extension DatabaseMappable where DatabaseType: NSManagedObject {
    public func createObject(userInfo: Any?) throws -> DatabaseType {
        return try self.createManagedObject(userInfo: userInfo)
    }

    public func createManagedObject(userInfo: Any?) throws -> DatabaseType {
        guard let context = userInfo as? NSManagedObjectContext,
              let entity = NSEntityDescription.entity(forEntityName: DatabaseType.entityName, in: context) else {
            fatalError("Failed to create object!")
        }
        let object = DatabaseType(entity: entity, insertInto: context)
        self.update(object)
        return object
    }
}


public extension DatabaseMappable where DatabaseType: NSManagedObject & DatabaseContainerProtocol {
    public func createObject(userInfo: Any?) throws -> DatabaseType {
        return try self.createManagedObject(userInfo: userInfo)
    }

    public func update(_ object: DatabaseType, primaryKey: PrimaryKeyContainer, data: Data, updates: DatabaseUpdates) {
        object.update(for: Self.typeName, primaryKey: primaryKey, data: data)
    }

    public static func internalPredicate() -> NSPredicate? {
        return NSPredicate(format: "typeName == %@", argumentArray: [Self.typeName])
    }
}


public extension DatabaseMappable where DatabaseType: NSManagedObject {
    public func update(_ object: DatabaseType, primaryKey: PrimaryKeyContainer, data: Data, updates: DatabaseUpdates) {
        let updatedModel = self.updated(updates)

        guard let encoded = try? updatedModel.encoded() else { return }
        var anObject = object
        anObject.encoded = encoded

        Self.updateProperties(for: object, using: updatedModel, updates: updates)
        if let context = object.managedObjectContext {
            Self.updateRelationships(for: object, updates: updates, in: context)
        }
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
        properties[primaryKey.key] = primaryKey.value

        properties.forEach { key, value in object.setValue(value, forKey: key) }
    }

    internal static func updateRelationships(for object: DatabaseType, updates: DatabaseUpdates, in writeContext: NSManagedObjectContext) {
        var relationships = [DatabaseRelationshipUpdate]()

        for (key, value) in updates.dictionaryRepresentation() {
            if let relation = value as? DatabaseRelationshipMappable {
                relationships.append(.toOne(key: key, object: relation, createNew: true))
            } else if let relations = value as? [DatabaseRelationshipMappable] {
                relationships.append(.toManySet(key: key, objects: relations, createNew: true))
            }
        }

        if !relationships.isEmpty {
            self.update(object, with: relationships, in: writeContext)
        }
    }

    internal static func update(_ managed: NSManagedObject,
                                with relationships: [DatabaseRelationshipUpdate],
                                in writeContext: NSManagedObjectContext) {
        for relationship in relationships {
            switch relationship {
            case .toOne(let key, let object, let create):
                let relationObject: NSManagedObject
                if create {
                    guard let rObject = (try? object?.createRelationObject(userInfo: writeContext)) as? NSManagedObject else {
                        managed.setValue(nil, forKey: key)
                        continue
                    }
                    relationObject = rObject
                } else {
                    guard let typeName = object?.databaseTypeName(),
                          let primaryKey = object?.primaryKeyValue(),
                          let primaryKeyName = object?.primaryKey.key else {
                        managed.setValue(nil, forKey: key)
                        continue
                    }
                    let request = NSFetchRequest<NSFetchRequestResult>(entityName: typeName)
                    request.predicate = NSPredicate(format: "%K = %@", argumentArray: [primaryKeyName, primaryKey])
                    guard let values = try? writeContext.fetch(request), let first = values.first as? NSManagedObject else { continue }
                    relationObject = first
                }

                managed.setValue(relationObject, forKey: key)
            case .toManySet(let key, let objects, let create):
                guard let objects = objects else {
                    managed.setValue(nil, forKey: key)
                    continue
                }
                self.addRelationships(objects, to: managed, for: key, initialSet: NSSet(), create: create, in: writeContext)
            case .toManyAdd(let key, let objects, let create):
                guard let set = managed.value(forKey: key) as? NSSet else { continue }
                self.addRelationships(objects, to: managed, for: key, initialSet: set, create: create, in: writeContext)
            case .toManyRemove(let key, let objects):
                guard let set = (managed.value(forKey: key) as? NSSet)?.mutableCopy() as? NSMutableSet else { continue }
                guard let primaryKeyName = objects.first?.primaryKey.key, let typeName = objects.first?.databaseTypeName() else { continue }
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: typeName)
                request.predicate = NSPredicate(format: "%K IN %@", argumentArray: [primaryKeyName, objects.map { $0.primaryKeyValue() }])
                guard let values = try? writeContext.fetch(request) else { continue }
                values.forEach { set.remove($0) }
                managed.setValue(set, forKey: key)
            }
        }
    }

    internal static func addRelationships(_ relationships: [DatabaseRelationshipMappable],
                                          to managed: NSManagedObject,
                                          for key: String,
                                          initialSet: NSSet,
                                          create: Bool,
                                          in writeContext: NSManagedObjectContext) {
        if create {
            let values = relationships.compactMap {
                object -> NSManagedObject? in
                let relation = (try? object.createRelationObject(userInfo: writeContext)) as? NSManagedObject
                return relation
            }
            managed.setValue(initialSet.addingObjects(from: values), forKey: key)
        } else {
            guard let primaryKeyName = relationships.first?.primaryKey.key,
                  let typeName = relationships.first?.databaseTypeName() else { return }
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: typeName)
            request.predicate = NSPredicate(format: "%K IN %@", argumentArray: [primaryKeyName, relationships.map { $0.primaryKeyValue() }])
            guard let values = try? writeContext.fetch(request) else { return }

            managed.setValue(initialSet.addingObjects(from: values), forKey: key)
        }
    }

}