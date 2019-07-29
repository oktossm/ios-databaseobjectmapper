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

    func testSimpleStoreWithKey() {
        let testModel = TestCDModel(id: 1, index: 3, name: "fr", count: 3, someCount: 4, urls: nil, subModel: .init())

        service.save(model: testModel)
        service.save(model: testModel)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let fetched: TestCDModel? = self.service.syncFetch(with: 1)
            let all: [TestCDModel] = self.service.syncFetch()

            XCTAssertTrue(all.count == 1)
            XCTAssertTrue(testModel == fetched)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testSimpleStoreWithoutKey() {
        let model = TestCDSimpleModel(title: "count", count: 3)

        service.simpleSave(model: model)
        service.simpleSave(model: model)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let fetched: [TestCDSimpleModel] = self.service.syncFetch()

            XCTAssertTrue(fetched.count == 2)
            XCTAssertTrue(fetched.contains { $0 != model } == false, "\(fetched)")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testMultipleStoreWithKey() {
        let testModel = TestCDModel(id: 1, index: 3, name: "fr", count: 3, someCount: 4, urls: nil, subModel: .init())
        let testModel2 = TestCDModel(id: 2, index: 1, name: "fr", count: 3, someCount: 4, urls: nil, subModel: .init())

        service.save(models: [testModel, testModel2])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let all: [TestCDModel] = self.service.syncFetch()

            XCTAssertTrue(all.sorted { $0.id < $1.id } == [testModel, testModel2])

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testMultipleUpdate() {
        let testModel = TestCDModel(id: 1, index: 3, name: "fr", count: 3, someCount: 4, urls: nil, subModel: .init())
        let testModel2 = TestCDModel(id: 2, index: 1, name: "fr", count: 3, someCount: 4, urls: nil, subModel: .init())
        let testModel3 = TestCDModel(id: 1, index: 5, name: "br", count: 3, someCount: 4, urls: nil, subModel: .init())
        let testModel4 = TestCDModel(id: 2, index: 4, name: "fr", count: 3, someCount: 4, urls: nil, subModel: .init())

        service.save(models: [testModel, testModel2])
        service.update(models: [testModel3, testModel4])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let all: [TestCDModel] = self.service.syncFetch()

            XCTAssertTrue(all.sorted { $0.id < $1.id } == [testModel3, testModel4])

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testUpdateByKey() {
        let testModel = TestCDModel(id: 1, index: 3, name: "fr", count: 3, someCount: 4, urls: nil, subModel: .init())
        let testModel2 = TestCDModel(id: 1, index: 5, name: "br", count: 3, someCount: 4, urls: nil, subModel: .init())

        service.save(models: [testModel])
        service.update(modelOf: TestCDModel.self, with: testModel.id, updates: testModel2.encodedValue)


        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let all: [TestCDModel] = self.service.syncFetch()

            XCTAssertTrue(all == [testModel2])

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }


    func testPartialUpdate() {
        let testModel = TestCDModel(id: 1, index: 3, name: "fr", count: 3, someCount: 4, urls: nil, subModel: .init())
        let testModel2 = TestCDModel(id: 1, index: nil, name: "br", count: 3, someCount: 4, urls: nil, subModel: .init())

        service.save(models: [testModel])
        service.update(modelOf: TestCDModel.self, with: testModel.id, updates: testModel2.difference(from: testModel).dictionaryRepresentation())


        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let all: [TestCDModel] = self.service.syncFetch()

            XCTAssertTrue(all == [testModel2])

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testDelete() {
        let testModel = TestCDModel(id: 1, index: 3, name: "fr", count: 3, someCount: 4, urls: nil, subModel: .init())
        let testModel2 = TestCDModel(id: 2, index: 1, name: "fr", count: 3, someCount: 4, urls: nil, subModel: .init())

        service.save(models: [testModel, testModel2])
        service.delete(models: [testModel])
        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let all: [TestCDModel] = self.service.syncFetch()

            XCTAssertTrue(all == [testModel2])

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testPrimaryKeyFetch() {
        let testModel = TestCDModel(id: 1, index: 3, name: "fr", count: 3, someCount: 4, urls: nil, subModel: .init())

        service.save(model: testModel)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.service.fetch(with: testModel.id) {
                (model: TestCDModel?) in

                XCTAssertTrue(testModel == model)

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testFetch() {
        let testModel = TestCDModel(id: 1, index: 3, name: "fr", count: 3, someCount: 4, urls: nil, subModel: .init())
        let testModel2 = TestCDModel(id: 2, index: 1, name: "fr", count: 3, someCount: 4, urls: nil, subModel: .init())

        service.save(model: testModel)
        service.save(model: testModel2)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.service.fetch() {
                (all: [TestCDModel]) in

                XCTAssertTrue(all.sorted { $0.id < $1.id } == [testModel, testModel2])
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testFetchUpdate() {
        let testModel = TestCDModel(id: 1, index: 3, name: "fr", count: 3, someCount: 4, urls: nil, subModel: .init())

        service.save(model: testModel)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.token = self.service.fetch(with: testModel.id, callback: {
                (_: TestCDModel?) in
                self.service.update(modelOf: TestCDModel.self,
                                    with: testModel.id,
                                    updates: [TestCDModel.Updates.count(5)].dictionaryRepresentation())
            }, updates: {
                update in

                switch update {
                case .update(let newModel):
                    XCTAssertTrue(newModel.count == 5)
                    expectation.fulfill()
                case .delete:break
                }
                self.token?.invalidate()
            })
        }
        wait(for: [expectation], timeout: 1)
    }

    func testFetchDelete() {
        let testModel = TestCDModel(id: 1, index: 3, name: "fr", count: 3, someCount: 4, urls: nil, subModel: .init())

        service.save(model: testModel)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.token = self.service.fetch(with: testModel.id, callback: {
                (_: TestCDModel?) in
                self.service.delete(model: testModel)
            }, updates: {
                update in

                switch update {
                case .update:
                    XCTAssertTrue(false)
                case .delete:
                    XCTAssertTrue(true)
                    expectation.fulfill()
                }
                self.token?.invalidate()
            })
        }
        wait(for: [expectation], timeout: 1)
    }

    func testMultipleFetchInsert() {
        let testModel = TestCDModel(id: 1, index: 3, name: "fr", count: 3, someCount: 4, urls: nil, subModel: .init())
        let testModel2 = TestCDModel(id: 2, index: 1, name: "fr", count: 3, someCount: 4, urls: nil, subModel: .init())

        service.save(models: [testModel])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.token = self.service.fetch(with: .unfiltered, with: .unsorted, callback: {
                (_: [TestCDModel]) in
                self.service.save(models: [testModel2])
            }, updates: {
                updates in

                XCTAssertTrue(updates.insertions.count == 1)
                expectation.fulfill()
                self.token?.invalidate()
            })
        }
        wait(for: [expectation], timeout: 1)
    }

    func testMultipleFetchDelete() {
        let testModel = TestCDModel(id: 1, index: 3, name: "fr", count: 3, someCount: 4, urls: nil, subModel: .init())
        let testModel2 = TestCDModel(id: 2, index: 1, name: "fr", count: 3, someCount: 4, urls: nil, subModel: .init())

        service.save(models: [testModel, testModel2])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.token = self.service.fetch(with: .unfiltered, with: .unsorted, callback: {
                (_: [TestCDModel]) in
                self.service.delete(model: testModel2)
            }, updates: {
                updates in

                XCTAssertTrue(updates.deletions.count == 1)
                expectation.fulfill()
                self.token?.invalidate()
            })
        }
        wait(for: [expectation], timeout: 1)
    }

    func testMultipleFetchUpdate() {
        let testModel = TestCDModel(id: 1, index: 3, name: "fr", count: 3, someCount: 4, urls: nil, subModel: .init())
        let testModel2 = TestCDModel(id: 2, index: 1, name: "fr", count: 3, someCount: 4, urls: nil, subModel: .init())

        service.save(models: [testModel, testModel2])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let testModel3 = TestCDModel(id: 2, index: 5, name: "br", count: 23, someCount: 64, urls: nil, subModel: .init())
            self.token = self.service.fetch(with: .unfiltered, with: .unsorted, callback: {
                (_: [TestCDModel]) in
                self.service.update(model: testModel3)
            }, updates: {
                updates in

                XCTAssertTrue(updates.modifications.count == 1)
                XCTAssertTrue(updates.values.contains(testModel3))
                expectation.fulfill()
                self.token?.invalidate()
            })
        }
        wait(for: [expectation], timeout: 1)
    }
}