import XCTest
import RealmSwift
import DatabaseObjectsMapper
@testable import DatabaseObjectsMapper_Example


class RealmPerformanceTests: XCTestCase {

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

    func testSimplePerformance() {
        let testModel = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)

        service.save(models: Array(0..<1000).map { testModel.userIdLens.set($0) })

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.measureMetrics(XCTestCase.defaultPerformanceMetrics, automaticallyStartMeasuring: false) {
                self.startMeasuring()
                let fetched: [TestSomeModel] = self.service.syncFetch()
                self.stopMeasuring()
                XCTAssertTrue(fetched.count == 1000)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10)
    }

    func testDefaultContainerPerformance() {
        let testModel = TestModel(id: 1, index: 3, name: "fr", count: 3, someCount: 4, urls: nil, someModel: nil)

        service.save(models: Array(0..<1000).map { testModel.idLens.set($0) })

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.measureMetrics(XCTestCase.defaultPerformanceMetrics, automaticallyStartMeasuring: false) {
                self.startMeasuring()
                let fetched: [TestModel] = self.service.syncFetch()
                self.stopMeasuring()
                XCTAssertTrue(fetched.count == 1000)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10)
    }

    func testCollectionsPerformance() {
        let codable = SomeCodable(key: "k", index: 4)
        let persistable = SomePersistable(persistedValue: 3)
        let url = URL(string: "https://google.com")!
        let testModel = TestCollectionsModel(id: 1,
                                             strings: ["one", "two"],
                                             intValues: [0, 3],
                                             doubleValues: nil,
                                             dates: [Date()],
                                             codable: [codable],
                                             persistable: [persistable],
                                             urls: [url],
                                             dict: ["key3": persistable],
                                             anotherDict: [codable: .thirdCase],
                                             set: [url],
                                             anotherSet: [codable],
                                             someEnum: [.thirdCase],
                                             someList: ["Test", "Test1"],
                                             codableEnums: [.chat(32), .program(22)])

        service.save(models: Array(0..<1000).map { testModel.idLens.set($0) })

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.measureMetrics(XCTestCase.defaultPerformanceMetrics, automaticallyStartMeasuring: false) {
                self.startMeasuring()
                let fetched: [TestCollectionsModel] = self.service.syncFetch()
                self.stopMeasuring()
                XCTAssertTrue(fetched.count == 1000)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10)
    }

    func testRelationPerformance() {
        let subModel = TestSomeModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2, nestedModel: nil)
        let testModel = TestRRModel(id: 1, name: "ll", owner: subModel)

        service.save(models: Array(0..<1000).map { testModel.idLens.set($0) })

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.measureMetrics(XCTestCase.defaultPerformanceMetrics, automaticallyStartMeasuring: false) {
                self.startMeasuring()
                let fetched: [TestRRModel] = self.service.syncFetch()
                self.stopMeasuring()
                XCTAssertTrue(fetched.count == 1000)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10)
    }
}
