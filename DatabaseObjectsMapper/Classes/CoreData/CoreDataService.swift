//
// Created by Mikhail Mulyar on 03/01/2018.
// Copyright (c) 2018 Mikhail Mulyar. All rights reserved.
//

import CoreData


public class CoreDataService {

    private var storage: CoreDataStorage

    private lazy var writeContext: NSManagedObjectContext = {
        return self.storage.newSavingContext
    }()
    private var readContext: NSManagedObjectContext {
        return self.storage.rootContext
    }

    init() {
        self.storage = CoreDataStorage()
    }

    deinit {

    }

    func deleteAll() {
        try? self.storage.destroyStore()
        self.storage = CoreDataStorage()
    }

    /// Uniqueness Constraints should be set up in Entity model
    func store<T: DatabaseMappable>(object: T, update: Bool) where T.DatabaseType: NSManagedObject {
        self.store(objects: [object], update: update)
    }

    /// Uniqueness Constraints should be set up in Entity model
    func store<T: DatabaseMappable>(objects: [T], update: Bool) where T.DatabaseType: NSManagedObject {
        self.writeContext.perform {
            guard objects.isEmpty == false else { return }
            let oldObjects: [PrimaryKeyValue: T.DatabaseType] = self.writeContext.findAll(withPrimaryKeys: objects.map { $0.primaryKey })
            objects.forEach {
                item in
                let hasOldObject = oldObjects.keys.contains(item.primaryKey)
                if update || !hasOldObject, let object = try? item.createObject(userInfo: self.writeContext) {
                    do {
                        try object.validateForInsert()
                    } catch let error as NSError {
                        print(error)
                    }
                }
            }
            self.storage.saveContexts(contextWithObject: self.writeContext)
        }
    }

    func update<T: DatabaseMappable>(object: T) where T.DatabaseType: NSManagedObject {
        self.update(objects: [object])
    }

    func update<T: DatabaseMappable>(objects: [T]) where T.DatabaseType: NSManagedObject {
        self.writeContext.perform {
            let managed: [PrimaryKeyValue: T.DatabaseType] = self.writeContext.findAll(withPrimaryKeys: objects.map { $0.primaryKey })
            objects.forEach {
                guard let m = managed[$0.primaryKey] else { return }
                $0.update(m)
            }
            self.storage.saveContexts(contextWithObject: self.writeContext)
        }
    }

    func update<T: DatabaseMappable>(objectOf type: T.Type,
                                     withPrimaryKey key: PrimaryKeyValue,
                                     updates: T.DatabaseUpdates) where T.DatabaseType: NSManagedObject {
        self.writeContext.perform {
            let managed: T.DatabaseType? = self.writeContext.findFirst(withPrimaryKey: key)
            updates.dictionaryRepresentation().forEach {
                key, value in
                managed?.setValue(value, forKey: key)
            }
            self.storage.saveContexts(contextWithObject: self.writeContext)
        }
    }

    func update<T: DatabaseMappable>(objectOf type: T.Type,
                                     withPrimaryKey key: PrimaryKeyValue,
                                     relationships: [DatabaseRelationshipUpdate]) where T.DatabaseType: NSManagedObject {
        self.writeContext.perform {
            guard let managed: T.DatabaseType = self.writeContext.findFirst(withPrimaryKey: key) else { return }

            self.update(managed, with: relationships)

            self.storage.saveContexts(contextWithObject: self.writeContext)
        }
    }

    func update<T: DatabaseMappable>(objectOf type: T.Type,
                                     withPrimaryKey key: PrimaryKeyValue,
                                     updates: T.DatabaseUpdates,
                                     relationships: [DatabaseRelationshipUpdate]) where T.DatabaseType: NSManagedObject {
        self.writeContext.perform {
            guard let managed: T.DatabaseType = self.writeContext.findFirst(withPrimaryKey: key) else { return }
            updates.dictionaryRepresentation().forEach { managed.setValue($0.value, forKey: $0.key) }
            self.update(managed, with: relationships)

            self.storage.saveContexts(contextWithObject: self.writeContext)
        }
    }

