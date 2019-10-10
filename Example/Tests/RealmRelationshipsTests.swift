import XCTest
import RealmSwift
import DatabaseObjectsMapper
@testable import DatabaseObjectsMapper_Example


class RealmRelationshipsTests: XCTestCase {

    var service: RealmService!


    override func setUp() {
        super.setUp()

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

        service = RealmService()
        service.deleteAll(sync: true)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSimpleRelationship() {
        let subModel = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)
        let testModel = TestRRModel(id: 1, name: "ll", owner: subModel)

        service.save(models: [testModel])

        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

            self.service.fetch() {
                (all: [TestRRModel]) in

                XCTAssertTrue(all == [testModel])
                expectation.fulfill()
            }

            self.service.fetch() {
                (all: [TestSomeModel]) in

                XCTAssertTrue(all == [subModel])
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testToManyRelationship() {
        let subModel = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)
        let testModel = TestRRModel(id: 1, name: "ll", owner: nil)

        service.save(model: subModel, update: true, relation: subModel.directModels, with: .setModels(models: [testModel]))

        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 3

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

            self.service.fetch() {
                (all: [TestRRModel]) in

                XCTAssertTrue(all == [testModel])
                expectation.fulfill()
            }

            self.service.fetch() {
                (all: [TestSomeModel]) in

                XCTAssertTrue(all == [subModel])
                expectation.fulfill()
            }

            self.service.fetchRelation(subModel.directModels, in: subModel, with: .unfiltered, sorted: .unsorted) {
                (all: [TestRRModel]) in

                XCTAssertTrue(all == [testModel])
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testFetchToManyRelationship() {
        let subModel = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)
        let testModel1 = TestRRModel(id: 1, name: "ll", owner: nil)
        let testModel2 = TestRRModel(id: 2, name: "dd", owner: nil)
        let testModel3 = TestRRModel(id: 3, name: "kk", owner: nil)
        let testModel4 = TestRRModel(id: 4, name: "kk", owner: nil)

        service.save(model: subModel,
                     update: true,
                     relation: subModel.directModels,
                     with: .setModels(models: [testModel1, testModel2, testModel3, testModel4]))

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

            let models = self.service.syncFetchRelation(subModel.directModels, in: subModel, predicate: \TestRRModel.id == 2)
            XCTAssertTrue(models == [testModel2])

            let models2 = self.service.syncFetchRelation(subModel.directModels,
                                                         in: subModel,
                                                         predicate: \TestRRModel.name == "kk",
                                                         sorted: [SortDescriptor(\TestRRModel.id, ascending: true)])
            XCTAssertTrue(models2 == [testModel3, testModel4])

            self.service.fetchRelation(subModel.directModels, in: subModel, predicate: \TestRRModel.id < 3) {
                (all: [TestRRModel]) in
                XCTAssertTrue(all == [testModel1, testModel2])
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testAddRelationship() {
        let subModel = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)
        let testModel = TestRRModel(id: 1, name: "ll", owner: nil)

        service.save(models: [testModel])
        service.update(modelOf: TestRRModel.self,
                       with: testModel.id,
                       updates: [TestRRModel.Updates.owner(subModel)].dictionaryRepresentation())
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

            self.service.fetch() {
                (all: [TestRRModel]) in

                XCTAssertTrue(all == [testModel.updated([TestRRModel.Updates.owner(subModel)])])
                expectation.fulfill()
            }

            self.service.fetch() {
                (all: [TestSomeModel]) in

                XCTAssertTrue(all == [subModel])
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testAddExistingRelationship() {
        let subModel = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)
        let testModel = TestRRModel(id: 1, name: "ll", owner: nil)

        service.save(models: [testModel])
        service.save(models: [subModel])

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.service.update(modelOf: TestRRModel.self,
                                with: testModel.id,
                                updates: [TestRRModel.Updates.owner(subModel)].dictionaryRepresentation())
        }

        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

            self.service.fetch() {
                (all: [TestRRModel]) in

                XCTAssertTrue(all == [testModel.updated([TestRRModel.Updates.owner(subModel)])])
                expectation.fulfill()
            }

            self.service.fetch() {
                (all: [TestSomeModel]) in

                XCTAssertTrue(all == [subModel])
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testAddToManyRelationship() {
        let subModel = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)
        let testModel = TestRRModel(id: 1, name: "ll", owner: nil)

        service.save(models: [subModel])
        service.updateRelation(subModel.directModels, in: subModel, with: .addModels(models: [testModel]))
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 3

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

            self.service.fetch() {
                (all: [TestRRModel]) in

                XCTAssertTrue(all == [testModel])
                expectation.fulfill()
            }

            self.service.fetch() {
                (all: [TestSomeModel]) in

                XCTAssertTrue(all == [subModel])
                expectation.fulfill()
            }

            self.service.fetchRelation(subModel.directModels, in: subModel, with: .unfiltered, sorted: .unsorted) {
                (all: [TestRRModel]) in

                XCTAssertTrue(all == [testModel])
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testAddToManyRelationshipWithKeys() {
        let subModel = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)
        let testModel = TestRRModel(id: 1, name: "ll", owner: nil)

        service.save(models: [subModel])
        service.save(models: [testModel])
        service.updateRelation(subModel.directModels, in: subModel, with: .add(keys: [testModel.id]))
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 3

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

            self.service.fetch() {
                (all: [TestRRModel]) in

                XCTAssertTrue(all == [testModel])
                expectation.fulfill()
            }

            self.service.fetch() {
                (all: [TestSomeModel]) in

                XCTAssertTrue(all == [subModel])
                expectation.fulfill()
            }

            self.service.fetchRelation(subModel.directModels, in: subModel, with: .unfiltered, sorted: .unsorted) {
                (all: [TestRRModel]) in

                XCTAssertTrue(all == [testModel])
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testRemoveSimpleRelationship() {
        let subModel = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)
        let testModel = TestRRModel(id: 1, name: "ll", owner: subModel)

        service.save(models: [testModel])
        service.update(modelOf: TestRRModel.self,
                       with: testModel.id,
                       updates: [TestRRModel.Updates.owner(nil)].dictionaryRepresentation())
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

            self.service.fetch() {
                (all: [TestRRModel]) in

                XCTAssertTrue(all == [testModel.ownerLens.set(nil)])
                expectation.fulfill()
            }

            self.service.fetch() {
                (all: [TestSomeModel]) in

                XCTAssertTrue(all == [subModel])
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testRemoveRelationshipWithUpdate() {
        let subModel = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)
        let testModel = TestRRModel(id: 1, name: "ll", owner: subModel)

        service.save(model: testModel)
        service.update(model: testModel.ownerLens.set(nil))
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

            self.service.fetch() {
                (all: [TestRRModel]) in

                XCTAssertTrue(all == [testModel.ownerLens.set(nil)])
                expectation.fulfill()
            }

            self.service.fetch() {
                (all: [TestSomeModel]) in

                XCTAssertTrue(all == [subModel])
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testSkipRelationshipsUpdate() {
        let subModel = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)
        let testModel = TestRRModel(id: 1, name: "ll", owner: subModel)

        service.save(model: testModel)
        service.update(model: testModel.ownerLens.set(nil), skipRelations: true)
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

            self.service.fetch() {
                (all: [TestRRModel]) in

                XCTAssertTrue(all == [testModel])
                expectation.fulfill()
            }

            self.service.fetch() {
                (all: [TestSomeModel]) in

                XCTAssertTrue(all == [subModel])
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testSkipRelationshipsSave() {
        let subModel = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)
        let testModel = TestRRModel(id: 1, name: "ll", owner: subModel)

        service.saveSkippingRelations(model: testModel)
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

            self.service.fetch() {
                (all: [TestRRModel]) in

                XCTAssertTrue(all == [testModel.ownerLens.set(nil)])
                expectation.fulfill()
            }

            self.service.fetch() {
                (all: [TestSomeModel]) in

                XCTAssertTrue(all == [])
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testSkipRelationshipsSavingExisting() {
        let subModel = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)
        let testModel = TestRRModel(id: 1, name: "ll", owner: subModel)

        service.save(model: testModel)
        service.saveSkippingRelations(model: testModel.ownerLens.set(nil))
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

            self.service.fetch() {
                (all: [TestRRModel]) in

                XCTAssertTrue(all == [testModel])
                expectation.fulfill()
            }

            self.service.fetch() {
                (all: [TestSomeModel]) in

                XCTAssertTrue(all == [subModel])
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testRemoveToManyRelationship() {
        let subModel = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)
        let testModel = TestRRModel(id: 1, name: "ll", owner: nil)

        service.save(model: subModel, update: true, relation: subModel.directModels, with: .setModels(models: [testModel]))
        service.updateRelation(subModel.directModels, in: subModel, with: .remove(keys: [testModel.id]))

        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 3

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

            self.service.fetch() {
                (all: [TestRRModel]) in

                XCTAssertTrue(all == [testModel])
                expectation.fulfill()
            }

            self.service.fetch() {
                (all: [TestSomeModel]) in

                XCTAssertTrue(all == [subModel])
                expectation.fulfill()
            }

            self.service.fetchRelation(subModel.directModels, in: subModel, with: .unfiltered, sorted: .unsorted) {
                (all: [TestRRModel]) in

                XCTAssertTrue(all == [])
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }


    func testInverseRelationship() {
        let subModel = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)
        let testModel = TestRRModel(id: 1, name: "ll", owner: subModel)

        service.save(models: [testModel])

        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

            self.service.fetchRelation(subModel.inverseModel,
                                       in: subModel,
                                       with: .unfiltered,
                                       sorted: .unsorted) {
                (all: [TestRRModel]) in
                XCTAssertTrue(all == [testModel])
                expectation.fulfill()
            }

            self.service.fetch() {
                (all: [TestRRModel]) in

                XCTAssertTrue(all == [testModel])
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testFetchWithLimit() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 1, nestedModel: nil)
        let testModel1 = TestRRModel(id: 1, name: "la", owner: nil)
        let testModel2 = TestRRModel(id: 2, name: "lb", owner: nil)
        let testModel3 = TestRRModel(id: 3, name: "lc", owner: nil)

        service.save(models: [testModel])
        service.updateRelation(testModel.directModels, in: testModel, with: .addModels(models: [testModel1, testModel2, testModel3]))

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.service.fetchRelation(testModel.directModels,
                                       in: testModel,
                                       with: .unfiltered,
                                       sorted: .byKeyPath(keyPath: "name", ascending: true),
                                       limit: 2) {
                (fetched: [TestRRModel]) in
                XCTAssertTrue(fetched == [testModel1, testModel2])
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testSyncFetchWithLimit() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 1, nestedModel: nil)
        let testModel1 = TestRRModel(id: 1, name: "la", owner: nil)
        let testModel2 = TestRRModel(id: 2, name: "lb", owner: nil)
        let testModel3 = TestRRModel(id: 3, name: "lc", owner: nil)

        service.save(models: [testModel])
        service.updateRelation(testModel.directModels, in: testModel, with: .addModels(models: [testModel1, testModel2, testModel3]))

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let fetched: [TestRRModel] = self.service.syncFetchRelation(testModel.directModels,
                                                                        in: testModel,
                                                                        with: .unfiltered,
                                                                        sorted: .byKeyPath(keyPath: "name", ascending: true),
                                                                        limit: 2)
            XCTAssertTrue(fetched == [testModel1, testModel2])
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testAddWithUpdate() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 1, nestedModel: nil)
        let testModel1 = TestRRModel(id: 1, name: "la", owner: nil)
        let testModel2 = TestRRModel(id: 2, name: "lb", owner: nil)
        let testModel3 = TestRRModel(id: 3, name: "lc", owner: nil)
        let testModel4 = TestRRModel(id: 4, name: "ld", owner: nil)

        service.save(models: [testModel])
        service.updateRelation(testModel.directModels, in: testModel, with: .addModels(models: [testModel1, testModel2, testModel3]))

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            var token: DatabaseUpdatesToken?
            token = self.service.fetchRelation(
                testModel.directModels,
                in: testModel,
                sorted: .byKeyPath(keyPath: "name", ascending: true),
                limit: nil,
                callback: {
                    (fetched: [TestRRModel]) in
                    XCTAssertTrue(fetched == [testModel1, testModel2, testModel3])
                },
                updates: {
                    (update: DatabaseObserveUpdate<TestRRModel>) in
                    token?.invalidate()
                    XCTAssertTrue(update.values == [testModel1, testModel2, testModel3, testModel4])
                    expectation.fulfill()
                })

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.service.updateRelation(testModel.directModels, in: testModel, with: .addModels(models: [testModel4]))
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testDeleteMainModel() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 1, nestedModel: nil)
        let testModel1 = TestRRModel(id: 1, name: "la", owner: nil)
        let testModel2 = TestRRModel(id: 2, name: "lb", owner: nil)
        let testModel3 = TestRRModel(id: 3, name: "lc", owner: nil)

        service.save(models: [testModel])
        service.updateRelation(testModel.directModels, in: testModel, with: .addModels(models: [testModel1, testModel2, testModel3]))

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            var token: DatabaseUpdatesToken?
            token = self.service.fetchRelation(
                testModel.directModels,
                in: testModel,
                sorted: .byKeyPath(keyPath: "name", ascending: true),
                limit: nil,
                callback: {
                    (fetched: [TestRRModel]) in
                    XCTAssertTrue(fetched == [testModel1, testModel2, testModel3])
                },
                updates: {
                    (update: DatabaseObserveUpdate<TestRRModel>) in
                    token?.invalidate()
                    XCTAssertTrue(update.values == [])
                    expectation.fulfill()
                })

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.service.delete(model: testModel)
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testFetchWithLimitUpdate() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 1, nestedModel: nil)
        let testModel1 = TestRRModel(id: 1, name: "la", owner: nil)
        let testModel2 = TestRRModel(id: 2, name: "lb", owner: nil)
        let testModel3 = TestRRModel(id: 3, name: "lc", owner: nil)
        let testModel4 = TestRRModel(id: 4, name: "ld", owner: nil)

        service.save(models: [testModel])
        service.updateRelation(testModel.directModels, in: testModel, with: .addModels(models: [testModel1, testModel2, testModel3, testModel4]))

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            var token: DatabaseUpdatesToken?
            token = self.service.fetchRelation(
                testModel.directModels,
                in: testModel,
                sorted: .byKeyPath(keyPath: "name", ascending: true),
                limit: 2,
                callback: {
                    (fetched: [TestRRModel]) in
                    XCTAssertTrue(fetched == [testModel1, testModel2])
                },
                updates: {
                    (update: DatabaseObserveUpdate<TestRRModel>) in
                    token?.invalidate()
                    XCTAssertTrue(token?.limit == 3)
                    XCTAssertTrue(update.values == [testModel1, testModel2, testModel3])
                    expectation.fulfill()
                })

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                token?.limit = 3
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testLoadNext() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 1, nestedModel: nil)
        let testModel1 = TestRRModel(id: 1, name: "la", owner: nil)
        let testModel2 = TestRRModel(id: 2, name: "lb", owner: nil)
        let testModel3 = TestRRModel(id: 3, name: "lc", owner: nil)
        let testModel4 = TestRRModel(id: 4, name: "ld", owner: nil)

        service.save(models: [testModel])
        service.updateRelation(testModel.directModels, in: testModel, with: .addModels(models: [testModel1, testModel2, testModel3, testModel4]))

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            var token: DatabaseUpdatesToken?
            token = self.service.fetchRelation(
                testModel.directModels,
                in: testModel,
                sorted: .byKeyPath(keyPath: "name", ascending: true),
                limit: 2,
                callback: {
                    (fetched: [TestRRModel]) in
                    XCTAssertTrue(fetched == [testModel1, testModel2])
                },
                next: {
                    (fetched: [TestRRModel], isLast: Bool) in
                    token?.invalidate()
                    XCTAssertTrue(token?.limit == 4)
                    XCTAssertTrue(isLast)
                    XCTAssertTrue(fetched == [testModel3, testModel4])
                    expectation.fulfill()
                },
                updates: {
                    (update: DatabaseObserveUpdate<TestRRModel>) in
                    token?.invalidate()
                    XCTAssertTrue(token?.limit == 3)
                    XCTAssertTrue(update.values == [testModel1, testModel2, testModel3])
                    expectation.fulfill()
                })

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                token?.loadNext(2)
            }
        }

        wait(for: [expectation], timeout: 1)
    }
}
