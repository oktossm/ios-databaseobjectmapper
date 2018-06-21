//
// Created by Mikhail Mulyar on 03/01/2018.
// Copyright (c) 2018 Mikhail Mulyar. All rights reserved.
//

import CoreData


public enum CoreDataStore {

    case named(String)
    case url(URL)
    case custom(NSPersistentStoreCoordinator, NSManagedObjectContext?)

    public func path() -> URL {
        switch self {
        case .url(let url): return url
        case .named(let name):
            return URL(fileURLWithPath: documentsDirectory()).appendingPathComponent(name)
        case .custom(let coordinator, _):
            guard let store = coordinator.persistentStores.first else { fatalError("No available stores") }
            return coordinator.url(for: store)
        }
    }
}


func documentsDirectory() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    return paths[0]
}


public enum CoreDataObjectModel {

    case named(String, Bundle)
    case merged([Bundle]?)
    case url(URL)

    func model() -> NSManagedObjectModel? {
        switch self {
        case .merged(let bundles):
            return NSManagedObjectModel.mergedModel(from: bundles)
        case .named(let name, let bundle):
            return NSManagedObjectModel(contentsOf: bundle.url(forResource: name, withExtension: "momd")!)
        case .url(let url):
            return NSManagedObjectModel(contentsOf: url)
        }

    }

}


public enum CoreDataOptions {

    case basic
    case migration

    func dict() -> [String: AnyObject] {
        switch self {
        case .basic:
            var sqliteOptions: [String: String] = [String: String]()
            sqliteOptions["journal_mode"] = "DELETE"
            var options: [String: AnyObject] = [String: AnyObject]()
            options[NSMigratePersistentStoresAutomaticallyOption] = NSNumber(value: true)
            options[NSInferMappingModelAutomaticallyOption] = NSNumber(value: false)
            options[NSSQLitePragmasOption] = sqliteOptions as AnyObject?
            return options
        case .migration:
            var sqliteOptions: [String: String] = [String: String]()
            sqliteOptions["journal_mode"] = "DELETE"
            var options: [String: AnyObject] = [String: AnyObject]()
            options[NSMigratePersistentStoresAutomaticallyOption] = NSNumber(value: true)
            options[NSInferMappingModelAutomaticallyOption] = NSNumber(value: true)
            options[NSSQLitePragmasOption] = sqliteOptions as AnyObject?
            return options
        }
    }

}


public class CoreDataStorage {

    /// Set this variable to true if you want to print errors to console
    public static var printErrors: Bool = true

    private let store: CoreDataStore
    private let model: CoreDataObjectModel
    private let migrate: Bool

    private weak var externalContext: NSManagedObjectContext?
    private var externalObserver: NSObjectProtocol?
    private var internalObserver: NSObjectProtocol?

    public init(store: CoreDataStore = .named("CoreData.sqlite"), model: CoreDataObjectModel = .merged(nil), migrate: Bool = true) {
        self.store = store
        self.model = model
        self.migrate = migrate

        if case .custom(let coordinator, let externalContext) = store {
            self.persistentStoreCoordinator = coordinator
            self.externalContext = externalContext

            self.externalObserver = self.externalContext?.addContextDidSaveNotificationObserver {
                [weak self] notification in
                self?.rootContext.performMergeChanges(from: notification)
            }

            self.internalObserver = self.rootContext.addContextDidSaveNotificationObserver {
                [weak self] notification in
                self?.externalContext?.performMergeChanges(from: notification)
            }
        } else {
            let _ = self.rootContext
        }
    }

    deinit {
        if let observer = self.externalObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = self.internalObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    /// NSManagedObjectModel for CoreDataStorage stack
    /// This property is not optional. It is a fatal error for the application not to be able to find and load its model.
    private lazy var managedObjectModel: NSManagedObjectModel = {

        let model: NSManagedObjectModel? = self.model.model()

        guard let mom = model else {
            fatalError("Could not load model")
        }

        return mom
    }()

    /// NSPersistentStoreCoordinator for CoreDataStorage stack.
    /// Creates and returns instance of NSPersistentStoreCoordinator. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)

        var addStore: ((_ store: CoreDataStore, _ storeCoordinator: NSPersistentStoreCoordinator, _ options: [String: AnyObject], _ cleanAndRetryIfMigrationFails: Bool) throws -> NSPersistentStore)?

        // Migration options for persistent store
        let options = self.migrate ? CoreDataOptions.migration : CoreDataOptions.basic


        addStore = {
            [weak self]
            (store: CoreDataStore,
             coordinator: NSPersistentStoreCoordinator,
             options: [String: AnyObject],
             retry: Bool) throws -> NSPersistentStore in

            var persistentStore: NSPersistentStore?
            var error: NSError?

            coordinator.performAndWait {
                do {
                    persistentStore = try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                                         configurationName: nil,
                                                                         at: store.path(),
                                                                         options: options)
                } catch let _error as NSError {
                    error = _error
                }
            }

            if let error = error {
                let isMigrationError = error.code == NSPersistentStoreIncompatibleVersionHashError || error.code == NSMigrationMissingSourceModelError
                if isMigrationError && retry {
                    _ = try? self?.cleanStoreFilesAfterFailedMigration(store: store)
                    return try addStore!(store, coordinator, options, false)
                } else {
                    throw error
                }
            } else if let persistentStore = persistentStore {
                return persistentStore
            }

            throw NSError(domain: "com.coredata.setup.domain", code: 0)
        }