    private func update(_ managed: NSManagedObject, with relationships: [DatabaseRelationshipUpdate]) {
        for relationship in relationships {
            switch relationship {
            case .toOne(let key, let object, let create):
                let relationObject: NSManagedObject
                if create {
                    guard let rObject = (try? object?.createRelationObject(userInfo: self.writeContext)) as? NSManagedObject else {
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
                    guard let values = try? self.writeContext.fetch(request), let first = values.first as? NSManagedObject else { continue }
                    relationObject = first
                }

                managed.setValue(relationObject, forKey: key)

                if let internalRelationships = object?.allRelationships(), internalRelationships.isEmpty == false {
                    self.update(relationObject, with: internalRelationships)
                }
            case .toManySet(let key, let objects, let create):
                guard let objects = objects else {
                    managed.setValue(nil, forKey: key)
                    continue
                }
                self.addRelationships(objects, to: managed, for: key, initialSet: NSSet(), create: create)
            case .toManyAdd(let key, let objects, let create):
                guard let set = managed.value(forKey: key) as? NSSet else { continue }
                self.addRelationships(objects, to: managed, for: key, initialSet: set, create: create)
            case .toManyRemove(let key, let objects):
                guard let set = (managed.value(forKey: key) as? NSSet)?.mutableCopy() as? NSMutableSet else { continue }
                guard let primaryKeyName = objects.first?.primaryKey.key, let typeName = objects.first?.databaseTypeName() else { continue }
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: typeName)
                request.predicate = NSPredicate(format: "%K IN %@", argumentArray: [primaryKeyName, objects.map { $0.primaryKeyValue() }])
                guard let values = try? self.writeContext.fetch(request) else { continue }
                values.forEach { set.remove($0) }
                managed.setValue(set, forKey: key)
            }
        }
    }

