// Generated using Sourcery 0.15.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// MARK: - AutoDatabaseMappable
import RealmSwift
import DatabaseObjectsMapper
import DatabaseObjectsMapper

// swiftlint:disable file_length



// MARK: - AutoDatabaseMappable for classes, structs
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
    @objc public dynamic var owner: TestSubModelContainer?
    let users = List<TestRRModelContainer>()
}
// MARK: - TestSubModel generated container
class TestSubModelContainer: Object, DatabaseContainer {
    public static var idKey: WritableKeyPath<TestSubModelContainer, Int> = \TestSubModelContainer.userId
            public override static func primaryKey() -> String? {
        return "userId"
    }
    public override class func indexedProperties() -> [String] {
        return []
    }
    @objc public dynamic var userId: Int = 0
    @objc public dynamic var userName: String = String()
    @objc public dynamic var userAvatar: String = String()
    @objc public dynamic var title: String?
    @objc public dynamic var count: Int = 0
    let inverseModel = LinkingObjects(fromType: TestRRModelContainer.self, property: "owner")
    let directModels = List<TestRRModelContainer>()
}