        if let result = try? addStore!(store, coordinator, options.dict(), true) {
            return coordinator
        }

        return nil
    }()

    /// NSManagedObjectContext with privateQueueConcurrencyType
    /// It's used internally in CoreDataStorage as the only context to write to persistence store
    /// For saving data use backgroundContext instead
    lazy var rootContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.shouldDeleteInaccessibleFaults = true
        return context
    }()

    /// NSManagedObjectContext with privateQueueConcurrencyType
    /// Use it for background save operations
    public var newSavingContext: NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = self.rootContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    /// Save all contexts
    ///
    /// - Parameter receivedContext: background context to save
    /// - Returns: success of contexts save operation (true or false)
    func saveContexts(contextWithObject receivedContext: NSManagedObjectContext) {

        receivedContext.perform {
            [weak self] in
            do {
                // Save background NSManagedObjectContext
                try receivedContext.save()

                self?.rootContext.perform {
                    if self?.rootContext.hasChanges == true {
                        do {
                            // Save root NSManagedObjectContext
                            try self?.rootContext.save()
                        } catch let error as NSError {
                            // Writing NSManagedObjectContext save error
                            CoreDataStorage.printError("Writing NSManagedObjectContext save error: \(String(describing: error.userInfo))")
                        } catch let exception as NSException {
                            CoreDataStorage.printError("Background NSManagedObjectContext save exception: \(String(describing: exception.userInfo))")
                        }
                    }
                }
            } catch let error as NSError {
                // Background NSManagedObjectContext save error
                CoreDataStorage.printError("Background NSManagedObjectContext save error: \(String(describing: error.userInfo))")
            } catch let exception as NSException {
                CoreDataStorage.printError("Background NSManagedObjectContext save exception: \(String(describing: exception.userInfo))")
            }
        }
        return
    }

    /// Save all contexts and wait
    ///
    /// - Parameter receivedContext: background context to save
    /// - Returns: success of contexts save operation (true or false)
    func saveContextsAndWait(contextWithObject receivedContext: NSManagedObjectContext) -> Bool {

        var success = true

        receivedContext.performAndWait {
            [weak self] in
            do {
                // Save background NSManagedObjectContext
                try receivedContext.save()

                self?.rootContext.performAndWait {
                    if self?.rootContext.hasChanges == true {
                        do {
                            // Save root NSManagedObjectContext
                            try self?.rootContext.save()
                        } catch let error as NSError {
                            // Writing NSManagedObjectContext save error
                            CoreDataStorage.printError("Writing NSManagedObjectContext save error: \(error.userInfo)")
                            success = false
                        }
                    }
                }
            } catch let error as NSError {
                // Background NSManagedObjectContext save error
                CoreDataStorage.printError("Background NSManagedObjectContext save error: \(error.userInfo)")
                success = false
            }
        }
        return success
    }

    public func destroyStore() throws {
        try persistentStoreCoordinator?.destroyPersistentStore(at: store.path(), ofType: NSSQLiteStoreType)
    }

    public func removeStore() throws {
        try FileManager.default.removeItem(at: store.path())
        _ = try? FileManager.default.removeItem(atPath: "\(store.path().absoluteString)-shm")
        _ = try? FileManager.default.removeItem(atPath: "\(store.path().absoluteString)-wal")

    }

    internal func cleanStoreFilesAfterFailedMigration(store: CoreDataStore) throws {
        let rawUrl: String = store.path().absoluteString
        let shmSidecar: NSURL = NSURL(string: rawUrl.appending("-shm"))!
        let walSidecar: NSURL = NSURL(string: rawUrl.appending("-wal"))!
        try FileManager.default.removeItem(at: store.path())
        try FileManager.default.removeItem(at: shmSidecar as URL)
        try FileManager.default.removeItem(at: walSidecar as URL)
    }

    /// Print error in console
    /// Will print error only if `printErrors` set in true
    ///
    /// - Parameter error: String error text
    static func printError(_ error: String) {
        if CoreDataStorage.printErrors {
            print("⚠️ ", error)
        }
    }
}