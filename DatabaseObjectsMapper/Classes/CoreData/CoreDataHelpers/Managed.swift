//
// Created by Mikhail Mulyar on 03/01/2018.
// Copyright (c) 2018 Mikhail Mulyar. All rights reserved.
//


import CoreData


public protocol Managed: NSFetchRequestResult {
    static var entity: NSEntityDescription { get }
    static var entityName: String { get }
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
    static var defaultPredicate: NSPredicate { get }
    var managedObjectContext: NSManagedObjectContext? { get }
}


extension NSManagedObject: Managed {
}


public protocol DefaultManaged: Managed {
}


extension DefaultManaged {
    public static var defaultPredicate: NSPredicate {
        return NSPredicate(value: true)
    }
}


extension Managed {

    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return []
    }
    public static var defaultPredicate: NSPredicate {
        return NSPredicate(value: true)
    }

    public static var sortedFetchRequest: NSFetchRequest<Self> {
        let request = NSFetchRequest<Self>(entityName: entityName)
        request.sortDescriptors = defaultSortDescriptors
        request.predicate = defaultPredicate
        return request
    }

    public static func sortedFetchRequest(with predicate: NSPredicate) -> NSFetchRequest<Self> {
        let request = sortedFetchRequest
        guard let existingPredicate = request.predicate else { fatalError("must have predicate") }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [existingPredicate, predicate])
        return request
    }

    public static func predicate(format: String, _ args: CVarArg...) -> NSPredicate {
        let p = withVaList(args) { NSPredicate(format: format, arguments: $0) }
        return predicate(p)
    }

    public static func predicate(_ predicate: NSPredicate) -> NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [defaultPredicate, predicate])
    }
}


extension Managed where Self: NSManagedObject {

    public static var entity: NSEntityDescription {
        return entity()
    }

    public static var entityName: String {
        return entity.name ?? String(describing: self)
    }

    public static func findOrCreate(in context: NSManagedObjectContext, matching predicate: NSPredicate, configure: (Self) -> ()) throws -> Self {
        guard let object = try findOrFetch(in: context, matching: predicate) else {
            let newObject: Self = context.insertObject()
            configure(newObject)
            return newObject
        }
        return object
    }

    public static func findOrFetch(in context: NSManagedObjectContext,
                                   matching predicate: NSPredicate? = nil,
                                   sortDescriptors: [NSSortDescriptor]? = nil) throws -> Self? {
        guard let object = materializedObject(in: context, matching: predicate, sortDescriptors: sortDescriptors) else {
            return try fetch(in: context) {
                request in
                request.predicate = predicate
                request.sortDescriptors = sortDescriptors
                request.returnsObjectsAsFaults = false
                request.fetchLimit = 1
            }
                    .first
        }
        return object
    }

    public static func fetch(in context: NSManagedObjectContext, configurationBlock: (NSFetchRequest<Self>) -> () = { _ in }) throws -> [Self] {
        let request = NSFetchRequest<Self>(entityName: Self.entityName)
        configurationBlock(request)
        return try context.fetch(request)
    }

    public static func delete(in context: NSManagedObjectContext,
                              configurationBlock: (NSFetchRequest<NSFetchRequestResult>) -> () = { _ in }) throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Self.entityName)
        configurationBlock(request)

        let batchRequest = NSBatchDeleteRequest(fetchRequest: request)
        batchRequest.resultType = .resultTypeObjectIDs
        let result = try context.execute(batchRequest) as? NSBatchDeleteResult
        guard let objectIDArray = result?.result as? [NSManagedObjectID] else { return }
        let changes = [NSDeletedObjectsKey: objectIDArray]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context.parent ?? context])
    }

    public static func count(in context: NSManagedObjectContext, configure: (NSFetchRequest<Self>) -> () = { _ in }) throws -> Int {
        let request = NSFetchRequest<Self>(entityName: entityName)
        configure(request)
        return try context.count(for: request)
    }

    public static func materializedObjects(in context: NSManagedObjectContext,
                                           matching predicate: NSPredicate? = nil,
                                           sortDescriptors: [NSSortDescriptor]? = nil) -> [Self] {
        var objects = [Self]()
        for object in context.registeredObjects where !object.isFault {
            guard let result = object as? Self, (predicate?.evaluate(with: result) ?? true) else { continue }
            objects.append(result)
        }
        return (sortDescriptors.flatMap { (objects as NSArray).sortedArray(using: $0) } as? [Self]) ?? objects
    }

    public static func materializedObject(in context: NSManagedObjectContext,
                                          matching predicate: NSPredicate? = nil,
                                          sortDescriptors: [NSSortDescriptor]? = nil) -> Self? {
        var objects = [Any]()
        for object in context.registeredObjects where !object.isFault {
            guard let result = object as? Self, (predicate?.evaluate(with: result) ?? true) else { continue }
            objects.append(result)
        }
        return (sortDescriptors.flatMap { (objects as NSArray).sortedArray(using: $0) }?.first ?? objects.first) as? Self
    }
}


extension Managed where Self: NSManagedObject {
    public static func fetchSingleObject(in context: NSManagedObjectContext, cacheKey: String, configure: (NSFetchRequest<Self>) -> ()) -> Self? {
        if let cached = context.object(forSingleObjectCacheKey: cacheKey) as? Self {
            return cached
        }
        let result = fetchSingleObject(in: context, configure: configure)
        context.set(result, forSingleObjectCacheKey: cacheKey)
        return result
    }

    fileprivate static func fetchSingleObject(in context: NSManagedObjectContext, configure: (NSFetchRequest<Self>) -> ()) -> Self? {
        guard let result = try? fetch(in: context, configurationBlock: {
            request in
            configure(request)
            request.fetchLimit = 2
        }) else { return nil }
        switch result.count {
        case 0: return nil
        case 1: return result[0]
        default: fatalError("Returned multiple objects, expected max 1")
        }
    }
}