// Generated using Sourcery 0.16.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// MARK: - AutoDatabaseMappable
import RealmSwift
import DatabaseObjectsMapper
import DatabaseObjectsMapper

// swiftlint:disable file_length



// MARK: - AutoDatabaseMappable for classes, structs
// MARK: - TestCollectionsModel generated container
internal class TestCollectionsModelContainer: Object, DatabaseContainer {
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
    @objc public dynamic var someEnum = Data()
}

extension TestCollectionsModel: KeyPathConvertible {
    static func key(for keyPath: PartialKeyPath<TestCollectionsModel>) -> String {
        switch keyPath {
        case \TestCollectionsModel.id: return "id"
        case \TestCollectionsModel.strings: return "strings"
        case \TestCollectionsModel.intValues: return "intValues"
        case \TestCollectionsModel.doubleValues: return "doubleValues"
        case \TestCollectionsModel.dates: return "dates"
        case \TestCollectionsModel.codable: return "codable"
        case \TestCollectionsModel.urls: return "urls"
        case \TestCollectionsModel.dict: return "dict"
        case \TestCollectionsModel.anotherDict: return "anotherDict"
        case \TestCollectionsModel.set: return "set"
        case \TestCollectionsModel.anotherSet: return "anotherSet"
        case \TestCollectionsModel.someEnum: return "someEnum"
        default:
            fatalError("Unhandled key path")
        }
    }
}
// MARK: - TestPrimitivesModel generated container
internal class TestPrimitivesModelContainer: Object, DatabaseContainer {
    public static var idKey: WritableKeyPath<TestPrimitivesModelContainer, Int> = \TestPrimitivesModelContainer.id
            public override static func primaryKey() -> String? {
        return "id"
    }
    public override class func indexedProperties() -> [String] {
        return []
    }
    @objc public dynamic var id: Int = 0
    let value = RealmOptional<Int32>()
    @objc public dynamic var doubleValue: Double = 0
    let floatValue = RealmOptional<Float>()
    let boolValue = RealmOptional<Bool>()
    @objc public dynamic var someEnum: Int = Int()
    let someEnumOpt = RealmOptional<Int>()
    @objc public dynamic var stringEnum: String = String()
    @objc public dynamic var stringEnumOpt: String?
}

extension TestPrimitivesModel: KeyPathConvertible {
    static func key(for keyPath: PartialKeyPath<TestPrimitivesModel>) -> String {
        switch keyPath {
        case \TestPrimitivesModel.id: return "id"
        case \TestPrimitivesModel.value: return "value"
        case \TestPrimitivesModel.doubleValue: return "doubleValue"
        case \TestPrimitivesModel.floatValue: return "floatValue"
        case \TestPrimitivesModel.boolValue: return "boolValue"
        case \TestPrimitivesModel.someEnum: return "someEnum"
        case \TestPrimitivesModel.someEnumOpt: return "someEnumOpt"
        case \TestPrimitivesModel.stringEnum: return "stringEnum"
        case \TestPrimitivesModel.stringEnumOpt: return "stringEnumOpt"
        default:
            fatalError("Unhandled key path")
        }
    }
}
// MARK: - TestRRModel generated container
internal class TestRRModelContainer: Object, DatabaseContainer {
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

extension TestRRModel: KeyPathConvertible {
    static func key(for keyPath: PartialKeyPath<TestRRModel>) -> String {
        switch keyPath {
        case \TestRRModel.id: return "id"
        case \TestRRModel.name: return "name"
        case \TestRRModel.owner: return "owner"
        case \TestRRModel.users: return "users"
        default:
            fatalError("Unhandled key path")
        }
    }
}
// MARK: - TestSomeModel generated container
internal class TestSomeModelContainer: Object, DatabaseContainer {
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

extension TestSomeModel: KeyPathConvertible {
    static func key(for keyPath: PartialKeyPath<TestSomeModel>) -> String {
        switch keyPath {
        case \TestSomeModel.userId: return "userId"
        case \TestSomeModel.userName: return "userName"
        case \TestSomeModel.userAvatar: return "userAvatar"
        case \TestSomeModel.title: return "title"
        case \TestSomeModel.count: return "count"
        case \TestSomeModel.inverseModel: return "inverseModel"
        case \TestSomeModel.directModels: return "directModels"
        case \TestSomeModel.nestedModel: return "nestedModel"
        default:
            fatalError("Unhandled key path")
        }
    }
}
