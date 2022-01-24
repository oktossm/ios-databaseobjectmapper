//
// Created by Mikhail Mulyar on 03/01/2018.
// Copyright (c) 2018 Mikhail Mulyar. All rights reserved.
//

import CoreData


public typealias CoreDataObject = NSManagedObject


open class CoreDataService {

    private var storage: CoreDataStorage

    private lazy var writeContext: NSManagedObjectContext = {
        self.storage.newSavingContext
    }()
    private var readContext: NSManagedObjectContext {
        storage.rootContext
    }

    public init(storage: CoreDataStorage = CoreDataStorage()) {
        self.storage = storage
    }

    deinit {
    }
}


extension CoreDataService {
    public func deleteAll() {
        try? storage.destroyStore()
        storage = CoreDataStorage()
    }

    public func simpleSave<T: DatabaseMappable>(model: T) where T.Container: CoreDataObject {
        self.simpleSave(models: [model])
    }

    public func simpleSave<T: DatabaseMappable>(models: [T]) where T.Container: CoreDataObject {
        writeContext.perform {
            [weak self] in
            guard let s = self else { return }
            models.forEach {
                item in
                if let object = try? item.container(with: s.writeContext) {
                    do {
                        try object.validateForInsert()
                    } catch let error as NSError {
                        print(error)
                    }
                }
            }
            s.storage.saveContexts(contextWithObject: s.writeContext)
        }
    }

    public func save<T: UniquelyMappable>(model: T, update: Bool = true) where T.Container: CoreDataObject {
        self.save(models: [model], update: update)
    }

    public func save<T: UniquelyMappable>(models: [T], update: Bool = true) where T.Container: CoreDataObject {
        writeContext.perform {
            [weak self] in
            guard let s = self else { return }
            guard models.isEmpty == false else { return }
            let oldObjects: [T.Container.ID: T.Container] = s.writeContext.findAll(with: models.map { $0.objectKeyValue })
            models.forEach {
                item in
                let hasOldObject = oldObjects.keys.contains(item.objectKeyValue)
                if !hasOldObject, let object = try? item.container(with: s.writeContext) {
                    do {
                        try object.validateForInsert()
                    } catch let error as NSError {
                        print(error)
                    }
                } else if update, let object = oldObjects[item.objectKeyValue] {
                    item.update(object)
                }
            }
            s.storage.saveContexts(contextWithObject: s.writeContext)
        }
    }

    public func update<T: UniquelyMappable>(model: T) where T.Container: CoreDataObject {
        self.update(models: [model])
    }

    public func update<T: UniquelyMappable>(models: [T]) where T.Container: CoreDataObject {
        writeContext.perform {
            [weak self] in
            guard let s = self else { return }
            let managed: [T.Container.ID: T.Container] = s.writeContext.findAll(with: models.map { $0.objectKeyValue })
            models.forEach {
                guard let m = managed[$0.objectKeyValue] else { return }
                $0.update(m)
            }
            s.storage.saveContexts(contextWithObject: s.writeContext)
        }
    }

    public func update<T: UniquelyMappable>(modelOf type: T.Type, with key: T.ID, updates: [String: Any?]) where T.Container: CoreDataObject {
        writeContext.perform {
            [weak self] in
            guard let s = self,
                  let managed: T.Container = s.writeContext.findFirst(with: T.idMapping(key)) else { return }
            guard let model = try? T.mappable(for: managed) else { return }
            let updates: [String: Any?] = updates.mapValues {
                if let mappable = $0 as? DictionaryCodable {
                    return mappable.encodedValue
                } else {
                    return $0
                }
            }
            var encoded = model.encodedValue.merging(updates.compactMapValues { $0 }) { return $1 }
            updates.filter { $0.value == nil }.forEach { encoded[$0.key] = nil }
            guard let new = T(encoded) else { return }
            new.update(managed)
            s.storage.saveContexts(contextWithObject: s.writeContext)
        }
    }


    public func update<T: UniquelyMappable & KeyPathConvertible>(modelOf type: T.Type,
                                                                 with key: T.ID,
                                                                 updates: [RootKeyPathUpdate<T>]) where T.Container: CoreDataObject {
        let updates = Dictionary(updates.map { $0.update }) { _, last in last }
        self.update(modelOf: type, with: key, updates: updates)
    }

