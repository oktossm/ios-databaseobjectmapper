import XCTest
import RealmSwift
import DatabaseObjectsMapper
@testable import DatabaseObjectsMapper_Example


class CustomRealmContainerTests: XCTestCase {

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
        service.deleteAll()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSimpleStoreWithKey() {
        let testModel = TestSubModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2)

        service.store(object: testModel)
        service.store(object: testModel)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let fetched = self.service.syncFetch(objectOf: TestSubModel.self, withPrimaryKey: testModel.primaryKey)
            let all = self.service.syncFetch(objectsOf: TestSubModel.self)

            XCTAssertTrue(all.count == 1)
            XCTAssertTrue(testModel == fetched)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testMultipleStoreWithKey() {
        let testModel = TestSubModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2)
        let testModel2 = TestSubModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2)

        service.store(objects: [testModel, testModel2])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let all = self.service.syncFetch(objectsOf: TestSubModel.self)

            XCTAssertTrue(all.sorted { $0.userId < $1.userId } == [testModel, testModel2])

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testMultipleUpdate() {
        let testModel = TestSubModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2)
        let testModel2 = TestSubModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2)
        let testModel3 = TestSubModel(userId: 1, userName: "rt", userAvatar: "ab", title: "po", count: 3)
        let testModel4 = TestSubModel(userId: 2, userName: "ki", userAvatar: "ad", title: "pl", count: 3)

        service.store(objects: [testModel, testModel2])
        service.update(objects: [testModel3, testModel4])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let all = self.service.syncFetch(objectsOf: TestSubModel.self)

            XCTAssertTrue(all.sorted { $0.userId < $1.userId } == [testModel3, testModel4])

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testUpdateByKey() {
        let testModel = TestSubModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2)
        let testModel2 = TestSubModel(userId: 1, userName: "rt", userAvatar: "ab", title: "po", count: 3)

        service.store(objects: [testModel])
        service.update(objectOf: TestSubModel.self, withPrimaryKey: testModel.primaryKey, updates: testModel2.allUpdates())


        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let all = self.service.syncFetch(objectsOf: TestSubModel.self)

            XCTAssertTrue(all == [testModel2])

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testDelete() {
        let testModel = TestSubModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2)
        let testModel2 = TestSubModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2)

        service.store(objects: [testModel, testModel2])
        service.delete(objects: [testModel])
        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let all = self.service.syncFetch(objectsOf: TestSubModel.self)

            XCTAssertTrue(all == [testModel2])

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testPrimaryKeyFetch() {
        let testModel = TestSubModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2)

        service.store(object: testModel)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.service.fetch(objectOf: TestSubModel.self, withPrimaryKey: testModel.primaryKey) {
                model in

                XCTAssertTrue(testModel == model)

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testFetch() {
        let testModel = TestSubModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2)
        let testModel2 = TestSubModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2)

        service.store(object: testModel)
        service.store(object: testModel2)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.service.fetch(objectsOf: TestSubModel.self) {
                all in

                XCTAssertTrue(all.sorted { $0.userId < $1.userId } == [testModel, testModel2])
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testFetchUpdate() {
        let testModel = TestSubModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2)

        service.store(object: testModel)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let token = self.service.fetch(objectOf: TestSubModel.self, withPrimaryKey: testModel.primaryKey, callback: {
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

            self.service.update(objectOf: TestSubModel.self, withPrimaryKey: testModel.primaryKey, updates: [TestSubModel.Updates.count(5)])

            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                token.invalidate()
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testFetchDelete() {
        let testModel = TestSubModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2)

        service.store(object: testModel)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let token = self.service.fetch(objectOf: TestSubModel.self, withPrimaryKey: testModel.primaryKey, callback: {
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
        let testModel = TestSubModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2)
        let testModel2 = TestSubModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2)

        service.store(objects: [testModel])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            var token: DatabaseUpdatesToken?
            token = self.service.fetch(objectsOf: TestSubModel.self, with: .unfiltered, with: .unsorted, callback: {
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
        let testModel = TestSubModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2)
        let testModel2 = TestSubModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2)

        service.store(objects: [testModel, testModel2])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            var token: DatabaseUpdatesToken?
            token = self.service.fetch(objectsOf: TestSubModel.self, with: .unfiltered, with: .unsorted, callback: {
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
        let testModel = TestSubModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2)
        let testModel2 = TestSubModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2)

        service.store(objects: [testModel, testModel2])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let testModel3 = TestSubModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 5)
            var token: DatabaseUpdatesToken?
            token = self.service.fetch(objectsOf: TestSubModel.self, with: .unfiltered, with: .unsorted, callback: {
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
