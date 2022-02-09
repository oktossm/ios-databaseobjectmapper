//
// Created by Mikhail Mulyar on 03/01/2018.
// Copyright (c) 2018 Mikhail Mulyar. All rights reserved.
//


import Foundation
import CoreData


public struct ContextDidSaveNotification {

    public init(note: Notification) {
        guard note.name == .NSManagedObjectContextDidSave else { fatalError() }
        notification = note
    }

    public var insertedObjects: AnyIterator<NSManagedObject> {
        iterator(forKey: NSInsertedObjectsKey)
    }

    public var updatedObjects: AnyIterator<NSManagedObject> {
        iterator(forKey: NSUpdatedObjectsKey)
    }

    public var deletedObjects: AnyIterator<NSManagedObject> {
        iterator(forKey: NSDeletedObjectsKey)
    }

    public var managedObjectContext: NSManagedObjectContext {
        guard let c = notification.object as? NSManagedObjectContext else { fatalError("Invalid notification object") }
        return c
    }


    // MARK: Private

    fileprivate let notification: Notification

    fileprivate func iterator(forKey key: String) -> AnyIterator<NSManagedObject> {
        guard let set = (notification as Notification).userInfo?[key] as? NSSet else {
            return AnyIterator { nil }
        }
        var innerIterator = set.makeIterator()
        return AnyIterator { innerIterator.next() as? NSManagedObject }
    }
}


extension ContextDidSaveNotification: CustomDebugStringConvertible {
    public var debugDescription: String {
        var components = [notification.name.rawValue]
        components.append(managedObjectContext.description)
        for (name, set) in [("inserted", insertedObjects), ("updated", updatedObjects), ("deleted", deletedObjects)] {
            let all = set.map { $0.objectID.description }.joined(separator: ", ")
            components.append("\(name): {\(all)})")
        }
        return components.joined(separator: " ")
    }
}


public struct ContextWillSaveNotification {

    public init(note: Notification) {
        assert(note.name == .NSManagedObjectContextWillSave)
        notification = note
    }

    public var managedObjectContext: NSManagedObjectContext {
        guard let c = notification.object as? NSManagedObjectContext else { fatalError("Invalid notification object") }
        return c
    }


    // MARK: Private

    fileprivate let notification: Notification
}


public struct ObjectsDidChangeNotification {

    init(note: Notification) {
        assert(note.name == .NSManagedObjectContextObjectsDidChange)
        notification = note
    }

    public var insertedObjects: Set<NSManagedObject> {
        objects(forKey: NSInsertedObjectsKey)
    }

    public var updatedObjects: Set<NSManagedObject> {
        objects(forKey: NSUpdatedObjectsKey)
    }

    public var deletedObjects: Set<NSManagedObject> {
        objects(forKey: NSDeletedObjectsKey)
    }

    public var refreshedObjects: Set<NSManagedObject> {
        objects(forKey: NSRefreshedObjectsKey)
    }

    public var invalidatedObjects: Set<NSManagedObject> {
        objects(forKey: NSInvalidatedObjectsKey)
    }

    public var invalidatedAllObjects: Bool {
        (notification as Notification).userInfo?[NSInvalidatedAllObjectsKey] != nil
    }

    public var managedObjectContext: NSManagedObjectContext {
        guard let c = notification.object as? NSManagedObjectContext else { fatalError("Invalid notification object") }
        return c
    }


    // MARK: Private

    fileprivate let notification: Notification

    fileprivate func objects(forKey key: String) -> Set<NSManagedObject> {
        ((notification as Notification).userInfo?[key] as? Set<NSManagedObject>) ?? Set()
    }
}


extension NSManagedObjectContext {

    /// Adds the given block to the default `NotificationCenter`'s dispatch table for the given context's did-save notifications.
    /// - returns: An opaque object to act as the observer. This must be sent to the default `NotificationCenter`'s `removeObserver()`.
    public func addContextDidSaveNotificationObserver(_ handler: @escaping (ContextDidSaveNotification) -> ()) -> NSObjectProtocol {
        let nc = NotificationCenter.default
        return nc.addObserver(forName: .NSManagedObjectContextDidSave, object: self, queue: nil) {
            note in
            let wrappedNote = ContextDidSaveNotification(note: note)
            handler(wrappedNote)
        }
    }

    /// Adds the given block to the default `NotificationCenter`'s dispatch table for the given context's will-save notifications.
    /// - returns: An opaque object to act as the observer. This must be sent to the default `NotificationCenter`'s `removeObserver()`.
    public func addContextWillSaveNotificationObserver(_ handler: @escaping (ContextWillSaveNotification) -> ()) -> NSObjectProtocol {
        let nc = NotificationCenter.default
        return nc.addObserver(forName: .NSManagedObjectContextWillSave, object: self, queue: nil) {
            note in
            let wrappedNote = ContextWillSaveNotification(note: note)
            handler(wrappedNote)
        }
    }

    /// Adds the given block to the default `NotificationCenter`'s dispatch table for the given context's objects-did-change notifications.
    /// - returns: An opaque object to act as the observer. This must be sent to the default `NotificationCenter`'s `removeObserver()`.
    public func addObjectsDidChangeNotificationObserver(_ handler: @escaping (ObjectsDidChangeNotification) -> ()) -> NSObjectProtocol {
        let nc = NotificationCenter.default
        return nc.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: self, queue: nil) {
            note in
            let wrappedNote = ObjectsDidChangeNotification(note: note)
            handler(wrappedNote)
        }
    }

    public func performMergeChanges(from note: ContextDidSaveNotification) {
        perform {
            self.mergeChanges(fromContextDidSave: note.notification)
        }
    }

    func observeToGetPermanentIDsBeforeSaving() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextWillSave, object: self, queue: nil, using: {
            [weak self] (notification) in
            guard let s = self else {
                return
            }
            if s.insertedObjects.count == 0 {
                return
            }
            _ = try? s.obtainPermanentIDs(for: Array(s.insertedObjects))
        })
    }
}