    private func addRelationships(_ relationships: [DatabaseRelationshipMappable],
                                  to managed: NSManagedObject,
                                  for key: String,
                                  initialSet: NSSet,
                                  create: Bool) {
        if create {
            let values = relationships.flatMap {
                object -> (NSManagedObject, [DatabaseRelationshipUpdate])? in
                let relation = (try? object.createRelationObject(userInfo: self.writeContext)) as? NSManagedObject
                return relation.flatMap { ($0, object.allRelationships()) }
            }
            for value in values {
                self.update(value.0, with: value.1)
            }
            managed.setValue(initialSet.addingObjects(from: values), forKey: key)
        } else {
            guard let primaryKey = relationships.first?.primaryKey,
                  let primaryKeyName = relationships.first?.primaryKey.key,
                  let typeName = relationships.first?.databaseTypeName() else { return }
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: typeName)
            request.predicate = NSPredicate(format: "%K IN %@", argumentArray: [primaryKeyName, relationships.map { $0.primaryKeyValue() }])
            guard let values = try? self.writeContext.fetch(request) else { return }

            let relations = relationships.reduce(into: [PrimaryKeyValue: [DatabaseRelationshipUpdate]]()) {
                result, mappable in
                result[mappable.primaryKey] = mappable.allRelationships()
            }

            switch primaryKey {
            case .int:
                for value in values {
                    guard let relation = value as? NSManagedObject,
                          let keyValue = relation.value(forKey: primaryKey.key) as? Int,
                          let updates = relations[.int(value: keyValue, key: primaryKey.key)] else { return }
                    self.update(relation, with: updates)
                }
            case .string:
                for value in values {
                    guard let relation = value as? NSManagedObject,
                          let keyValue = relation.value(forKey: primaryKey.key) as? String,
                          let updates = relations[.string(value: keyValue, key: primaryKey.key)] else { return }
                    self.update(relation, with: updates)
                }
            default:
                break
            }

            managed.setValue(initialSet.addingObjects(from: values), forKey: key)
        }
    }

    func delete<T: DatabaseMappable>(object: T) where T.DatabaseType: NSManagedObject {
        self.delete(objects: [object])
    }

    func delete<T: DatabaseMappable>(objects: [T]) where T.DatabaseType: NSManagedObject {
        self.writeContext.perform {
            let managed: [PrimaryKeyValue: T.DatabaseType] = self.writeContext.findAll(withPrimaryKeys: objects.map { $0.primaryKey })
            for m in managed.values {
                self.writeContext.delete(m)
            }
            self.storage.saveContexts(contextWithObject: self.writeContext)
        }
    }

    func deleteAll<T: DatabaseMappable>(objectsOf type: T.Type) where T.DatabaseType: NSManagedObject {
        self.writeContext.perform {
            try? T.DatabaseType.delete(in: self.writeContext) {
                request in
                request.predicate = T.internalPredicate()
            }
            self.storage.saveContexts(contextWithObject: self.writeContext)
        }
    }

    func fetch<T: DatabaseMappable>(objectsOf type: T.Type,
                                    with filter: DatabaseFilterType,
                                    with sort: DatabaseSortType,
                                    callback: @escaping (Array<T>) -> Void) where T.DatabaseType: NSManagedObject {
        self.readContext.perform {
            let predicate: NSPredicate?
            if let p = filter.predicate, let t = T.internalPredicate() {
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p, t])
            } else {
                predicate = T.internalPredicate() ?? filter.predicate
            }
            let objects: [T.DatabaseType] = self.readContext.findAll(with: predicate, sortDescriptors: sort.sortDescriptors)

            callback(objects.flatMap { try? T.createMappable(from: $0) })
        }
    }

    func syncFetch<T: DatabaseMappable>(objectsOf type: T.Type,
                                        with filter: DatabaseFilterType = .unfiltered,
                                        with sort: DatabaseSortType = .unsorted) -> Array<T> where T.DatabaseType: NSManagedObject {
        var result = [T]()

        self.readContext.performAndWait {
            let predicate: NSPredicate?
            if let p = filter.predicate, let t = T.internalPredicate() {
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p, t])
            } else {
                predicate = T.internalPredicate() ?? filter.predicate
            }
            let objects: [T.DatabaseType] = self.readContext.findAll(with: predicate, sortDescriptors: sort.sortDescriptors)

            result = objects.flatMap { try? T.createMappable(from: $0) }
        }

        return result
    }

    func fetch<T: DatabaseMappable>(objectsOf type: T.Type,
                                    with filter: DatabaseFilterType,
                                    with sort: DatabaseSortType,
                                    callback: @escaping (Array<T>) -> Void,
                                    updates: @escaping (DatabaseObserveUpdate<T>) -> Void) -> DatabaseUpdatesToken where T.DatabaseType: NSManagedObject {
        let token = DatabaseUpdatesToken {}

        self.readContext.perform {

            if token.isInvalidated { return }

            let predicate: NSPredicate?
            if let p = filter.predicate, let t = T.internalPredicate() {
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p, t])
            } else {
                predicate = T.internalPredicate() ?? filter.predicate
            }
            let constraints = T.DatabaseType.entity.uniquenessConstraints
            let request = NSFetchRequest<T.DatabaseType>(entityName: T.DatabaseType.entityName)
            request.predicate = predicate
            request.sortDescriptors = sort.sortDescriptors ?? constraints.first?.first.flatMap {
                [NSSortDescriptor(key: $0 as? String, ascending: false)]
            }

            let observer = FetchRequestObserver<T.DatabaseType>(fetchRequest: request, context: self.readContext)
            let objects: [T.DatabaseType]? = observer.fetchedResultsController.fetchedObjects

            callback(objects?.flatMap { try? T.createMappable(from: $0) } ?? [T]())

            observer.observer = {
                (update: DatabaseObserveUpdate<T.DatabaseType>) in
                do {
                    updates(DatabaseObserveUpdate(values: try update.values.map { try T.createMappable(from: $0) },
                                                  deletions: update.deletions,
                                                  insertions: update.insertions,
                                                  modifications: update.modifications))
                } catch {

                }
            }

            token.invalidation = {
                observer.dispose()
            }
        }

        return token
    }

    func fetch<T: DatabaseMappable>(objectOf type: T.Type,
                                    withPrimaryKey key: PrimaryKeyValue,
                                    callback: @escaping (T?) -> Void) where T.DatabaseType: NSManagedObject {
        self.readContext.perform {
            let object: T.DatabaseType? = self.readContext.findFirst(withPrimaryKey: key)

            callback(object.flatMap { try? T.createMappable(from: $0) })
        }
    }

    func syncFetch<T: DatabaseMappable>(objectOf type: T.Type,
                                        withPrimaryKey key: PrimaryKeyValue) -> T? where T.DatabaseType: NSManagedObject {

        var result: T? = nil

        self.readContext.performAndWait {
            let object: T.DatabaseType? = self.readContext.findFirst(withPrimaryKey: key)

            result = object.flatMap { try? T.createMappable(from: $0) }
        }

        return result
    }

    func fetch<T: DatabaseMappable>(objectOf type: T.Type,
                                    withPrimaryKey key: PrimaryKeyValue,
                                    callback: @escaping (T?) -> Void,
                                    updates: @escaping (DatabaseObjectUpdate<T>) -> Void) -> DatabaseUpdatesToken where T.DatabaseType: NSManagedObject {
        let token = DatabaseUpdatesToken {}

        self.readContext.perform {

            if token.isInvalidated { return }

            let object: T.DatabaseType? = self.readContext.findFirst(withPrimaryKey: key)

            callback(object.flatMap { try? T.createMappable(from: $0) })

            guard let managed = object else { return }

            let observer = ManagedObjectObserver(object: managed) {
                change in

                switch change {
                case .delete:
                    DispatchQueue.main.async {
                        updates(.delete)
                    }
                case .update:
                    guard let mapped = try? T.createMappable(from: managed) else { return }
                    DispatchQueue.main.async {
                        updates(.update(object: mapped))
                    }
                }
            }

            token.invalidation = {
                observer?.dispose()
            }
        }

        return token
    }

}
