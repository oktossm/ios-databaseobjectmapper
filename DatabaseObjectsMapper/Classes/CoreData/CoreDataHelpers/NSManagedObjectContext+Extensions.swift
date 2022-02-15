//
// Created by Mikhail Mulyar on 03/01/2018.
// Copyright (c) 2018 Mikhail Mulyar. All rights reserved.
//


import CoreData


extension NSManagedObjectContext {

    private var store: NSPersistentStore {
        guard let psc = persistentStoreCoordinator else { fatalError("PSC missing") }
        guard let store = psc.persistentStores.first else { fatalError("No Store") }
        return store
    }

    public var metaData: [String: AnyObject] {
        get {
            guard let psc = persistentStoreCoordinator else { fatalError("must have PSC") }
            return psc.metadata(for: store) as [String: AnyObject]
        }
        set {
            performChanges {
                guard let psc = self.persistentStoreCoordinator else { fatalError("PSC missing") }
                psc.setMetadata(newValue, for: self.store)
            }
        }
    }

    public func setMetaData(object: AnyObject?, forKey key: String) {
        var md = metaData
        md[key] = object
        metaData = md
    }

    /// Create new NSManagedObject
    ///
    /// - Parameter entity: NSManagedObject entity for detect type
    /// - Returns: new NSManagedObject instance inserted into specified context or nil

    public func insertObject<A: NSManagedObject>() -> A {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A else { fatalError("Wrong object type") }
        return obj
    }

    /// Get reference to NSManagedObject instance in context
    ///
    /// - Parameter entity: NSManagedObject entity
    /// - Returns: NSManagedObject reference in context or nil
    public func get<A: NSManagedObject>(_ entity: A) -> A? {
        if entity.objectID.isTemporaryID {
            do {
                try entity.managedObjectContext?.obtainPermanentIDs(for: [entity])
            } catch {
                CoreDataStorage.printError("Error while getting existing object in context \(error.localizedDescription)")
                return nil
            }
        }

        do {
            return try existingObject(with: entity.objectID) as? A
        } catch {
            CoreDataStorage.printError("Error while obtain object in context \(error.localizedDescription)")
            return nil
        }
    }

    /// Get count of entities
    ///
    /// - Parameters:
    ///   - entity: NSManagedObject entity for detect type
    ///   - predicate: NSPredicate for search
    /// - Returns: count of entities
    public func countOfEntities<A: NSManagedObject>(entity: A.Type, with predicate: NSPredicate) -> Int {
        do {
            return try entity.count(in: self)
        } catch {
            CoreDataStorage.printError("Failed to get count of \(A.entityName), error: \(error.localizedDescription)")
            return 0
        }
    }

    // MARK: - Find first with predicate

    /// Find first NSManagedObject with predicate
    ///
    /// - Parameters:
    ///   - predicate: NSPredicate for search
    ///   - sortDescriptors: NSSortDescriptor for sorting
    /// - Returns: NSManagedObject instance or nil
    public func findFirst<A: NSManagedObject>(with predicate: NSPredicate? = nil,
                                              sortDescriptors: [NSSortDescriptor]? = nil) -> A? {
        do {
            return try A.findOrFetch(in: self, matching: predicate, sortDescriptors: sortDescriptors)
        } catch {
            CoreDataStorage.printError("Failed to fetch first object of \(A.entityName), error: \(error.localizedDescription)")
            return nil
        }
    }

    /// Find first object
    ///
    /// - Parameters:
    ///   - sortedBy: column name to sort by
    ///   - ascending: direction to sort by
    /// - Returns: object or nil
    public func findFirst<A: NSManagedObject>(sortedBy: String, ascending: Bool) -> A? {
        // Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: sortedBy, ascending: ascending)

        return self.findFirst(with: nil, sortDescriptors: [sortDescriptor])
    }

