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
        service.deleteAll()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSimpleRelationship() {
        let subModel = TestSubModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2)
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
                (all: [TestSubModel]) in

                XCTAssertTrue(all == [subModel])
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testToManyRelationship() {
        let subModel = TestSubModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2)
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
                (all: [TestSubModel]) in

                XCTAssertTrue(all == [subModel])
                expectation.fulfill()
            }

            self.service.fetchRelation(subModel.directModels, in: subModel, with: .unfiltered, with: .unsorted) {
                (all: [TestRRModel]) in

                XCTAssertTrue(all == [testModel])
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testAddRelationship() {
        let subModel = TestSubModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2)
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
                (all: [TestSubModel]) in

                XCTAssertTrue(all == [subModel])
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testAddToManyRelationship() {
        let subModel = TestSubModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2)
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
                (all: [TestSubModel]) in

                XCTAssertTrue(all == [subModel])
                expectation.fulfill()
            }

            self.service.fetchRelation(subModel.directModels, in: subModel, with: .unfiltered, with: .unsorted) {
                (all: [TestRRModel]) in

                XCTAssertTrue(all == [testModel])
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testAddToManyRelationshipWithKeys() {
        let subModel = TestSubModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2)
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
                (all: [TestSubModel]) in

                XCTAssertTrue(all == [subModel])
                expectation.fulfill()
            }

            self.service.fetchRelation(subModel.directModels, in: subModel, with: .unfiltered, with: .unsorted) {
                (all: [TestRRModel]) in

                XCTAssertTrue(all == [testModel])
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testRemoveSimpleRelationship() {
        let subModel = TestSubModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2)
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

                XCTAssertTrue(all == [testModel])
                expectation.fulfill()
            }

            self.service.fetch() {
                (all: [TestSubModel]) in

                XCTAssertTrue(all == [subModel])
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testRemoveToManyRelationship() {
        let subModel = TestSubModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2)
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
                (all: [TestSubModel]) in

                XCTAssertTrue(all == [subModel])
                expectation.fulfill()
            }

            self.service.fetchRelation(subModel.directModels, in: subModel, with: .unfiltered, with: .unsorted) {
                (all: [TestRRModel]) in

                XCTAssertTrue(all == [])
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }


    func testInverseRelationship() {
        let subModel = TestSubModel(userId: 2, userName: "ki", userAvatar: "rw", title: "pl", count: 2)
        let testModel = TestRRModel(id: 1, name: "ll", owner: subModel)

        service.save(models: [testModel])

        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

            self.service.fetchRelation(subModel.inverseModel,
                                       in: subModel,
                                       with: .unfiltered,
                                       with: .unsorted) {
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
}
