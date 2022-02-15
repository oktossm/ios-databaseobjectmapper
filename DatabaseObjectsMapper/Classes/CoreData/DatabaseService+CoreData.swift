//
// Created by Mikhail Mulyar on 07/01/2018.
// Copyright (c) 2018 Mikhail Mulyar. All rights reserved.
//

import CoreData


public extension DatabaseMappable where Container: NSManagedObject {
    func container(with userInfo: Any?) throws -> Container {
        try managedObject(with: userInfo)
    }

    func managedObject(with userInfo: Any?) throws -> Container {
        guard let context = userInfo as? NSManagedObjectContext,
              let entity = NSEntityDescription.entity(forEntityName: Container.entityName, in: context) else {
            fatalError("Failed to create object!")
        }
        let object = Container(entity: entity, insertInto: context)
        self.update(object)
        return object
    }
}


public extension DatabaseMappable where Container: NSManagedObject & SharedDatabaseContainer {
    func container(with userInfo: Any?) throws -> Container {
        try managedObject(with: userInfo)
    }

    func update(_ container: Container, updates: [String: Any?]) {
        container.typeName = Self.typeName
        defaultUpdate(container, updates: updates)
        updateId(for: container)
    }

    static func internalPredicate() -> NSPredicate? {
        NSPredicate(format: "typeName == %@", argumentArray: [Self.typeName])
    }
}


public extension UniquelyMappable where Container: NSManagedObject {
    func existingContainer(with userInfo: Any?) throws -> AnyDatabaseContainer? {
        guard let context = userInfo as? NSManagedObjectContext else { return nil }
        let container: Container? = context.findFirst(with: objectKeyValue)
        return container
    }

    func update(_ container: Container, updates: [String: Any?]) {
        defaultUpdate(container, updates: updates)
        updateId(for: container)
    }

    internal func updateId(for container: Container) {
        guard let keyPath = Container.idKey._kvcKeyPathString, container.entity.attributesByName[keyPath] != nil else { return }
        container.setValue(objectKeyValue, forKey: keyPath)
    }
}


public extension UniquelyMappable where Container: NSManagedObject & SharedDatabaseContainer {
    func update(_ container: Container, updates: [String: Any?]) {
        container.typeName = Self.typeName
        defaultUpdate(container, updates: updates)
        updateId(for: container)
    }

    internal func updateId(for container: Container) {
        guard let keyPath = Container.idKey._kvcKeyPathString, container.entity.attributesByName[keyPath] != nil else { return }
        container.setValue(objectKeyValue, forKey: keyPath)
    }
}


public extension DatabaseMappable where Container: NSManagedObject {
    func update(_ container: Container, updates: [String: Any?]) {
        defaultUpdate(container, updates: updates)
        updateId(for: container)
    }

    internal func defaultUpdate(_ container: Container, updates: [String: Any?]) {
        updateProperties(for: container, updates: updates)
        if let context = container.managedObjectContext {
            updateRelationships(for: container, updates: updates, in: context)
        }
    }

    internal func updateId(for container: Container) {
//        guard let keyPath = Container.idKey._kvcKeyPathString,
//              Container.ID.self == String.self,
//              container.entity.attributesByName[keyPath] != nil else { return }
//        container.setValue(UUID().uuidString, forKey: keyPath)
    }

    internal func updateProperties(for container: Container, updates: [String: Any?]) {
        container.encodedValue = updates
    }

    internal func updateRelationships(for container: Container, updates: [String: Any?], in writeContext: NSManagedObjectContext) {
        let relations = Set(container.entity.relationshipsByName.values.filter { !$0.isToMany }.map { $0.name })
        guard !relations.isEmpty else { return }
        let reflection = Dictionary(uniqueKeysWithValues: Mirror(reflecting: self).children.compactMap {
            (key, value) -> (String, Any)? in
            guard let string = key else { return nil }
            return (string, unwrapUsingProtocol(value))
        })
        relations.forEach {
            guard let value = reflection[$0] as? AnyDatabaseMappable else { return }
            if let oldObject = try? value.existingContainer(with: writeContext) {
                value.update(oldObject)
                container.setValue(oldObject, forKey: $0)
            } else {
                container.setValue(try? value.container(with: nil), forKey: $0)
            }
        }
    }
}


public extension DatabaseContainer where Self: NSManagedObject {
    var encodedValue: [String: Any?] {
        get {
            var encoded: [String: Any?] = entity.attributesByName.compactMapValues { value(forKey: $0.name) }
            entity.relationshipsByName.values.filter { !$0.isToMany }.forEach {
                if let object = value(forKey: $0.name) as? AnyDatabaseContainer {
                    encoded[$0.name] = object.encodedValue
                }
            }
            return encoded
        }
        set {
//            let keyPath = Container.idKey._kvcKeyPathString
            let properties = Set(entity.attributesByName.map { $0.key })

            newValue.forEach {
//                if $0 != keyPath && properties.contains($0) {
                if properties.contains($0) {
                    setValue($1, forKey: $0)
                }
            }

            properties.filter { newValue[$0] == nil }.forEach { setValue(nil, forKey: $0) }
//            properties.filter { newValue[$0] == nil && $0 != keyPath }.forEach { setValue(nil, forKey: $0) }
        }
    }
}
