import XCTest
import RealmSwift
import DatabaseObjectsMapper
@testable import DatabaseObjectsMapper_Example


class CustomRealmContainerTests: XCTestCase {

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
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)

        service.save(model: testModel)
        service.save(model: testModel)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let fetched: TestSomeModel? = self.service.syncFetchUnique(with: testModel.userId)
            let all: [TestSomeModel] = self.service.syncFetch()

            XCTAssertTrue(all.count == 1)
            XCTAssertTrue(testModel == fetched)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testSyncStoreWithKey() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)

        service.save(model: testModel, sync: true)
        //Test duplicate
        service.save(model: testModel, sync: true)

        let fetched: TestSomeModel? = self.service.syncFetchUnique(with: testModel.userId)
        let all: [TestSomeModel] = self.service.syncFetch()

        XCTAssertTrue(all.count == 1)
        XCTAssertTrue(testModel == fetched)
    }


    func testMultipleStoreWithKey() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)

        service.save(models: [testModel, testModel2])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let all: [TestSomeModel] = self.service.syncFetch()

            XCTAssertTrue(all.sorted { $0.userId < $1.userId } == [testModel, testModel2])

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testMultipleUpdate() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)
        let testModel3 = TestSomeModel(userId: 1, userName: "rt", userAvatar: "ab", title: "po", count: 3, nestedModel: nil)
        let testModel4 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "ad", title: "pl", count: 3, nestedModel: nil)

        service.save(models: [testModel, testModel2])
        service.update(models: [testModel3, testModel4])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let all: [TestSomeModel] = self.service.syncFetch()

            XCTAssertTrue(all.sorted { $0.userId < $1.userId } == [testModel3, testModel4])

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testMultipleUpdateSync() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)
        let testModel3 = TestSomeModel(userId: 1, userName: "rt", userAvatar: "ab", title: "po", count: 3, nestedModel: nil)
        let testModel4 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "ad", title: "pl", count: 3, nestedModel: nil)

        service.save(models: [testModel, testModel2], sync: true)
        service.update(models: [testModel3, testModel4], sync: true)

        let all: [TestSomeModel] = self.service.syncFetch()

        XCTAssertTrue(all.sorted { $0.userId < $1.userId } == [testModel3, testModel4])
    }

    func testUpdateByKey() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 1, userName: "rt", userAvatar: "ab", title: "po", count: 3, nestedModel: nil)

        service.save(models: [testModel])
        service.update(modelOf: TestSomeModel.self, with: testModel.userId, updates: testModel2.encodedValue)


        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let all: [TestSomeModel] = self.service.syncFetch()

            XCTAssertTrue(all == [testModel2])

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testUpdateByKeySync() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 1, userName: "rt", userAvatar: "ab", title: "po", count: 3, nestedModel: nil)

        service.save(models: [testModel], sync: true)
        service.update(modelOf: TestSomeModel.self, with: testModel.userId, updates: testModel2.encodedValue, sync: true)

        let all: [TestSomeModel] = self.service.syncFetch()

        XCTAssertTrue(all == [testModel2])
    }

    func testPartialUpdate() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 1, userName: "rt", userAvatar: "ab", title: nil, count: 3, nestedModel: nil)

        service.save(models: [testModel])
        service.update(modelOf: TestSomeModel.self,
                       with: testModel.userId,
                       updates: testModel2.difference(from: testModel).dictionaryRepresentation())

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let all: [TestSomeModel] = self.service.syncFetch()

            XCTAssertTrue(all == [testModel2], "\(all)")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testPartialUpdateSync() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 1, userName: "rt", userAvatar: "ab", title: nil, count: 3, nestedModel: nil)

        service.save(models: [testModel], sync: true)
        service.update(modelOf: TestSomeModel.self,
                       with: testModel.userId,
                       updates: testModel2.difference(from: testModel).dictionaryRepresentation(),
                       sync: true)

        let all: [TestSomeModel] = self.service.syncFetch()

        XCTAssertTrue(all == [testModel2], "\(all)")
    }

    func testTypeSafeUpdate() {
        let nestedModel = TestSomeModel.TestNestedModel(title: "title", count: 9)

        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 1, userName: "rt", userAvatar: "ab", title: nil, count: 3, nestedModel: nestedModel)

        service.save(models: [testModel])
        service.update(modelOf: TestSomeModel.self,
                       with: testModel.userId,
                       updates: [\TestSomeModel.count <- 3,
                                 \TestSomeModel.userAvatar <- "ab",
                                 \TestSomeModel.title <- nil,
                                 \TestSomeModel.nestedModel <- nestedModel])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let all: [TestSomeModel] = self.service.syncFetch()

            XCTAssertTrue(all == [testModel2], "\(all)")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testDelete() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)

        service.save(models: [testModel, testModel2])
        service.delete(models: [testModel])
        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let all: [TestSomeModel] = self.service.syncFetch()

            XCTAssertTrue(all == [testModel2])

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testDeleteSync() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)

        service.save(models: [testModel, testModel2], sync: true)
        service.delete(models: [testModel], sync: true)

        let all: [TestSomeModel] = self.service.syncFetch()

        XCTAssertTrue(all == [testModel2])
    }

    func testPrimaryKeyFetch() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)

        service.save(model: testModel)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.service.fetchUnique(with: testModel.userId) {
                (model: TestSomeModel?) in

                XCTAssertTrue(testModel == model)

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testPrimaryKeyFetchDelete() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)

        service.save(model: testModel)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let token = self.service.fetchUnique(with: testModel.userId, callback: {
                (model: TestSomeModel?) in
                XCTAssertTrue(testModel == model)
            }, updates: {
                update in

                switch update {
                case .update:
                    XCTFail()
                case .delete:
                    expectation.fulfill()
                }
            })

            self.service.delete(model: testModel)

            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                token.invalidate()
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testPrimaryKeyFetchSync() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)

        service.save(model: testModel, sync: true)

        let model: TestSomeModel? = self.service.syncFetchUnique(with: testModel.userId)

        XCTAssertTrue(testModel == model)
    }

    func testFetch() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)

        service.save(model: testModel)
        service.save(model: testModel2)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.service.fetch() {
                (all: [TestSomeModel]) in

                XCTAssertTrue(all.sorted { $0.userId < $1.userId } == [testModel, testModel2])
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testFetchWithPredicate() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)

        service.save(model: testModel)
        service.save(model: testModel2)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let models: [TestSomeModel] = self.service.syncFetch { $0.userName == "rt" }
            XCTAssertTrue(models == [testModel])
            let models2: [TestSomeModel] = self.service.syncFetch { $0.userId > 1 }
            XCTAssertTrue(models2 == [testModel2])
            let models3: [TestSomeModel] = self.service.syncFetch { $0.title != "pl" }
            XCTAssertTrue(models3 == [testModel])
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testFetchWithComplexPredicate() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)
        let testModel3 = TestSomeModel(userId: 3, userName: "g", userAvatar: "op", title: "kl", count: 1, nestedModel: nil)

        service.save(models: [testModel, testModel2, testModel3])

        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.service.fetch({ $0.userName == "rt" && $0.count == 2 }) {
                (all: [TestSomeModel]) in

                XCTAssertTrue(all == [testModel])
                expectation.fulfill()
            }
            self.service.fetch({ $0.userName == "rt" || $0.userAvatar == "rw" }) {
                (all: [TestSomeModel]) in

                XCTAssertTrue(all.count == 2)
                XCTAssertTrue(all.contains(testModel))
                XCTAssertTrue(all.contains(testModel2))
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testFetchWithSort() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 3, nestedModel: nil)
        let testModel3 = TestSomeModel(userId: 3, userName: "ki", userAvatar: "rw", title: "pl", count: 1, nestedModel: nil)

        service.save(models: [testModel, testModel2, testModel3])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let models: [TestSomeModel] = self.service.syncFetch(sorted: [SortDescriptor(\TestSomeModel.count, ascending: false)])
            XCTAssertTrue(models == [testModel2, testModel, testModel3])

            self.service.fetch(with: .unfiltered, sorted: .byKeyPath(keyPath: "userId", ascending: false)) {
                (all: [TestSomeModel]) in

                XCTAssertTrue(all == [testModel3, testModel2, testModel])
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testFetchWithLimit() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 1, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 3, nestedModel: nil)
        let testModel3 = TestSomeModel(userId: 3, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)

        service.save(models: [testModel, testModel2, testModel3])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.service.fetch(with: .unfiltered, sorted: .byKeyPath(keyPath: "count", ascending: false), limit: 2) {
                (fetched: [TestSomeModel]) in
                XCTAssertTrue(fetched == [testModel2, testModel3])
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testSyncFetchWithLimit() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 1, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 3, nestedModel: nil)
        let testModel3 = TestSomeModel(userId: 3, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)

        service.save(models: [testModel, testModel2, testModel3])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let fetched: [TestSomeModel] = self.service.syncFetch(with: .unfiltered, sorted: .byKeyPath(keyPath: "count", ascending: false), limit: 2)
            XCTAssertTrue(fetched == [testModel2, testModel3])
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testFetchWithLimitUpdate() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 1, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 3, nestedModel: nil)
        let testModel3 = TestSomeModel(userId: 3, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)
        let testModel4 = TestSomeModel(userId: 4, userName: "ki", userAvatar: "rw", title: "pl", count: 4, nestedModel: nil)

        service.save(models: [testModel4, testModel, testModel2, testModel3])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            var token: DatabaseUpdatesToken?
            token = self.service.fetch(sorted: .byKeyPath(keyPath: "count", ascending: false), limit: 2, callback: {
                (fetched: [TestSomeModel]) in
                XCTAssertTrue(fetched == [testModel4, testModel2])
            }, updates: {
                (update: DatabaseObserveUpdate<TestSomeModel>) in
                token?.invalidate()
                XCTAssertTrue(token?.limit == 3)
                XCTAssertTrue(update.values == [testModel4, testModel2, testModel3])
                expectation.fulfill()
            })

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                token?.limit = 3
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testDynamicLimitInsertChange() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 1, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 3, nestedModel: nil)
        let testModel3 = TestSomeModel(userId: 3, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)
        let testModel4 = TestSomeModel(userId: 4, userName: "ki", userAvatar: "rw", title: "pl", count: 4, nestedModel: nil)

        service.save(models: [testModel, testModel2, testModel3])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            var token: DatabaseUpdatesToken?
            token = self.service.fetch(sorted: .byKeyPath(keyPath: "count", ascending: false), limit: 2, callback: {
                (fetched: [TestSomeModel]) in
                XCTAssertTrue(fetched == [testModel2, testModel3])
            }, updates: {
                (update: DatabaseObserveUpdate<TestSomeModel>) in
                token?.invalidate()
                XCTAssertTrue(token?.limit == 3)
                XCTAssertTrue(update.values == [testModel4, testModel2, testModel3])
                expectation.fulfill()
            })

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.service.save(model: testModel4)
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testDynamicLimitDeleteChange() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 1, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 3, nestedModel: nil)
        let testModel3 = TestSomeModel(userId: 3, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)
        let testModel4 = TestSomeModel(userId: 4, userName: "ki", userAvatar: "rw", title: "pl", count: 4, nestedModel: nil)

        service.save(models: [testModel4, testModel, testModel2, testModel3])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            var token: DatabaseUpdatesToken?
            token = self.service.fetch(sorted: .byKeyPath(keyPath: "count", ascending: false), limit: 3, callback: {
                (fetched: [TestSomeModel]) in
                XCTAssertTrue(fetched == [testModel4, testModel2, testModel3])
            }, updates: {
                (update: DatabaseObserveUpdate<TestSomeModel>) in
                token?.invalidate()
                XCTAssertTrue(token?.limit == 3)
                XCTAssertTrue(update.values == [testModel2, testModel3, testModel])
                expectation.fulfill()
            })

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.service.delete(model: testModel4)
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testLoadNext() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 1, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 3, nestedModel: nil)
        let testModel3 = TestSomeModel(userId: 3, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)
        let testModel4 = TestSomeModel(userId: 4, userName: "ki", userAvatar: "rw", title: "pl", count: 4, nestedModel: nil)
        let testModel5 = TestSomeModel(userId: 5, userName: "ki", userAvatar: "rw", title: "pl", count: 0, nestedModel: nil)

        service.save(models: [testModel5, testModel4, testModel, testModel2, testModel3])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            var token: DatabaseUpdatesToken?
            token = self.service.fetch(sorted: .byKeyPath(keyPath: "count", ascending: false), limit: 2, callback: {
                (fetched: [TestSomeModel]) in
                XCTAssertTrue(fetched == [testModel4, testModel2])
            }, next: {
                (fetched: [TestSomeModel], isLast: Bool) in
                token?.invalidate()
                XCTAssertTrue(token?.limit == 4)
                XCTAssertTrue(!isLast)
                XCTAssertTrue(fetched == [testModel3, testModel])
                expectation.fulfill()
            }, updates: {
                (update: DatabaseObserveUpdate<TestSomeModel>) in
                XCTFail()
            })

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                token?.loadNext(2)
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testLoadNextIsLast() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 1, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 3, nestedModel: nil)
        let testModel3 = TestSomeModel(userId: 3, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)
        let testModel4 = TestSomeModel(userId: 4, userName: "ki", userAvatar: "rw", title: "pl", count: 4, nestedModel: nil)

        service.save(models: [testModel4, testModel, testModel2, testModel3])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            var token: DatabaseUpdatesToken?
            token = self.service.fetch(sorted: .byKeyPath(keyPath: "count", ascending: false), limit: 2, callback: {
                (fetched: [TestSomeModel]) in
                XCTAssertTrue(fetched == [testModel4, testModel2])
            }, next: {
                (fetched: [TestSomeModel], isLast: Bool) in
                token?.invalidate()
                XCTAssertTrue(token?.limit == 4)
                XCTAssertTrue(isLast)
                XCTAssertTrue(fetched == [testModel3, testModel])
                expectation.fulfill()
            }, updates: {
                (update: DatabaseObserveUpdate<TestSomeModel>) in
                XCTFail()
            })

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                token?.loadNext(2)
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testFetchUpdate() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)

        service.save(model: testModel)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            var token: DatabaseUpdatesToken?
            token = self.service.fetchUnique(with: testModel.userId, callback: {
                (model: TestSomeModel?) in
            }, updates: {
                update in

                token?.invalidate()

                switch update {
                case .update(let newModel):
                    XCTAssertTrue(newModel.count == 5)
                    expectation.fulfill()
                case .delete:
                    XCTFail()
                }
            })

            self.service.update(modelOf: TestSomeModel.self,
                                with: testModel.userId,
                                updates: [TestSomeModel.Updates.count(5)].dictionaryRepresentation())
        }
        wait(for: [expectation], timeout: 1)
    }

    func testFetchDelete() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)

        service.save(model: testModel)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            var token: DatabaseUpdatesToken?
            token = self.service.fetchUnique(with: testModel.userId, callback: {
                (model: TestSomeModel?) in
            }, updates: {
                update in

                token?.invalidate()

                switch update {
                case .update:
                    XCTAssertTrue(false)
                case .delete:
                    XCTAssertTrue(true)
                    expectation.fulfill()
                }
            })

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.service.delete(model: testModel)
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testMultipleFetchInsert() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)

        service.save(models: [testModel])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            var token: DatabaseUpdatesToken?
            token = self.service.fetch(with: .unfiltered, sorted: .unsorted, callback: {
                (models: [TestSomeModel]) in
            }, updates: {
                updates in

                token?.invalidate()

                XCTAssertTrue(updates.insertions.count == 1)
                expectation.fulfill()
            })

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.service.save(models: [testModel2])
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testMultipleFetchDelete() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)

        service.save(models: [testModel, testModel2])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            var token: DatabaseUpdatesToken?
            token = self.service.fetch(with: .unfiltered, sorted: .unsorted, callback: {
                (models: [TestSomeModel]) in
            }, updates: {
                updates in

                token?.invalidate()

                XCTAssertTrue(updates.deletions.count == 1)
                expectation.fulfill()
            })

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.service.delete(model: testModel2)
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testMultipleFetchUpdate() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)

        service.save(models: [testModel, testModel2])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let testModel3 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 5, nestedModel: nil)
            var token: DatabaseUpdatesToken?
            token = self.service.fetch(with: .unfiltered, sorted: .unsorted, callback: {
                (models: [TestSomeModel]) in
            }, updates: {
                updates in

                token?.invalidate()

                XCTAssertTrue(updates.modifications.count == 1)
                XCTAssertTrue(updates.values.contains(testModel3))
                expectation.fulfill()
            })

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.service.update(model: testModel3)
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testSimpleRelationship() {
        let someModel = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)
        let testModel = TestRRModel(id: 1, name: "ll", owner: someModel, user: nil)

        service.save(models: [testModel])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

            self.service.fetch() {
                (all: [TestRRModel]) in

                XCTAssertTrue(all == [testModel])
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testNestedModel() {
        let testModel = TestSomeModel.TestNestedModel(title: "title", count: 9)
        let someModel = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: testModel)

        service.save(models: [someModel])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

            self.service.fetch() {
                (all: [TestSomeModel]) in

                XCTAssertTrue(all.first?.nestedModel == testModel)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testNestedModelUpdate() {
        let testModel = TestSomeModel.TestNestedModel(title: "title", count: 9)
        let someModel = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)

        service.save(models: [someModel])
        service.update(modelOf: TestSomeModel.self,
                       with: someModel.userId,
                       updates: ["nestedModel": testModel])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

            self.service.fetch() {
                (all: [TestSomeModel]) in

                XCTAssertTrue(all.first?.nestedModel == testModel)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testCollectionsStoring() {
        let codable = SomeCodable(key: "k", index: 4)
        let persistable = SomePersistable(persistedValue: 2)
        let url = URL(string: "https://google.com")!
        let testModel = TestCollectionsModel(id: 1,
                                             strings: ["one", "two"],
                                             intValues: [0, 3],
                                             doubleValues: nil,
                                             dates: [Date()],
                                             codable: [codable],
                                             persistable: [persistable],
                                             urls: [url],
                                             dict: ["key": persistable],
                                             anotherDict: [codable: .secondCase],
                                             set: [url],
                                             anotherSet: [codable],
                                             someEnum: [.secondCase, .thirdCase],
                                             someList: ["Test", "Test1"],
                                             codableEnums: [.chat(32), .program(22)])

        service.save(model: testModel)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let fetched: TestCollectionsModel? = self.service.syncFetchUnique(with: testModel.id)

            XCTAssertTrue(testModel == fetched)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testPrimitivesStoring() {
        let testModel = TestPrimitivesModel(id: 1,
                                            value: 20,
                                            doubleValue: 3.02,
                                            floatValue: nil,
                                            boolValue: true,
                                            urlValue: URL(string: "https://google.com"),
                                            someEnum: .secondCase,
                                            someEnumOpt: .thirdCase,
                                            stringEnum: .firstCase,
                                            stringEnumOpt: .secondCase,
                                            someComplexCodable: SomeComplexCodable(key: "key", index: 24, link: .profile(399)))
        let testModel2 = TestPrimitivesModel(id: 2,
                                             value: 5,
                                             doubleValue: 4.5909,
                                             floatValue: 9.123,
                                             boolValue: false,
                                             urlValue: nil,
                                             someEnum: .firstCase,
                                             someEnumOpt: nil,
                                             stringEnum: .secondCase,
                                             stringEnumOpt: nil,
                                             someComplexCodable: SomeComplexCodable(key: "key22", index: 74, link: .chat(223)))

        service.save(models: [testModel, testModel2])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let fetched: TestPrimitivesModel? = self.service.syncFetchUnique(with: testModel.id)
            let fetched2: TestPrimitivesModel? = self.service.syncFetchUnique(with: testModel2.id)

            XCTAssertTrue(testModel == fetched)
            XCTAssertTrue(testModel2 == fetched2)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testPrimitivesUpdates() {
        let testModel = TestPrimitivesModel(id: 1,
                                            value: 20,
                                            doubleValue: 3.02,
                                            floatValue: nil,
                                            boolValue: true,
                                            urlValue: URL(string: "https://yahoo.com"),
                                            someEnum: .secondCase,
                                            someEnumOpt: .thirdCase,
                                            stringEnum: .firstCase,
                                            stringEnumOpt: .secondCase,
                                            someComplexCodable: SomeComplexCodable(key: "key", index: 78, link: .chat(226)))

        service.save(models: [testModel])

        let expectation = XCTestExpectation()

        service.update(modelOf: TestPrimitivesModel.self,
                       with: testModel.id,
                       updates: ["doubleValue": 5.0,
                                 "someEnum": SomeEnum.firstCase,
                                 "someEnumOpt": nil,
                                 "stringEnumOpt": SomeStringEnum.thirdCase,
                                 "urlValue": URL(string: "https://google.com")])

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let fetched: TestPrimitivesModel? = self.service.syncFetchUnique(with: testModel.id)

            XCTAssertTrue(fetched?.doubleValue == 5)
            XCTAssertTrue(fetched?.someEnum == .firstCase)
            XCTAssertTrue(fetched?.someEnumOpt == nil)
            XCTAssertTrue(fetched?.stringEnumOpt == .thirdCase)
            XCTAssertTrue(fetched?.urlValue == URL(string: "https://google.com"))

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testTypeSafePrimitivesUpdates() {
        let testModel = TestPrimitivesModel(id: 1,
                                            value: 20,
                                            doubleValue: 3.02,
                                            floatValue: nil,
                                            boolValue: true,
                                            urlValue: URL(string: "https://google.com"),
                                            someEnum: .secondCase,
                                            someEnumOpt: .thirdCase,
                                            stringEnum: .firstCase,
                                            stringEnumOpt: .secondCase,
                                            someComplexCodable: SomeComplexCodable(key: "key", index: 24, link: .profile(399)))

        service.save(models: [testModel])

        let expectation = XCTestExpectation()

        service.update(modelOf: TestPrimitivesModel.self,
                       with: testModel.id,
                       updates: [\TestPrimitivesModel.doubleValue <- 5,
                                 \TestPrimitivesModel.someEnum <- .firstCase,
                                 \TestPrimitivesModel.someEnumOpt <- nil,
                                 \TestPrimitivesModel.stringEnumOpt <- .thirdCase,
                                 \TestPrimitivesModel.urlValue <- URL(string: "https://yahoo.com")])

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let fetched: TestPrimitivesModel? = self.service.syncFetchUnique(with: testModel.id)

            XCTAssertTrue(fetched?.doubleValue == 5)
            XCTAssertTrue(fetched?.someEnum == .firstCase)
            XCTAssertTrue(fetched?.someEnumOpt == nil)
            XCTAssertTrue(fetched?.stringEnumOpt == .thirdCase)
            XCTAssertTrue(fetched?.urlValue == URL(string: "https://yahoo.com"))

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testCollectionsUpdate() {
        let codable = SomeCodable(key: "k", index: 4)
        let newCodable = SomeCodable(key: "b", index: 5)
        let persistable = SomePersistable(persistedValue: 6)
        let newPersistable = SomePersistable(persistedValue: 7)
        let url = URL(string: "https://google.com")!
        let url2 = URL(string: "https://yahoo.com")!
        let testModel = TestCollectionsModel(id: 1,
                                             strings: ["one", "two"],
                                             intValues: [0, 3],
                                             doubleValues: nil,
                                             dates: [Date()],
                                             codable: [codable],
                                             persistable: [persistable],
                                             urls: [url],
                                             dict: ["key": persistable],
                                             anotherDict: [codable: .firstCase],
                                             set: [url],
                                             anotherSet: [codable],
                                             someEnum: [.secondCase, .thirdCase],
                                             someList: ["Test3", "Test4"],
                                             codableEnums: [.chat(32), .program(22)])

        service.save(models: [testModel])
        let updates: [RootKeyPathUpdate<TestCollectionsModel>] = [\TestCollectionsModel.intValues <- [0, 5],
                                                                  \TestCollectionsModel.codable <- [newCodable, codable],
                                                                  \TestCollectionsModel.urls <- [url, url2],
                                                                  \TestCollectionsModel.dict <- ["key2": newPersistable],
                                                                  \TestCollectionsModel.someList <- ["Test1", "Test2"],
                                                                  \TestCollectionsModel.codableEnums <- [.profile(31), .chat(21)]]

        service.update(modelOf: TestCollectionsModel.self, with: testModel.id, updates: updates)

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let all: [TestCollectionsModel] = self.service.syncFetch()

            XCTAssertTrue(all.first?.intValues == [0, 5], "\(all)")
            XCTAssertTrue(all.first?.codable == [newCodable, codable], "\(all)")
            XCTAssertTrue(all.first?.urls == [url, url2], "\(all)")
            XCTAssertTrue(all.first?.dict == ["key2": newPersistable], "\(all)")
            XCTAssertTrue(all.first?.someList == ["Test1", "Test2"], "\(all)")
            XCTAssertTrue(all.first?.codableEnums == [.profile(31), .chat(21)], "\(all)")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testMaxMin() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 3, nestedModel: nil)
        let testModel3 = TestSomeModel(userId: 3, userName: "ki", userAvatar: "rw", title: "pl", count: 10, nestedModel: nil)
        let testModel4 = TestSomeModel(userId: 4, userName: "ki", userAvatar: "rw", title: "pl", count: 7, nestedModel: nil)

        service.save(models: [testModel, testModel2, testModel3, testModel4])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let max: Int? = self.service.maxSync(with: .unfiltered, for: \TestSomeModel.count)
            let min: Int? = self.service.minSync(with: .unfiltered, for: \TestSomeModel.count)
            let minFiltered: Int? = self.service.minSync(with: .query(query: "userAvatar == 'rw'"), for: \TestSomeModel.count)

            XCTAssertTrue(max == 10)
            XCTAssertTrue(min == 2)
            XCTAssertTrue(minFiltered == 3)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testMaxMinUpdates() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 3, nestedModel: nil)
        let testModel3 = TestSomeModel(userId: 3, userName: "ki", userAvatar: "rw", title: "pl", count: 10, nestedModel: nil)
        let testModel4 = TestSomeModel(userId: 4, userName: "ki", userAvatar: "rw", title: "pl", count: 7, nestedModel: nil)

        service.save(models: [testModel, testModel4])

        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 4

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            var tokenMax: DatabaseUpdatesToken?
            tokenMax = self.service.max(with: .unfiltered, for: \TestSomeModel.count, callback: {
                XCTAssertTrue($0 == 7)
            }) {
                tokenMax?.invalidate()

                XCTAssertTrue($0 == 10)
                expectation.fulfill()
            }
            self.service.max(with: .query(query: "userAvatar == 'we'"), for: \TestSomeModel.count, callback: {
                XCTAssertTrue($0 == 2)
                expectation.fulfill()
            })

            var tokenMin: DatabaseUpdatesToken?
            tokenMin = self.service.min(with: .query(query: "userAvatar == 'rw'"), for: \TestSomeModel.count, callback: {
                XCTAssertTrue($0 == 7)
            }) {
                tokenMin?.invalidate()

                XCTAssertTrue($0 == 3)
                expectation.fulfill()
            }
            self.service.min(with: .unfiltered, for: \TestSomeModel.count, callback: {
                XCTAssertTrue($0 == 2)
                expectation.fulfill()
            })

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.service.save(models: [testModel2, testModel3])
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testMaxMinOptional() {
        let testModel = TestPrimitivesModel(id: 1,
                                            value: 20,
                                            doubleValue: 3.02,
                                            floatValue: nil,
                                            boolValue: true,
                                            urlValue: URL(string: "https://google.com"),
                                            someEnum: .secondCase,
                                            someEnumOpt: .thirdCase,
                                            stringEnum: .firstCase,
                                            stringEnumOpt: .secondCase,
                                            someComplexCodable: SomeComplexCodable(key: "key", index: 24, link: .profile(399)))
        let testModel2 = TestPrimitivesModel(id: 2,
                                             value: 5,
                                             doubleValue: 4.5909,
                                             floatValue: 9.123,
                                             boolValue: false,
                                             urlValue: nil,
                                             someEnum: .firstCase,
                                             someEnumOpt: nil,
                                             stringEnum: .secondCase,
                                             stringEnumOpt: nil,
                                             someComplexCodable: nil)
        let testModel3 = TestPrimitivesModel(id: 3,
                                             value: nil,
                                             doubleValue: 4.5909,
                                             floatValue: 9.123,
                                             boolValue: false,
                                             urlValue: nil,
                                             someEnum: .firstCase,
                                             someEnumOpt: nil,
                                             stringEnum: .secondCase,
                                             stringEnumOpt: nil,
                                             someComplexCodable: nil)

        service.save(models: [testModel, testModel2, testModel3])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let max = self.service.maxSync(with: .unfiltered, for: \TestPrimitivesModel.value)
            let min = self.service.minSync(with: .unfiltered, for: \TestPrimitivesModel.value)

            XCTAssertTrue(max == 20)
            XCTAssertTrue(min == 5)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testSumAverage() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 3, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 4, nestedModel: nil)
        let testModel3 = TestSomeModel(userId: 3, userName: "ki", userAvatar: "rw", title: "pl", count: 10, nestedModel: nil)
        let testModel4 = TestSomeModel(userId: 4, userName: "ki", userAvatar: "rw", title: "pl", count: 7, nestedModel: nil)

        service.save(models: [testModel, testModel2, testModel3, testModel4])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let sum: Int = self.service.sumSync(with: .unfiltered, for: \TestSomeModel.count)
            let average: Double? = self.service.averageSync(with: .unfiltered, for: \TestSomeModel.count)
            let averageFiltered: Double? = self.service.averageSync(with: .query(query: "userAvatar == 'rw'"), for: \TestSomeModel.count)

            XCTAssertTrue(sum == 24)
            XCTAssertTrue(average == 6)
            XCTAssertTrue(averageFiltered == 7)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testSumAverageUpdates() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 3, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 4, nestedModel: nil)
        let testModel3 = TestSomeModel(userId: 3, userName: "ki", userAvatar: "rw", title: "pl", count: 10, nestedModel: nil)
        let testModel4 = TestSomeModel(userId: 4, userName: "ki", userAvatar: "rw", title: "pl", count: 7, nestedModel: nil)

        service.save(models: [testModel, testModel4])

        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 4

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            var sumToken: DatabaseUpdatesToken?
            sumToken = self.service.sum(with: .unfiltered, for: \TestSomeModel.count, callback: {
                XCTAssertTrue($0 == 10)
            }) {
                sumToken?.invalidate()

                XCTAssertTrue($0 == 24)
                expectation.fulfill()
            }
            var sumFilteredToken: DatabaseUpdatesToken?
            sumFilteredToken = self.service.sum(with: .query(query: "userAvatar == 'rw'"), for: \TestSomeModel.count, callback: {
                XCTAssertTrue($0 == 7)
            }) {
                sumFilteredToken?.invalidate()

                XCTAssertTrue($0 == 21)
                expectation.fulfill()
            }
            var averageToken: DatabaseUpdatesToken?
            averageToken = self.service.average(with: .unfiltered, for: \TestSomeModel.count, callback: {
                XCTAssertTrue($0 == 5)
            }) {
                averageToken?.invalidate()

                XCTAssertTrue($0 == 6)
                expectation.fulfill()
            }
            var averageFilteredToken: DatabaseUpdatesToken?
            averageFilteredToken = self.service.average(with: .query(query: "userAvatar == 'rw'"), for: \TestSomeModel.count, callback: {
                XCTAssertTrue($0 == 7)
            }) {
                averageFilteredToken?.invalidate()

                XCTAssertTrue($0 == 7)
                expectation.fulfill()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.service.save(models: [testModel2, testModel3])
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testCount() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 3, nestedModel: nil)
        let testModel3 = TestSomeModel(userId: 3, userName: "ki", userAvatar: "rw", title: "pl", count: 10, nestedModel: nil)
        let testModel4 = TestSomeModel(userId: 4, userName: "ki", userAvatar: "rw", title: "pl", count: 7, nestedModel: nil)

        service.save(models: [testModel, testModel2, testModel3, testModel4])

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let count = self.service.countSync(for: TestSomeModel.self)
            let countFiltered = self.service.countSync(for: TestSomeModel.self, with: .query(query: "userAvatar == 'rw'"))

            XCTAssertTrue(count == 4)
            XCTAssertTrue(countFiltered == 3)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testCountUpdates() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 3, nestedModel: nil)
        let testModel3 = TestSomeModel(userId: 3, userName: "ki", userAvatar: "rw", title: "pl", count: 10, nestedModel: nil)
        let testModel4 = TestSomeModel(userId: 4, userName: "ki", userAvatar: "rw", title: "pl", count: 7, nestedModel: nil)

        service.save(models: [testModel, testModel4])

        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            var countToken: DatabaseUpdatesToken?
            countToken = self.service.count(for: TestSomeModel.self, callback: {
                XCTAssertTrue($0 == 2)
            }) {
                countToken?.invalidate()
                XCTAssertTrue($0 == 4)
                expectation.fulfill()
            }
            var countFilteredToken: DatabaseUpdatesToken?
            countFilteredToken = self.service.count(for: TestSomeModel.self, with: .query(query: "userAvatar == 'rw'"), callback: {
                XCTAssertTrue($0 == 1)
            }) {
                countFilteredToken?.invalidate()
                XCTAssertTrue($0 == 3)
                expectation.fulfill()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.service.save(models: [testModel2, testModel3])
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testBatchStoreWithKey() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)

        let service = service.startBatchService()
        service.save(model: testModel)
        service.save(model: testModel2)
        service.commitBatchWrites()

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let all: [TestSomeModel] = self.service.syncFetch()

            XCTAssertTrue(all.sorted { $0.userId < $1.userId } == [testModel, testModel2])

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testBatchStoreBlockWithKey() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)

        service.withBatchWrites { service in
            service.save(model: testModel)
            service.save(model: testModel2)
        }

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let all: [TestSomeModel] = self.service.syncFetch()

            XCTAssertTrue(all.sorted { $0.userId < $1.userId } == [testModel, testModel2])

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testSyncBatchStoreWithKey() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)

        let service = service.startBatchService()
        service.save(model: testModel)
        //Test duplicate
        service.save(model: testModel)
        service.save(model: testModel2)
        service.commitBatchWrites(sync: true)

        let all: [TestSomeModel] = self.service.syncFetch()

        XCTAssertTrue([testModel, testModel2] == all)
    }

    func testBatchUpdate() {
        let testModel = TestSomeModel(userId: 1, userName: "rt", userAvatar: "we", title: "po", count: 2, nestedModel: nil)
        let testModel2 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)
        let testModel3 = TestSomeModel(userId: 1, userName: "rt", userAvatar: "ab", title: "po", count: 3, nestedModel: nil)
        let testModel4 = TestSomeModel(userId: 2, userName: "ki", userAvatar: "ad", title: "pl", count: 3, nestedModel: nil)

        let service = service.startBatchService()
        service.save(models: [testModel, testModel2])
        service.update(models: [testModel3, testModel4])
        service.commitBatchWrites()

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let all: [TestSomeModel] = self.service.syncFetch()

            XCTAssertTrue(all.sorted { $0.userId < $1.userId } == [testModel3, testModel4])

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }
}
