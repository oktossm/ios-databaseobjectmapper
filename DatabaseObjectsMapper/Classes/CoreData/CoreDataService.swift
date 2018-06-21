//
// Created by Mikhail Mulyar on 03/01/2018.
// Copyright (c) 2018 Mikhail Mulyar. All rights reserved.
//

import CoreData


public typealias CoreDataObject = NSManagedObject


public class CoreDataService {

    private var storage: CoreDataStorage

    private lazy var writeContext: NSManagedObjectContext = {
        return self.storage.newSavingContext
    }()
    private var readContext: NSManagedObjectContext {
        return self.storage.rootContext
    }

    public init(storage: CoreDataStorage = CoreDataStorage()) {
        self.storage = storage
    }

    deinit {

    }
}


extension CoreDataService {
    public func deleteAll() {
        try? self.storage.destroyStore()
        self.storage = CoreDataStorage()
    }

    /// Uniqueness Constraints should be set up in Entity model
    public func store<T: DatabaseMappable>(object: T, update: Bool = true) where T.DatabaseType: CoreDataObject {
        self.store(objects: [object], update: update)
    }

    /// Uniqueness Constraints should be set up in Entity model
    public func store<T: DatabaseMappable>(objects: [T], update: Bool = true) where T.DatabaseType: CoreDataObject {
        self.writeContext.perform {
            [weak self] in
            guard let s = self else { return }
            guard objects.isEmpty == false else { return }
            let oldObjects: [PrimaryKeyContainer: T.DatabaseType] = s.writeContext.findAll(withPrimaryKeys: objects.map { $0.primaryKeyValue })
            objects.forEach {
                item in
                let hasOldObject = oldObjects.keys.contains(item.primaryKeyValue)
                if !hasOldObject, let object = try? item.createObject(userInfo: s.writeContext) {
                    do {
                        try object.validateForInsert()
                    } catch let error as NSError {
                        print(error)
                    }
                } else if update, let object = oldObjects[item.primaryKeyValue] {
                    item.update(object)
                }
            }
            s.storage.saveContexts(contextWithObject: s.writeContext)
        }
    }

    public func update<T: DatabaseMappable>(object: T) where T.DatabaseType: CoreDataObject {
        self.update(objects: [object])
    }

    public func update<T: DatabaseMappable>(objects: [T]) where T.DatabaseType: CoreDataObject {
        self.writeContext.perform {
            [weak self] in
            guard let s = self else { return }
            let managed: [PrimaryKeyContainer: T.DatabaseType] = s.writeContext.findAll(withPrimaryKeys: objects.map { $0.primaryKeyValue })
            objects.forEach {
                guard let m = managed[$0.primaryKeyValue] else { return }
                $0.update(m)
            }
            s.storage.saveContexts(contextWithObject: s.writeContext)
        }
    }

    public func update<T: DatabaseMappable>(objectOf type: T.Type,
                                            withPrimaryKey key: PrimaryKeyContainer,
                                            updates: T.DatabaseUpdates) where T.DatabaseType: CoreDataObject {
        self.writeContext.perform {
            [weak self] in
            guard let s = self,
                  let managed: T.DatabaseType = s.writeContext.findFirst(withPrimaryKey: T.primaryKeyMapped(for: key)) else { return }
            guard var model = try? T.createMappable(from: managed) else { return }
            model = model.updated(updates)
            model.update(managed)
            s.storage.saveContexts(contextWithObject: s.writeContext)
        }
    }

    public func update<T: DatabaseMappable>(objectOf type: T.Type,
                                            withPrimaryKey key: PrimaryKeyContainer,
                                            relationships: [DatabaseRelationshipUpdate]) where T.DatabaseType: CoreDataObject {
        self.writeContext.perform {
            [weak self] in
            guard let s = self, let managed: T.DatabaseType = s.writeContext.findFirst(withPrimaryKey: T.primaryKeyMapped(for: key)) else { return }
            T.update(managed, with: relationships, in: s.writeContext)
            s.storage.saveContexts(contextWithObject: s.writeContext)
        }
    }

    public func update<T: DatabaseMappable>(objectOf type: T.Type,
                                            withPrimaryKey key: PrimaryKeyContainer,
                                            updates: T.DatabaseUpdates,
                                            relationships: [DatabaseRelationshipUpdate]) where T.DatabaseType: CoreDataObject {
        self.writeContext.perform {
            [weak self] in
            guard let s = self,
                  let managed: T.DatabaseType = s.writeContext.findFirst(withPrimaryKey: T.primaryKeyMapped(for: key)) else { return }

            guard var model = try? T.createMappable(from: managed) else { return }
            model = model.updated(updates)
            model.update(managed)

            T.update(managed, with: relationships, in: s.writeContext)

            s.storage.saveContexts(contextWithObject: s.writeContext)
        }
    }

    public func delete<T: DatabaseMappable>(object: T) where T.DatabaseType: CoreDataObject {
        self.delete(objects: [object])
    }