    public func delete<T: UniquelyMappable>(model: T) where T.Container: CoreDataObject {
        self.delete(models: [model])
    }

    public func delete<T: UniquelyMappable>(models: [T]) where T.Container: CoreDataObject {
        self.writeContext.perform {
            [weak self] in
            guard let s = self else { return }
            let managed: [T.Container.ID: T.Container] = s.writeContext.findAll(with: models.map { $0.objectKeyValue })
            for m in managed.values {
                s.writeContext.delete(m)
            }
            s.storage.saveContexts(contextWithObject: s.writeContext)
        }
    }

    public func deleteAll<T: DatabaseMappable>(modelOf type: T.Type) where T.Container: CoreDataObject {
        writeContext.perform {
            [weak self] in
            guard let s = self else { return }
            try? T.Container.delete(in: s.writeContext) {
                request in
                request.predicate = T.internalPredicate()
            }
            s.storage.saveContexts(contextWithObject: s.writeContext)
        }
    }

    public func fetch<T: DatabaseMappable>(with filter: DatabaseFilterType = .unfiltered,
                                           sorted sort: DatabaseSortType = .unsorted,
                                           callback: @escaping (Array<T>) -> Void) where T.Container: CoreDataObject {
        readContext.perform {
            [weak self] in
            guard let s = self else { return }
            let predicate: NSPredicate?
            if let p = filter.predicate, let t = T.internalPredicate() {
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p, t])
            } else {
                predicate = T.internalPredicate() ?? filter.predicate
            }
            let objects: [T.Container] = s.readContext.findAll(with: predicate, sortDescriptors: sort.sortDescriptors)

