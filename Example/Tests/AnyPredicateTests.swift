import XCTest
import RealmSwift
import DatabaseObjectsMapper
@testable import DatabaseObjectsMapper_Example


class AnyPredicateTests: XCTestCase {

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

    var johnSwift: TestSomeModel!
    var johnObjC: TestSomeModel!

    var helenSwift: TestSomeModel!
    var helenObjC: TestSomeModel!
    var uniqueUser: TestSomeModel!

    var savedModels: [TestSomeModel] = []

    func saveModels() {
        johnSwift = TestSomeModel(
            userId: 1,
            userName: "John Swift",
            userAvatar: "Yellow Bird",
            title: "one'swift three",
            count: 1,
            nestedModel: nil
        )
        johnObjC = TestSomeModel(
            userId: 2,
            userName: "John ObjC",
            userAvatar: "White Bird",
            title: "four five'objc'eight",
            count: 2,
            nestedModel: nil
        )

        helenSwift = TestSomeModel(
            userId: 3,
            userName: "Helen Swift",
            userAvatar: "Yellow Submarine",
            title: "one'swift three",
            count: 3,
            nestedModel: nil
        )
        helenObjC = TestSomeModel(
            userId: 4,
            userName: "Helen ObjC",
            userAvatar: "White Submarine",
            title: "four five'objc'eight",
            count: 4,
            nestedModel: nil
        )
        uniqueUser = TestSomeModel(
            userId: 5,
            userName: "All words unique userName",
            userAvatar: "Unique avatar link",
            title: "Some unique title",
            count: 1024,
            nestedModel: nil
        )
        let models: [TestSomeModel] = [
            johnSwift,
            johnObjC,
            helenSwift,
            helenObjC,
            uniqueUser
        ]

        service.save(models: models, sync: true)

        savedModels = models
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testComplexPredicates() {
        saveModels()

        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 4

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

            let query1: TestSomeModel.Query = { ($0.userId == 1 && $0.userId == 2) || ($0.userId == 3 && $0.count == 3) }
            self.service.fetch(
                query1,
                sorted: [SortDescriptor(\TestSomeModel.userId, ascending: true)]) {
                models in

                XCTAssertTrue([self.helenSwift] == models)
                expectation.fulfill()
            }

            let query2: TestSomeModel.Query = { $0.userName.contains("Swift") || $0.userName.contains("ObjC") && $0.count > 1 }
            self.service.fetch(
                query2,
                sorted: [SortDescriptor(\TestSomeModel.userId, ascending: true)]) {
                models in

                XCTAssertTrue([self.johnSwift, self.johnObjC, self.helenSwift, self.helenObjC] == models)
                expectation.fulfill()
            }

            let query3: TestSomeModel.Query = { $0.userName.contains("Swift") || ($0.userName.contains("ObjC") && $0.count > 1) }
            self.service.fetch(
                query3,
                sorted: [SortDescriptor(\TestSomeModel.userId, ascending: true)]) {
                models in

                XCTAssertTrue([self.johnSwift, self.johnObjC, self.helenSwift, self.helenObjC] == models)
                expectation.fulfill()
            }

            let query4: TestSomeModel.Query = { ($0.userName.contains("Swift") || $0.userName.contains("ObjC")) && $0.count > 1 }
            self.service.fetch(
                query4,
                sorted: [SortDescriptor(\TestSomeModel.userId, ascending: true)]) {
                models in

                XCTAssertTrue([self.johnObjC, self.helenSwift, self.helenObjC] == models)
                expectation.fulfill()
            }

            // In not supported yet by Realm.Query
            //            let query5: TestSomeModel.Query = { $0.userId.in([1, 2, 3]) }
            //            self.service.fetch(
            //                query5,
            //                sorted: [SortDescriptor(\TestSomeModel.userId, ascending: true)]) {
            //                    models in
            //
            //                    XCTAssertTrue(self.savedModels.filter { [1,2,3].contains($0.userId) } == models)
            //                    expectation.fulfill()
            //            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testAnyPredicate() {
        let predicate1 = \TestSomeModel.userId == 1 && \TestSomeModel.count <= 2
        XCTAssertEqual(
            "userId == 1 AND count <= 2",
            predicate1.predicate.description
        )

        let predicate2 = \TestSomeModel.userId >= 1 || \TestSomeModel.count < 3
        XCTAssertEqual(
            "userId >= 1 OR count < 3",
            predicate2.predicate.description
        )

        let predicate3 = (\TestSomeModel.userId != 1 || \TestSomeModel.count <= 3) && (\TestSomeModel.count > 1 && \TestSomeModel.count < 3)
        XCTAssertEqual(
            "(userId != 1 OR count <= 3) AND (count > 1 AND count < 3)",
            predicate3.predicate.description
        )

        let predicate4 = (\TestSomeModel.userId > 1 && \TestSomeModel.userId < 3) || (\TestSomeModel.count > 1 && \TestSomeModel.count < 2)
        XCTAssertEqual(
            "(userId > 1 AND userId < 3) OR (count > 1 AND count < 2)",
            predicate4.predicate.description
        )

        let predicate5 = (\TestSomeModel.userId > 1 && \TestSomeModel.userId < 3) || \TestSomeModel.count > 1
        XCTAssertEqual(
            "(userId > 1 AND userId < 3) OR count > 1",
            predicate5.predicate.description
        )
    }

    func testNumericPredicateDescriptions() {
        let predicate1 = \TestSomeModel.userId ~ .in([1, 2, 5])
        XCTAssertEqual(
            "userId IN {1, 2, 5}",
            predicate1.predicate.description
        )

        let predicate2 = \TestSomeModel.count ~ .between(10...1024) || \TestSomeModel.count ~ .betweenValues(11, 200)
        XCTAssertEqual(
            "count BETWEEN {10, 1024} OR count BETWEEN {11, 200}",
            predicate2.predicate.description
        )

        let predicate3 = \TestSomeModel.userId ~ .in([])
        XCTAssertEqual(
            "userId IN {}",
            predicate3.predicate.description
        )

        let predicate4 = \TestSomeModel.userId ~ .between(0...0)
        XCTAssertEqual(
            "userId BETWEEN {0, 0}",
            predicate4.predicate.description
        )
    }

    func testStringPredicateDescriptions() {
        let predicate1 = \TestSomeModel.userName ~ .in(["Swift", "ObjC", "Hello World's", "Hello World\"s"])
        XCTAssertEqual(
            "userName IN {\"Swift\", \"ObjC\", \"Hello World\'s\", \"Hello World\\\"s\"}",
            predicate1.predicate.description
        )

        let predicate2 = \TestSomeModel.userName ~ .hasPrefix("John") && \TestSomeModel.userName ~ .hasSuffix("Swift")
        XCTAssertEqual(
            "userName BEGINSWITH \"John\" AND userName ENDSWITH \"Swift\"",
            predicate2.predicate.description
        )

        let predicate3 = \TestSomeModel.userAvatar ~ .like("John.*")
        XCTAssertEqual(
            "userAvatar LIKE \"John.*\"",
            predicate3.predicate.description
        )
    }

    func testFetchWithStringPredicates() {
        saveModels()

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

            let query1: TestSomeModel.Query = { $0.userName.starts(with: "Helen") }
            self.service.fetch(
                query1,
                sorted: [SortDescriptor(\TestSomeModel.userId, ascending: true)]) {
                models in

                XCTAssertTrue([self.helenSwift, self.helenObjC] == models)
                expectation.fulfill()
            }

            let query2: TestSomeModel.Query = { $0.userName.ends(with: "Swift") }
            self.service.fetch(
                query2,
                sorted: [SortDescriptor(\TestSomeModel.userId, ascending: true)]) {
                models in

                XCTAssertTrue([self.johnSwift, self.helenSwift] == models)
                expectation.fulfill()
            }

            // In not supported yet by Realm.Query
            //            let query3: TestSomeModel.Query = { $0.userName.in(["John Swift", "Helen Swift"]) }
            //            self.service.fetch(
            //                query3,
            //                sorted: [SortDescriptor(\TestSomeModel.userId, ascending: true)]) {
            //                    models in
            //
            //                    XCTAssertTrue([self.johnSwift, self.helenSwift] == models)
            //                    expectation.fulfill()
            //            }

            let query4: TestSomeModel.Query = { $0.userAvatar.contains("low") }
            self.service.fetch(
                query4,
                sorted: [SortDescriptor(\TestSomeModel.userId, ascending: true)]) {
                models in

                XCTAssertTrue([self.johnSwift, self.helenSwift] == models)
                expectation.fulfill()
            }

            let query5: TestSomeModel.Query = { $0.userName.contains("ohn Swi") }
            self.service.fetch(query5) {
                (models: [TestSomeModel]) in

                XCTAssertTrue([self.johnSwift] == models)
                expectation.fulfill()
            }

            let query6: TestSomeModel.Query = { $0.userName.like("Helen*") }
            self.service.fetch(
                query6,
                sorted: [SortDescriptor(\TestSomeModel.userId, ascending: true)]
            ) {
                models in

                XCTAssertTrue([self.helenSwift, self.helenObjC] == models)
                expectation.fulfill()
            }
        }

        expectation.expectedFulfillmentCount = 5
        wait(for: [expectation], timeout: 1)
    }

    func testFetchWithNumericPredicates() {
        saveModels()

        let expectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

            // In not supported yet by Realm.Query
            //            let query1: TestSomeModel.Query = { $0.userId.in([1, 3]) }
            //            self.service.fetch(
            //                query1,
            //                sorted: [SortDescriptor(\TestSomeModel.userId, ascending: true)]) {
            //                models in
            //
            //                XCTAssertTrue([self.johnSwift, self.helenSwift] == models)
            //                expectation.fulfill()
            //            }

            let query2: TestSomeModel.Query = { $0.userId.contains(2...4) }
            self.service.fetch(
                query2,
                sorted: [SortDescriptor(\TestSomeModel.userId, ascending: true)]) {
                models in

                XCTAssertTrue([self.johnObjC, self.helenSwift, self.helenObjC] == models)
                expectation.fulfill()
            }
        }

        expectation.expectedFulfillmentCount = 1
        wait(for: [expectation], timeout: 1)
    }
}