    public func delete<T: DatabaseMappable>(objects: [T]) where T.DatabaseType: CoreDataObject {
        self.writeContext.perform {
            [weak self] in
            guard let s = self else { return }
            let managed: [PrimaryKeyContainer: T.DatabaseType] = s.writeContext.findAll(withPrimaryKeys: objects.map { $0.primaryKeyValue })
            for m in managed.values {
                s.writeContext.delete(m)
            }
            s.storage.saveContexts(contextWithObject: s.writeContext)
        }
    }

    public func deleteAll<T: DatabaseMappable>(objectsOf type: T.Type) where T.DatabaseType: CoreDataObject {
        self.writeContext.perform {
            [weak self] in
            guard let s = self else { return }
            try? T.DatabaseType.delete(in: s.writeContext) {
                request in
                request.predicate = T.internalPredicate()
            }
            s.storage.saveContexts(contextWithObject: s.writeContext)
        }
    }

    public func fetch<T: DatabaseMappable>(objectsOf type: T.Type,
                                           with filter: DatabaseFilterType = .unfiltered,
                                           with sort: DatabaseSortType = .unsorted,
                                           callback: @escaping (Array<T>) -> Void) where T.DatabaseType: CoreDataObject {
        self.readContext.perform {
            [weak self] in
            guard let s = self else { return }
            let predicate: NSPredicate?
            if let p = filter.predicate, let t = T.internalPredicate() {
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p, t])
            } else {
                predicate = T.internalPredicate() ?? filter.predicate
            }
            let objects: [T.DatabaseType] = s.readContext.findAll(with: predicate, sortDescriptors: sort.sortDescriptors)

            callback(objects.compactMap { try? T.createMappable(from: $0) })
        }
    }

    public func syncFetch<T: DatabaseMappable>(objectsOf type: T.Type,
                                               with filter: DatabaseFilterType = .unfiltered,
                                               with sort: DatabaseSortType = .unsorted) -> Array<T> where T.DatabaseType: CoreDataObject {
        var result = [T]()

        self.readContext.performAndWait {
            [weak self] in
            guard let s = self else { return }
            let predicate: NSPredicate?
            if let p = filter.predicate, let t = T.internalPredicate() {
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p, t])
            } else {
                predicate = T.internalPredicate() ?? filter.predicate
            }
            let objects: [T.DatabaseType] = s.readContext.findAll(with: predicate, sortDescriptors: sort.sortDescriptors)

            result = objects.compactMap { try? T.createMappable(from: $0) }
        }

        return result
    }

    public func fetch<T: DatabaseMappable>(objectsOf type: T.Type,
                                           with filter: DatabaseFilterType = .unfiltered,
                                           with sort: DatabaseSortType = .unsorted,
                                           callback: @escaping (Array<T>) -> Void,
                                           updates: @escaping (DatabaseObserveUpdate<T>) -> Void) -> DatabaseUpdatesToken where T.DatabaseType: CoreDataObject {
        let token = DatabaseUpdatesToken {}

        self.readContext.perform {
            [weak self] in
            guard let s = self else { return }

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

            let observer = FetchRequestObserver<T.DatabaseType>(fetchRequest: request, context: s.readContext)
            let objects: [T.DatabaseType]? = observer.fetchedResultsController.fetchedObjects

            callback(objects?.compactMap { try? T.createMappable(from: $0) } ?? [T]())

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

    public func fetch<T: DatabaseMappable>(objectOf type: T.Type,
                                           withPrimaryKey key: PrimaryKeyContainer,
                                           callback: @escaping (T?) -> Void) where T.DatabaseType: CoreDataObject {
        self.readContext.perform {
            [weak self] in
            guard let s = self else { return }
            let object: T.DatabaseType? = s.readContext.findFirst(withPrimaryKey: T.primaryKeyMapped(for: key))

            callback(object.flatMap { try? T.createMappable(from: $0) })
        }
    }

    public func syncFetch<T: DatabaseMappable>(objectOf type: T.Type,
                                               withPrimaryKey key: PrimaryKeyContainer) -> T? where T.DatabaseType: CoreDataObject {

        var result: T? = nil

        self.readContext.performAndWait {
            [weak self] in
            guard let s = self else { return }
            let object: T.DatabaseType? = s.readContext.findFirst(withPrimaryKey: T.primaryKeyMapped(for: key))

            result = object.flatMap { try? T.createMappable(from: $0) }
        }

        return result
    }

    public func fetch<T: DatabaseMappable>(objectOf type: T.Type,
                                           withPrimaryKey key: PrimaryKeyContainer,
                                           callback: @escaping (T?) -> Void,
                                           updates: @escaping (DatabaseObjectUpdate<T>) -> Void) -> DatabaseUpdatesToken where T.DatabaseType: CoreDataObject {
        let token = DatabaseUpdatesToken {}

        self.readContext.perform {
            [weak self] in
            guard let s = self else { return }

            if token.isInvalidated { return }

            let object: T.DatabaseType? = s.readContext.findFirst(withPrimaryKey: T.primaryKeyMapped(for: key))

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