            callback(objects.compactMap { try? T.mappable(for: $0) })
        }
    }

    public func syncFetch<T: DatabaseMappable>(with filter: DatabaseFilterType = .unfiltered,
                                               sorted sort: DatabaseSortType = .unsorted) -> Array<T> where T.Container: CoreDataObject {
        var result = [T]()

        readContext.performAndWait {
            [weak self] in
            guard let s = self else { return }
            let predicate: NSPredicate?
            if let p = filter.predicate, let t = T.internalPredicate() {
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p, t])
            } else {
                predicate = T.internalPredicate() ?? filter.predicate
            }
            let objects: [T.Container] = s.readContext.findAll(with: predicate, sortDescriptors: sort.sortDescriptors)

            result = objects.compactMap { try? T.mappable(for: $0) }
        }

        return result
    }

    public func fetch<T: DatabaseMappable>(with filter: DatabaseFilterType = .unfiltered,
                                           sorted sort: DatabaseSortType = .unsorted,
                                           callback: @escaping (Array<T>) -> Void,
                                           updates: @escaping (DatabaseObserveUpdate<T>) -> Void) -> DatabaseUpdatesToken where T.Container: CoreDataObject {
        let token = DatabaseUpdatesToken()

        readContext.perform {
            [weak self] in
            guard let s = self else { return }

            if token.isInvalidated { return }

            let predicate: NSPredicate?
            if let p = filter.predicate, let t = T.internalPredicate() {
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p, t])
            } else {
                predicate = T.internalPredicate() ?? filter.predicate
            }
            let constraints = T.Container.entity.uniquenessConstraints
            let request = NSFetchRequest<T.Container>(entityName: T.Container.entityName)
            request.predicate = predicate
            request.sortDescriptors = sort.sortDescriptors ?? constraints.first?.first.flatMap {
                [NSSortDescriptor(key: $0 as? String, ascending: false)]
            }

            let observer = FetchRequestObserver<T.Container>(fetchRequest: request, context: s.readContext)
            let objects: [T.Container]? = observer.fetchedResultsController.fetchedObjects

            callback(objects?.compactMap { try? T.mappable(for: $0) } ?? [T]())

            observer.observer = {
                (update: DatabaseObserveUpdate<T.Container>) in
                do {
                    updates(DatabaseObserveUpdate(values: try update.values.map { try T.mappable(for: $0) },
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

    public func fetchUnique<T: UniquelyMappable>(with key: T.ID, callback: @escaping (T?) -> Void) where T.Container: CoreDataObject {
        readContext.perform {
            [weak self] in
            guard let s = self else { return }
            let object: T.Container? = s.readContext.findFirst(with: T.idMapping(key))

            callback(object.flatMap { try? T.mappable(for: $0) })
        }
    }

    public func syncFetchUnique<T: UniquelyMappable>(with key: T.ID) -> T? where T.Container: CoreDataObject {

        var result: T? = nil

        readContext.performAndWait {
            [weak self] in
            guard let s = self else { return }
            let object: T.Container? = s.readContext.findFirst(with: T.idMapping(key))

            result = object.flatMap { try? T.mappable(for: $0) }
        }

        return result
    }

    public func fetch<T: UniquelyMappable>(with key: T.ID,
                                           callback: @escaping (T?) -> Void,
                                           updates: @escaping (DatabaseModelUpdate<T>) -> Void) -> DatabaseUpdatesToken where T.Container: CoreDataObject {
        let token = DatabaseUpdatesToken()

        readContext.perform {
            [weak self] in
            guard let s = self else { return }

            if token.isInvalidated { return }

            let object: T.Container? = s.readContext.findFirst(with: T.idMapping(key))

            callback(object.flatMap { try? T.mappable(for: $0) })

            guard let managed = object else { return }

            let observer = ManagedObjectObserver(object: managed) {
                change in

                switch change {
                case .delete:
                    DispatchQueue.main.async {
                        updates(.delete)
                    }
                case .update:
                    guard let mapped = try? T.mappable(for: managed) else { return }
                    DispatchQueue.main.async {
                        updates(.update(model: mapped))
                    }
                }
            }

            token.invalidation = {
                observer?.dispose()
            }
        }

        return token
    }

    // MARK: Type safe Fetching

    public func fetch<T: DatabaseMappable, P: Predicate>(_ predicate: P,
                                                         sorted sort: [SortDescriptor<T>] = [],
                                                         callback: @escaping ([T]) -> Void)
        where T.Container: CoreDataObject, P.ModelType == T {
        fetch(with: .predicate(predicate: predicate.predicate),
              sorted: sort.isEmpty ? .unsorted : .init(sortDescriptors: sort),
              callback: callback)
    }

    public func fetch<T: DatabaseMappable & KeyPathConvertible>(sorted sort: [SortDescriptor<T>] = [], callback: @escaping ([T]) -> Void)
        where T.Container: CoreDataObject {
        fetch(with: .unfiltered,
              sorted: sort.isEmpty ? .unsorted : .init(sortDescriptors: sort),
              callback: callback)
    }

    public func syncFetch<T: DatabaseMappable, P: Predicate>(_ predicate: P,
                                                             sorted sort: [SortDescriptor<T>] = []) -> [T]
        where T.Container: CoreDataObject, P.ModelType == T {
        syncFetch(with: .predicate(predicate: predicate.predicate),
                  sorted: sort.isEmpty ? .unsorted : .init(sortDescriptors: sort))
    }

    public func syncFetch<T: DatabaseMappable & KeyPathConvertible>(sorted sort: [SortDescriptor<T>] = []) -> [T] where T.Container: CoreDataObject {
        syncFetch(with: .unfiltered,
                  sorted: sort.isEmpty ? .unsorted : .init(sortDescriptors: sort))
    }

    public func fetch<T: DatabaseMappable, P: Predicate>(_ predicate: P,
                                                         sorted sort: [SortDescriptor<T>] = [],
                                                         callback: @escaping ([T]) -> Void,
                                                         next: (([T], Bool) -> Void)? = nil,
                                                         updates: @escaping (DatabaseObserveUpdate<T>) -> Void) -> DatabaseUpdatesToken
        where T.Container: CoreDataObject, P.ModelType == T {
        fetch(with: .predicate(predicate: predicate.predicate),
              sorted: sort.isEmpty ? .unsorted : .init(sortDescriptors: sort),
              callback: callback,
              updates: updates)
    }

    public func fetch<T: DatabaseMappable & KeyPathConvertible>(sorted sort: [SortDescriptor<T>] = [],
                                                                callback: @escaping ([T]) -> Void,
                                                                next: (([T], Bool) -> Void)? = nil,
                                                                updates: @escaping (DatabaseObserveUpdate<T>) -> Void) -> DatabaseUpdatesToken
        where T.Container: CoreDataObject {
        fetch(with: .unfiltered,
              sorted: sort.isEmpty ? .unsorted : .init(sortDescriptors: sort),
              callback: callback,
              updates: updates)
    }
}