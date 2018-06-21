//
// Created by Mikhail Mulyar on 18/06/2018.
// Copyright (c) 2018 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
import CoreData
import DatabaseObjectsMapper
@testable import DatabaseObjectsMapper_Example


class CoreDataContainerTests: XCTestCase {

    var service: CoreDataService = CoreDataService()

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

        service.deleteAll()
        service = CoreDataService()
        //        let setup = setUpInMemoryManagedObjectContext()
        //        service = CoreDataService(storage: CoreDataStorage(store: .custom(setup.1, setup.0), model: .merged([Bundle.main]), migrate: false))
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSimpleStoreWithKey() {
        let testModel = TestCDModel(id: 1, index: 3, name: "fr", count: 3, superCount: 4, urls: nil, subModel: nil, children: nil)

        service.store(object: testModel)
        service.store(object: testModel)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let fetched = self.service.syncFetch(objectOf: TestCDModel.self, withPrimaryKey: .int(value: 1, key: "id"))
            let all = self.service.syncFetch(objectsOf: TestCDModel.self)

            XCTAssertTrue(all.count == 1)
            XCTAssertTrue(testModel == fetched)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testMultipleStoreWithKey() {
        let testModel = TestCDModel(id: 1, index: 3, name: "fr", count: 3, superCount: 4, urls: nil, subModel: nil, children: nil)
        let testModel2 = TestCDModel(id: 2, index: 1, name: "fr", count: 3, superCount: 4, urls: nil, subModel: nil, children: nil)

        service.store(objects: [testModel, testModel2])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let all = self.service.syncFetch(objectsOf: TestCDModel.self)

            XCTAssertTrue(all.sorted { $0.id < $1.id } == [testModel, testModel2])

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testMultipleUpdate() {
        let testModel = TestCDModel(id: 1, index: 3, name: "fr", count: 3, superCount: 4, urls: nil, subModel: nil, children: nil)
        let testModel2 = TestCDModel(id: 2, index: 1, name: "fr", count: 3, superCount: 4, urls: nil, subModel: nil, children: nil)
        let testModel3 = TestCDModel(id: 1, index: 5, name: "br", count: 3, superCount: 4, urls: nil, subModel: nil, children: nil)
        let testModel4 = TestCDModel(id: 2, index: 4, name: "fr", count: 3, superCount: 4, urls: nil, subModel: nil, children: nil)

        service.store(objects: [testModel, testModel2])
        service.update(objects: [testModel3, testModel4])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let all = self.service.syncFetch(objectsOf: TestCDModel.self)

            XCTAssertTrue(all.sorted { $0.id < $1.id } == [testModel3, testModel4])

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testUpdateByKey() {
        let testModel = TestCDModel(id: 1, index: 3, name: "fr", count: 3, superCount: 4, urls: nil, subModel: nil, children: nil)
        let testModel2 = TestCDModel(id: 1, index: 5, name: "br", count: 3, superCount: 4, urls: nil, subModel: nil, children: nil)

        service.store(objects: [testModel])
        service.update(objectOf: TestCDModel.self, withPrimaryKey: testModel.primaryKey, updates: testModel2.allUpdates())


        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let all = self.service.syncFetch(objectsOf: TestCDModel.self)

            XCTAssertTrue(all == [testModel2])

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testDelete() {
        let testModel = TestCDModel(id: 1, index: 3, name: "fr", count: 3, superCount: 4, urls: nil, subModel: nil, children: nil)
        let testModel2 = TestCDModel(id: 2, index: 1, name: "fr", count: 3, superCount: 4, urls: nil, subModel: nil, children: nil)

        service.store(objects: [testModel, testModel2])
        service.delete(objects: [testModel])
        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let all = self.service.syncFetch(objectsOf: TestCDModel.self)

            XCTAssertTrue(all == [testModel2])

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testPrimaryKeyFetch() {
        let testModel = TestCDModel(id: 1, index: 3, name: "fr", count: 3, superCount: 4, urls: nil, subModel: nil, children: nil)

        service.store(object: testModel)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.service.fetch(objectOf: TestCDModel.self, withPrimaryKey: testModel.primaryKey) {
                model in

                XCTAssertTrue(testModel == model)

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testFetch() {
        let testModel = TestCDModel(id: 1, index: 3, name: "fr", count: 3, superCount: 4, urls: nil, subModel: nil, children: nil)
        let testModel2 = TestCDModel(id: 2, index: 1, name: "fr", count: 3, superCount: 4, urls: nil, subModel: nil, children: nil)

        service.store(object: testModel)
        service.store(object: testModel2)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.service.fetch(objectsOf: TestCDModel.self) {
                all in

                XCTAssertTrue(all.sorted { $0.id < $1.id } == [testModel, testModel2])
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testFetchUpdate() {
        let testModel = TestCDModel(id: 1, index: 3, name: "fr", count: 3, superCount: 4, urls: nil, subModel: nil, children: nil)

        service.store(object: testModel)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let token = self.service.fetch(objectOf: TestCDModel.self, withPrimaryKey: testModel.primaryKey, callback: {
                model in

            }, updates: {
                update in

                switch update {
                case .update(let newModel):
                    XCTAssertTrue(newModel.count == 5)
                    expectation.fulfill()
                case .delete:break
                }
            })

            self.service.update(objectOf: TestCDModel.self, withPrimaryKey: testModel.primaryKey, updates: [TestCDModel.Updates.count(5)])

            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                token.invalidate()
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testFetchDelete() {
        let testModel = TestCDModel(id: 1, index: 3, name: "fr", count: 3, superCount: 4, urls: nil, subModel: nil, children: nil)

        service.store(object: testModel)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let token = self.service.fetch(objectOf: TestCDModel.self, withPrimaryKey: testModel.primaryKey, callback: {
                model in

            }, updates: {
                update in

                switch update {
                case .update:
                    XCTAssertTrue(false)
                case .delete:
                    XCTAssertTrue(true)
                    expectation.fulfill()
                }
            })

            self.service.delete(object: testModel)

            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                token.invalidate()
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testMultipleFetchInsert() {
        let testModel = TestCDModel(id: 1, index: 3, name: "fr", count: 3, superCount: 4, urls: nil, subModel: nil, children: nil)
        let testModel2 = TestCDModel(id: 2, index: 1, name: "fr", count: 3, superCount: 4, urls: nil, subModel: nil, children: nil)

        service.store(objects: [testModel])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            var token: DatabaseUpdatesToken?
            token = self.service.fetch(objectsOf: TestCDModel.self, with: .unfiltered, with: .unsorted, callback: {
                models in

            }, updates: {
                updates in

                token?.invalidate()

                XCTAssertTrue(updates.insertions.count == 1)
                expectation.fulfill()
            })

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.service.store(objects: [testModel2])
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testMultipleFetchDelete() {
        let testModel = TestCDModel(id: 1, index: 3, name: "fr", count: 3, superCount: 4, urls: nil, subModel: nil, children: nil)
        let testModel2 = TestCDModel(id: 2, index: 1, name: "fr", count: 3, superCount: 4, urls: nil, subModel: nil, children: nil)

        service.store(objects: [testModel, testModel2])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            var token: DatabaseUpdatesToken?
            token = self.service.fetch(objectsOf: TestCDModel.self, with: .unfiltered, with: .unsorted, callback: {
                models in

            }, updates: {
                updates in

                token?.invalidate()

                XCTAssertTrue(updates.deletions.count == 1)
                expectation.fulfill()
            })

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.service.delete(object: testModel2)
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testMultipleFetchUpdate() {
        let testModel = TestCDModel(id: 1, index: 3, name: "fr", count: 3, superCount: 4, urls: nil, subModel: nil, children: nil)
        let testModel2 = TestCDModel(id: 2, index: 1, name: "fr", count: 3, superCount: 4, urls: nil, subModel: nil, children: nil)

        service.store(objects: [testModel, testModel2])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let testModel3 = TestCDModel(id: 2, index: 5, name: "br", count: 23, superCount: 64, urls: nil, subModel: nil, children: nil)
            var token: DatabaseUpdatesToken?
            token = self.service.fetch(objectsOf: TestCDModel.self, with: .unfiltered, with: .unsorted, callback: {
                models in

            }, updates: {
                updates in

                token?.invalidate()

                XCTAssertTrue(updates.modifications.count == 1)
                XCTAssertTrue(updates.values.contains(testModel3))
                expectation.fulfill()
            })

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.service.update(object: testModel3)
            }
        }
        wait(for: [expectation], timeout: 1)
    }
}