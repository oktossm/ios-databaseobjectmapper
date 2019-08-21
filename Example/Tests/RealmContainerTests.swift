import XCTest
import RealmSwift
import DatabaseObjectsMapper
@testable import DatabaseObjectsMapper_Example


class RealmContainerTests: XCTestCase {

    lazy var service: RealmService = {
        let config = Realm.Configuration(
                // Set the new schema version. This must be greater than the previously used
                // version (if you've never set a schema version before, the version is 0).
                schemaVersion: 1,

                // Set the block which will be called automatically when opening a Realm with
                // a schema version lower than the one set above
                migrationBlock: {
                    _, oldSchemaVersion in
                    // We haven’t migrated anything yet, so oldSchemaVersion == 0
                    if oldSchemaVersion < 3 {
                        // Nothing to do!
                        // Realm will automatically detect new properties and removed properties
                        // And will update the schema on disk automatically
                    }
                },
                deleteRealmIfMigrationNeeded: true)

        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config

        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        // swiftlint:disable force_try
        let _ = try! Realm()
        // swiftlint:enable force_try

        return RealmService()
    }()

    var token: DatabaseUpdatesToken?

    override func setUp() {
        super.setUp()
        service.deleteAll(sync: true)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSimpleStoreWithKey() {
        let testModel = TestModel(id: 1, index: 3, name: "fr", count: 3, someCount: 4, urls: nil, someModel: nil)

        service.save(model: testModel)
        service.save(model: testModel)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let fetched: TestModel? = self.service.syncFetchUnique(with: 1)
            let all: [TestModel] = self.service.syncFetch()

            XCTAssertTrue(all.count == 1)
            XCTAssertTrue(testModel == fetched)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testSimpleStoreWithoutKey() {
        let model = TestSimpleModel(title: "count", count: 3)

        service.simpleSave(model: model)
        service.simpleSave(model: model)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let fetched: [TestSimpleModel] = self.service.syncFetch()

            XCTAssertTrue(fetched.count == 2)
            XCTAssertTrue(fetched.contains { $0 != model } == false, "\(fetched)")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testSimpleUpdate() {
        let testModel = TestModel(id: 1, index: 2, name: "fr", count: 8, someCount: 9, urls: nil, someModel: nil)
        let testModel2 = TestModel(id: 1, index: 3, name: "pr", count: 2, someCount: 2, urls: nil, someModel: nil)

        service.save(model: testModel)
        service.update(model: testModel2)
        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let fetched: TestModel? = self.service.syncFetchUnique(with: 1)

            XCTAssertTrue(testModel2 == fetched)
            XCTAssertTrue(testModel != fetched, "\(fetched!)")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testMultipleStoreWithKey() {
        let testModel = TestModel(id: 1, index: 3, name: "fr", count: 3, someCount: 4, urls: nil, someModel: nil)
        let testModel2 = TestModel(id: 2, index: 2, name: "pr", count: 3, someCount: 8, urls: nil, someModel: nil)

        service.save(models: [testModel, testModel2])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let all: [TestModel] = self.service.syncFetch()

            XCTAssertTrue(all.sorted { $0.id < $1.id } == [testModel, testModel2])

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testMultipleUpdate() {
        let testModel = TestModel(id: 1, index: 3, name: "fr", count: 3, someCount: 4, urls: nil, someModel: nil)
        let testModel2 = TestModel(id: 2, index: 2, name: "pr", count: 3, someCount: 8, urls: nil, someModel: nil)
        let testModel3 = TestModel(id: 1, index: 1, name: "fr", count: 2, someCount: 2, urls: nil, someModel: nil)
        let testModel4 = TestModel(id: 2, index: 7, name: "pr", count: 9, someCount: 1, urls: nil, someModel: nil)

        service.save(models: [testModel, testModel2])
        service.update(models: [testModel3, testModel4])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let all: [TestModel] = self.service.syncFetch()

            XCTAssertTrue(all.sorted { $0.id < $1.id } == [testModel3, testModel4], "\(all)")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testUpdateByKey() {
        let testModel = TestModel(id: 1, index: 3, name: "fr", count: 3, someCount: 4, urls: nil, someModel: nil)
        let testModel2 = TestModel(id: 1, index: 1, name: "fr", count: 2, someCount: 2, urls: nil, someModel: nil)

        service.save(models: [testModel])
        service.update(modelOf: TestModel.self, with: testModel.id, updates: testModel2.allUpdates().dictionaryRepresentation())


        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let all: [TestModel] = self.service.syncFetch()

            XCTAssertTrue(all == [testModel2], "\(all)")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testPartialUpdate() {
        let testModel = TestModel(id: 1, index: 3, name: "fr", count: 3, someCount: 4, urls: nil, someModel: nil)
        let testModel2 = TestModel(id: 1, index: nil, name: "l", count: 2, someCount: 2, urls: nil, someModel: nil)

        service.save(models: [testModel])
        service.update(modelOf: TestModel.self, with: testModel.id, updates: testModel2.difference(from: testModel).dictionaryRepresentation())

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let all: [TestModel] = self.service.syncFetch()

            XCTAssertTrue(all == [testModel2], "\(all)")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testDelete() {
        let testModel = TestModel(id: 1, index: 3, name: "fr", count: 3, someCount: 4, urls: nil, someModel: nil)
        let testModel2 = TestModel(id: 2, index: 2, name: "pr", count: 3, someCount: 8, urls: nil, someModel: nil)

        service.save(models: [testModel, testModel2])
        service.delete(models: [testModel])
        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let all: [TestModel] = self.service.syncFetch()

            XCTAssertTrue(all == [testModel2], "\(all)")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testPrimaryKeyFetch() {
        let testModel = TestModel(id: 1, index: 3, name: "fr", count: 3, someCount: 4, urls: nil, someModel: nil)

        service.save(model: testModel)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.service.fetchUnique(with: testModel.id) {
                (model: TestModel?) in

                XCTAssertTrue(testModel == model, "\(model != nil)")

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testFetch() {
        let testModel = TestModel(id: 1, index: 3, name: "fr", count: 3, someCount: 4, urls: nil, someModel: nil)
        let testModel2 = TestModel(id: 2, index: 2, name: "pr", count: 3, someCount: 8, urls: nil, someModel: nil)

        service.save(model: testModel)
        service.save(model: testModel2)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.service.fetch() {
                (all: [TestModel]) in

                XCTAssertTrue(all.sorted { $0.id < $1.id } == [testModel, testModel2], "\(all)")
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testFetchUpdate() {
        let testModel = TestModel(id: 1, index: 3, name: "fr", count: 3, someCount: 4, urls: nil, someModel: nil)

        service.save(model: testModel)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.token = self.service.fetch(with: testModel.id, callback: {
                (_: TestModel?) in
                self.service.update(modelOf: TestModel.self, with: testModel.id, updates: [TestModel.Updates.count(5)].dictionaryRepresentation())
            }, updates: {
                update in

                switch update {
                case .update(let newModel):
                    XCTAssertTrue(newModel.count == 5, "\(newModel)")
                case .delete:
                    XCTFail("\(update)")
                }
                expectation.fulfill()
                self.token?.invalidate()
            })
        }
        wait(for: [expectation], timeout: 1)
    }

    func testFetchDelete() {
        let testModel = TestModel(id: 1, index: 3, name: "fr", count: 3, someCount: 4, urls: nil, someModel: nil)

        service.save(model: testModel)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.token = self.service.fetch(with: testModel.id, callback: {
                (_: TestModel?) in
                self.service.delete(model: testModel)
            }, updates: {
                update in

                switch update {
                case .update:
                    XCTFail()
                case .delete:
                    XCTAssertTrue(true, "\(update)")
                }
                expectation.fulfill()
                self.token?.invalidate()
            })
        }
        wait(for: [expectation], timeout: 1)
    }

    func testMultipleFetchInsert() {
        let testModel = TestModel(id: 1, index: 3, name: "fr", count: 3, someCount: 4, urls: nil, someModel: nil)
        let testModel2 = TestModel(id: 2, index: 2, name: "pr", count: 3, someCount: 8, urls: nil, someModel: nil)

        service.save(models: [testModel])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.token = self.service.fetch(with: .unfiltered, sorted: .unsorted, callback: {
                (_: [TestModel]) in
                self.service.save(models: [testModel2])
            }, updates: {
                updates in

                XCTAssertTrue(updates.insertions.count == 1, "\(updates)")
                expectation.fulfill()
                self.token?.invalidate()
            })
        }
        wait(for: [expectation], timeout: 1)
    }

    func testMultipleFetchDelete() {
        let testModel = TestModel(id: 1, index: 3, name: "fr", count: 3, someCount: 4, urls: nil, someModel: nil)
        let testModel2 = TestModel(id: 2, index: 2, name: "pr", count: 3, someCount: 8, urls: nil, someModel: nil)

        service.save(models: [testModel, testModel2])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.token = self.service.fetch(with: .unfiltered, sorted: .unsorted, callback: {
                (_: [TestModel]) in
                self.service.delete(model: testModel2)
            }, updates: {
                updates in

                if updates.insertions.isEmpty {
                    XCTAssertTrue(updates.deletions.count == 1, "\(updates)")
                    expectation.fulfill()
                }
                self.token?.invalidate()
            })
        }
        wait(for: [expectation], timeout: 1)
    }

    func testMultipleFetchUpdate() {
        let testModel = TestModel(id: 1, index: 3, name: "fr", count: 3, someCount: 4, urls: nil, someModel: nil)
        let testModel2 = TestModel(id: 2, index: 2, name: "pr", count: 3, someCount: 8, urls: nil, someModel: nil)

        service.save(models: [testModel, testModel2])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

            let testModel3 = TestModel(id: 2, index: 2, name: "pr", count: 2, someCount: 8, urls: nil, someModel: nil)
            self.token = self.service.fetch(with: .unfiltered, sorted: .unsorted, callback: {
                (models: [TestModel]) in
                self.service.update(model: testModel3)
            }, updates: {
                updates in

                XCTAssertTrue(updates.modifications.count == 1)
                XCTAssertTrue(updates.values.contains(testModel3), "\(updates)")
                expectation.fulfill()
                self.token?.invalidate()
            })
        }
        wait(for: [expectation], timeout: 1)
    }
}