    /// Find all objects with predicate
    ///
    /// - Parameters:
    ///   - predicate: NSPredicate for search
    ///   - sortDescriptors:
    ///   - fetchLimit:
    ///   - fetchOffset:
    /// - Returns: array of NSManagedObject's subclass instances
    public func findAll<A: NSManagedObject>(with predicate: NSPredicate? = nil,
                                            sortDescriptors: [NSSortDescriptor]? = nil,
                                            fetchLimit: Int = 0,
                                            fetchOffset: Int = 0) -> [A] {
        do {
            return try A.fetch(in: self) {
                request in
                request.predicate = predicate
                request.sortDescriptors = sortDescriptors
                request.fetchLimit = fetchLimit
                request.fetchOffset = fetchLimit
            }
        } catch {
            CoreDataStorage.printError("Failed to fetch request of \(A.entityName), error: \(error.localizedDescription)")
            return []
        }
    }

    /// Find all objects
    ///
    /// - Parameters:
    ///   - predicate:
    ///   - sortedBy: column name to sort by
    ///   - ascending: direction to sort by
    /// - Returns: array of NSManagedObject's subclass instances
    public func findAll<A: NSManagedObject>(predicate: NSPredicate? = nil, sortedBy: String, ascending: Bool) -> [A] {
        // Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: sortedBy, ascending: ascending)

        return self.findAll(with: predicate, sortDescriptors: [sortDescriptor])
    }

    /// Delete all objects
    ///
    /// - Parameters:
    ///   - entity: NSManagedObject entity for detect type
    ///   - predicate:
    public func deleteAll<T: NSManagedObject>(entity: T.Type, predicate: NSPredicate? = nil) {
        do {
            try entity.delete(in: self) {
                request in
                request.predicate = predicate
            }
        } catch {
            CoreDataStorage.printError("Failed to delete entities of \(T.entityName), error: \(error.localizedDescription)")
        }
    }

    public func deleteAllEntities() {

        if let entitiesByName = persistentStoreCoordinator?.managedObjectModel.entitiesByName {
            for (name, _) in entitiesByName {

                let request = NSFetchRequest<NSFetchRequestResult>(entityName: name)

                let batchRequest = NSBatchDeleteRequest(fetchRequest: request)
                batchRequest.resultType = .resultTypeStatusOnly

                do {
                    try execute(batchRequest)
                } catch {
                    CoreDataStorage.printError("Failed to delete entities of \(name), error: \(error.localizedDescription)")
                    return
                }
            }
        }
    }

    public func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            rollback()
            return false
        }
    }

    public func performSaveOrRollback() {
        perform {
            _ = self.saveOrRollback()
        }
    }

    public func performChanges(block: @escaping () -> ()) {
        perform {
            block()
            _ = self.saveOrRollback()
        }
    }
}


private let SingleObjectCacheKey = "SingleObjectCache"
private typealias SingleObjectCache = [String: NSManagedObject]


extension NSManagedObjectContext {
    public func set(_ object: NSManagedObject?, forSingleObjectCacheKey key: String) {
        var cache = userInfo[SingleObjectCacheKey] as? SingleObjectCache ?? [:]
        cache[key] = object
        userInfo[SingleObjectCacheKey] = cache
    }

    public func object(forSingleObjectCacheKey key: String) -> NSManagedObject? {
        guard let cache = userInfo[SingleObjectCacheKey] as? [String: NSManagedObject] else { return nil }
        return cache[key]
    }
}


extension NSManagedObjectContext {
    /// Find first object
    ///
    /// - Parameters:
    ///   - key: key to find object
    /// - Returns: object or nil
    func findFirst<A: UniqueDatabaseContainer>(with key: A.ID) -> A? where A: NSManagedObject {
        guard let keyPath = A.idKey._kvcKeyPathString else { return nil }
        return self.findFirst(with: NSPredicate(format: "%K = %@", argumentArray: [keyPath, key]))
    }

    func findAll<A: UniqueDatabaseContainer>(with keys: [A.ID]) -> [A.ID: A] where A: NSManagedObject {
        guard let keyPath = A.idKey._kvcKeyPathString else { return [A.ID: A]() }
        let values: [A] = self.findAll(with: NSPredicate(format: "%K IN %@", argumentArray: [keyPath, keys]))
        var result = [A.ID: A]()
        if let keyPath = A.idKey._kvcKeyPathString {
            for value in values {
                if let keyPathValue = value.value(forKeyPath: keyPath) as? A.ID {
                    result[keyPathValue] = value
                }
            }
        }

        return result
    }
}

