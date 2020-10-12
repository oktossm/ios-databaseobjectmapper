import XCTest
import RealmSwift
import DatabaseObjectsMapper
@testable import DatabaseObjectsMapper_Example


class DatePredicateTests: XCTestCase {

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

    var nowDateModel: TestDateModel!
    var nowPlusOneDayTestModel: TestDateModel!
    var nowPlusOneMonthTestModel: TestDateModel!
    var nowMinusOneDayTestModel: TestDateModel!
    var nowMinusOneMonthTestModel: TestDateModel!

    var savedModels: [TestDateModel] = []
    func saveModels() {
        nowDateModel = TestDateModel(id: 1, date: Date())

        nowPlusOneDayTestModel = TestDateModel(id: 2, date: Date(timeIntervalSinceNow: 24 * 60 * 60))
        nowMinusOneDayTestModel = TestDateModel(id: 3, date: Date(timeIntervalSinceNow: -24 * 60 * 60))

        nowPlusOneMonthTestModel = TestDateModel(id: 4, date: Date(timeIntervalSinceNow: 30 * 24 * 60 * 60))
        nowMinusOneMonthTestModel = TestDateModel(id: 5, date: Date(timeIntervalSinceNow: -30 * 24 * 60 * 60))


        let models: [TestDateModel] = [
            nowDateModel,
            nowMinusOneDayTestModel,
            nowPlusOneDayTestModel,
            nowMinusOneMonthTestModel,
            nowPlusOneMonthTestModel
        ]

        service.save(models: models, sync: true)

        savedModels = models
    }

    override func tearDown() {
        super.tearDown()
    }

    func testDateQueries() {
        saveModels()

        var models = self.service.syncFetch(\TestDateModel.date > self.nowDateModel.date,
                                            sorted: [SortDescriptor(\TestDateModel.date, ascending: true)])
        XCTAssertTrue([self.nowPlusOneDayTestModel, self.nowPlusOneMonthTestModel] == models)

        models = self.service.syncFetch(\TestDateModel.date <= self.nowDateModel.date,
                                        sorted: [SortDescriptor(\TestDateModel.date, ascending: true)])
        XCTAssertTrue([self.nowMinusOneMonthTestModel, self.nowMinusOneDayTestModel, self.nowDateModel] == models)
    }
}
