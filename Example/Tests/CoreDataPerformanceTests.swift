//
// Created by Mikhail Mulyar on 2019-08-08.
// Copyright (c) 2019 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
import CoreData
import DatabaseObjectsMapper
@testable import DatabaseObjectsMapper_Example


class CoreDataPerformanceTests: XCTestCase {

    lazy var service: CoreDataService = createService()

    var token: DatabaseUpdatesToken?

    func createService() -> CoreDataService {
        let setup = setUpInMemoryManagedObjectContext()
        let service = CoreDataService(storage: CoreDataStorage(store: .custom(setup.1, setup.0), model: .merged([Bundle.main]), migrate: false))
        return service
    }

    func setUpInMemoryManagedObjectContext() -> (NSManagedObjectContext, NSPersistentStoreCoordinator) {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!

        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil)
        } catch {
            print("Adding in-memory persistent store failed")
        }

        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator

        return (managedObjectContext, persistentStoreCoordinator)
    }

    override func setUp() {
        super.setUp()

        service = createService()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSimplePerformance() {
        let testModel = TestCDModel(id: 1, index: 3, name: "fr", count: 3, someCount: 4, urls: nil, subModel: .init())

        service.save(models: Array(0..<1000).map { testModel.idLens.set($0) })

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.measureMetrics(XCTestCase.defaultPerformanceMetrics, automaticallyStartMeasuring: false) {
                self.startMeasuring()
                let fetched: [TestCDModel] = self.service.syncFetch()
                self.stopMeasuring()
                XCTAssertTrue(fetched.count == 1000)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10)
    }
}