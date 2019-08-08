// Generated using Sourcery 0.16.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// MARK: - AutoDatabaseMappable
import RealmSwift
import DatabaseObjectsMapper
import DatabaseObjectsMapper

// swiftlint:disable file_length



// MARK: - AutoDatabaseMappable for classes, structs
// MARK: - TestCollectionsModel generated container
class TestCollectionsModelContainer: Object, DatabaseContainer {
    public static var idKey: WritableKeyPath<TestCollectionsModelContainer, Int> = \TestCollectionsModelContainer.id
            public override static func primaryKey() -> String? {
        return "id"
    }
    public override class func indexedProperties() -> [String] {
        return []
    }
    @objc public dynamic var id: Int = 0
    @objc public dynamic var strings = Data()
    @objc public dynamic var intValues: Data?
    @objc public dynamic var doubleValues: Data?
    @objc public dynamic var dates: Data?
    @objc public dynamic var codable = Data()
    @objc public dynamic var urls = Data()
    @objc public dynamic var dict = Data()
    @objc public dynamic var anotherDict = Data()
    @objc public dynamic var set = Data()
    @objc public dynamic var anotherSet: Data?
}
// MARK: - TestRRModel generated container
class TestRRModelContainer: Object, DatabaseContainer {
    public static var idKey: WritableKeyPath<TestRRModelContainer, Int> = \TestRRModelContainer.id
            public override static func primaryKey() -> String? {
        return "id"
    }
    public override class func indexedProperties() -> [String] {
        return []
    }
    @objc public dynamic var id: Int = 0
    @objc public dynamic var name: String = String()
    @objc public dynamic var owner: TestSomeModelContainer?
    let users = List<TestRRModelContainer>()
}
// MARK: - TestSomeModel generated container
class TestSomeModelContainer: Object, DatabaseContainer {
    public static var idKey: WritableKeyPath<TestSomeModelContainer, Int> = \TestSomeModelContainer.userId
            public override static func primaryKey() -> String? {
        return "userId"
    }
    public override class func indexedProperties() -> [String] {
        return ["userName", "title"]
    }
    @objc public dynamic var userId: Int = 0
    @objc public dynamic var userName: String = String()
    @objc public dynamic var userAvatar: String = String()
    @objc public dynamic var title: String?
    @objc public dynamic var count: Int = 0
    let inverseModel = LinkingObjects(fromType: TestRRModelContainer.self, property: "owner")
    let directModels = List<TestRRModelContainer>()
    @objc public dynamic var nestedModel: Data?
}
