//
// Created by Mikhail Mulyar on 06/01/2018.
// Copyright (c) 2018 Mikhail Mulyar. All rights reserved.
//

import Foundation
import CoreData
import UIKit


internal enum FetchRequestChange<T> {

    case update(Int, T)
    case delete(Int, T)
    case insert(Int, T)

    internal func object() -> T {
        switch self {
        case .update(_, let object): return object
        case .delete(_, let object): return object
        case .insert(_, let object): return object
        }
    }

    internal func index() -> Int {
        switch self {
        case .update(let index, _): return index
        case .delete(let index, _): return index
        case .insert(let index, _): return index
        }
    }

    internal var isDeletion: Bool {
        switch self {
        case .delete: return true
        default: return false
        }
    }

    internal var isUpdate: Bool {
        switch self {
        case .update: return true
        default: return false
        }
    }

    internal var isInsertion: Bool {
        switch self {
        case .insert: return true
        default: return false
        }
    }
}


internal class FetchRequestObserver<T: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {

    // MARK: - Attributes
    internal var fetchRequest: NSFetchRequest<T> {
        didSet {
            _ = try? fetchedResultsController.performFetch()
        }
    }
    internal var observer: ((DatabaseObserveUpdate<T>) -> Void)?
    internal let fetchedResultsController: NSFetchedResultsController<T>
    private var batchChanges: [FetchRequestChange<T>] = []


    // MARK: - Init
    internal init(fetchRequest: NSFetchRequest<T>, context: NSManagedObjectContext) {
        self.fetchRequest = fetchRequest
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: context,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)

        super.init()

        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            CoreDataStorage.printError("Failed to fetch objects: \(error.userInfo)")
        }
    }

    // MARK: - Dispose Method

    func dispose() {
        fetchedResultsController.delegate = nil
    }


    // MARK: - NSFetchedResultsControllerDelegate

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                           didChange anObject: Any,
                           at indexPath: IndexPath?,
                           for type: NSFetchedResultsChangeType,
                           newIndexPath: IndexPath?) {

        var index: Int?
        var newIndex: Int?

        index = indexPath?.row
        newIndex = newIndexPath?.row

        switch type {
        case .delete:
            batchChanges.append(.delete(index!, anObject as! T))
        case .insert:
            batchChanges.append(.insert(newIndex!, anObject as! T))
        case .update:
            batchChanges.append(.update(index!, anObject as! T))
        default: break
        }
    }

    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        batchChanges = []
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let deleted = batchChanges.filter { $0.isDeletion }.map { $0.index() }
        let inserted = batchChanges.filter { $0.isInsertion }.map { $0.index() }
        let updated = batchChanges.filter { $0.isUpdate }.map { $0.index() }
        observer?(DatabaseObserveUpdate(values: fetchedResultsController.fetchedObjects ?? [T](),
                                        deletions: deleted,
                                        insertions: inserted,
                                        modifications: updated))
    }
}
