//
// Created by Mikhail Mulyar on 06/01/2018.
// Copyright (c) 2018 Mikhail Mulyar. All rights reserved.
//

import Foundation
import CoreData


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
            _ = try? self.fetchedResultsController.performFetch()
        }
    }
    internal var observer: ((DatabaseObserveUpdate<T>) -> Void)?
    internal let fetchedResultsController: NSFetchedResultsController<T>
    private var batchChanges: [FetchRequestChange<T>] = []


    // MARK: - Init
    internal init(fetchRequest: NSFetchRequest<T>, context: NSManagedObjectContext) {
        self.fetchRequest = fetchRequest
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                   managedObjectContext: context,
                                                                   sectionNameKeyPath: nil,
                                                                   cacheName: nil)

        super.init()

        self.fetchedResultsController.delegate = self

        do {
            try self.fetchedResultsController.performFetch()
        } catch let error as NSError {
            CoreDataStorage.printError("Failed to fetch objects: \(error.userInfo)")
        }
    }

    // MARK: - Dispose Method

    func dispose() {
        self.fetchedResultsController.delegate = nil
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
            self.batchChanges.append(.delete(index!, anObject as! T))
        case .insert:
            self.batchChanges.append(.insert(newIndex!, anObject as! T))
        case .update:
            self.batchChanges.append(.update(index!, anObject as! T))
        default: break
        }
    }

    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.batchChanges = []
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let deleted = self.batchChanges.filter { $0.isDeletion }.map { $0.index() }
        let inserted = self.batchChanges.filter { $0.isInsertion }.map { $0.index() }
        let updated = self.batchChanges.filter { $0.isUpdate }.map { $0.index() }
        self.observer?(DatabaseObserveUpdate(values: self.fetchedResultsController.fetchedObjects ?? [T](),
                                             deletions: deleted,
                                             insertions: inserted,
                                             modifications: updated))
    }
}
