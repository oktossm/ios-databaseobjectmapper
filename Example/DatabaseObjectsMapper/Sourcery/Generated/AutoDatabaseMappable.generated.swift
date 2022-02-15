// Generated using Sourcery 1.6.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// MARK: - AutoDatabaseMappable
import RealmSwift
import DatabaseObjectsMapper
import DatabaseObjectsMapper

// swiftlint:disable file_length


// MARK: - AutoDatabaseMappable for classes, structs
// MARK: - TestCollectionsModel generated container
internal class TestCollectionsModelContainer: Object, UniqueDatabaseContainer {
    public static var idKey: WritableKeyPath<TestCollectionsModelContainer, Int> = \TestCollectionsModelContainer.id
    @Persisted(primaryKey: true) var id: Int
    @Persisted var strings: List<String>
    @Persisted var intValues: Data
    @Persisted var doubleValues: Data?
    @Persisted var dates: Data?
    @Persisted var codable: Data
    @Persisted var persistable: List<SomePersistable>
    @Persisted var urls: List<URL>
    @Persisted var dict: Map<String, SomePersistable>
    @Persisted var anotherDict: Data
    @Persisted var set: MutableSet<URL>
    @Persisted var anotherSet: Data
    @Persisted var someEnum: List<SomeEnum>
    @Persisted var someList: List<String>
    @Persisted var codableEnums: Data
}

extension TestCollectionsModel: KeyPathConvertible {
    public static func key(for keyPath: PartialKeyPath<TestCollectionsModel>) -> String {
        switch keyPath {
        case \TestCollectionsModel.id: return "id"
        case \TestCollectionsModel.strings: return "strings"
        case \TestCollectionsModel.intValues: return "intValues"
        case \TestCollectionsModel.doubleValues: return "doubleValues"
        case \TestCollectionsModel.dates: return "dates"
        case \TestCollectionsModel.codable: return "codable"
        case \TestCollectionsModel.persistable: return "persistable"
        case \TestCollectionsModel.urls: return "urls"
        case \TestCollectionsModel.dict: return "dict"
        case \TestCollectionsModel.anotherDict: return "anotherDict"
        case \TestCollectionsModel.set: return "set"
        case \TestCollectionsModel.anotherSet: return "anotherSet"
        case \TestCollectionsModel.someEnum: return "someEnum"
        case \TestCollectionsModel.someList: return "someList"
        case \TestCollectionsModel.codableEnums: return "codableEnums"
        default:
            fatalError("Unhandled key path")
        }
    }
}
// MARK: - TestDateModel generated container
internal class TestDateModelContainer: Object, UniqueDatabaseContainer {
    public static var idKey: WritableKeyPath<TestDateModelContainer, Int> = \TestDateModelContainer.id
    @Persisted(primaryKey: true) var id: Int
    @Persisted var date: Date
}

extension TestDateModel: KeyPathConvertible {
    public static func key(for keyPath: PartialKeyPath<TestDateModel>) -> String {
        switch keyPath {
        case \TestDateModel.id: return "id"
        case \TestDateModel.date: return "date"
        default:
            fatalError("Unhandled key path")
        }
    }
}
// MARK: - TestERRModel generated container
internal class TestERRModelContainer: EmbeddedObject, DatabaseContainer {
    @Persisted var name: String
    @Persisted var someCount: Int
    @Persisted var url: URL?
}

extension TestERRModel: KeyPathConvertible {
    public static func key(for keyPath: PartialKeyPath<TestERRModel>) -> String {
        switch keyPath {
        case \TestERRModel.name: return "name"
        case \TestERRModel.someCount: return "someCount"
        case \TestERRModel.url: return "url"
        default:
            fatalError("Unhandled key path")
        }
    }
}
// MARK: - TestPrimitivesModel generated container
internal class TestPrimitivesModelContainer: Object, UniqueDatabaseContainer {
    public static var idKey: WritableKeyPath<TestPrimitivesModelContainer, Int> = \TestPrimitivesModelContainer.id
    @Persisted(primaryKey: true) var id: Int
    @Persisted var value: Int32?
    @Persisted var doubleValue: Double
    @Persisted var floatValue: Float?
    @Persisted var boolValue: Bool?
    @Persisted var urlValue: URL?
    @Persisted var someEnum: SomeEnum
    @Persisted var someEnumOpt: SomeEnum?
    @Persisted var stringEnum: String
    @Persisted var stringEnumOpt: String?
    @Persisted var someComplexCodable: Data?
}

extension TestPrimitivesModel: KeyPathConvertible {
    public static func key(for keyPath: PartialKeyPath<TestPrimitivesModel>) -> String {
        switch keyPath {
        case \TestPrimitivesModel.id: return "id"
        case \TestPrimitivesModel.value: return "value"
        case \TestPrimitivesModel.doubleValue: return "doubleValue"
        case \TestPrimitivesModel.floatValue: return "floatValue"
        case \TestPrimitivesModel.boolValue: return "boolValue"
        case \TestPrimitivesModel.urlValue: return "urlValue"
        case \TestPrimitivesModel.someEnum: return "someEnum"
        case \TestPrimitivesModel.someEnumOpt: return "someEnumOpt"
        case \TestPrimitivesModel.stringEnum: return "stringEnum"
        case \TestPrimitivesModel.stringEnumOpt: return "stringEnumOpt"
        case \TestPrimitivesModel.someComplexCodable: return "someComplexCodable"
        default:
            fatalError("Unhandled key path")
        }
    }
}
// MARK: - TestRNModel generated container
internal class TestRNModelContainer: Object, UniqueDatabaseContainer {
    public static var idKey: WritableKeyPath<TestRNModelContainer, Int> = \TestRNModelContainer.id
    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String
    @Persisted var owner: TestSomeModelContainer?
}

extension TestRNModel: KeyPathConvertible {
    public static func key(for keyPath: PartialKeyPath<TestRNModel>) -> String {
        switch keyPath {
        case \TestRNModel.id: return "id"
        case \TestRNModel.name: return "name"
        case \TestRNModel.owner: return "owner"
        default:
            fatalError("Unhandled key path")
        }
    }
}
// MARK: - TestRRModel generated container
internal class TestRRModelContainer: Object, UniqueDatabaseContainer {
    public static var idKey: WritableKeyPath<TestRRModelContainer, Int> = \TestRRModelContainer.id
    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String
    @Persisted var owner: TestSomeModelContainer?
    @Persisted var user: TestERRModelContainer?
    @Persisted var users: List<TestRRModelContainer>
    @Persisted var owners: List<TestERRModelContainer>
}

extension TestRRModel: KeyPathConvertible {
    public static func key(for keyPath: PartialKeyPath<TestRRModel>) -> String {
        switch keyPath {
        case \TestRRModel.id: return "id"
        case \TestRRModel.name: return "name"
        case \TestRRModel.owner: return "owner"
        case \TestRRModel.user: return "user"
        case \TestRRModel.users: return "users"
        case \TestRRModel.owners: return "owners"
        default:
            fatalError("Unhandled key path")
        }
    }
}
// MARK: - TestSomeModel generated container
internal class TestSomeModelContainer: Object, UniqueDatabaseContainer {
    public static var idKey: WritableKeyPath<TestSomeModelContainer, Int> = \TestSomeModelContainer.userId
    @Persisted(primaryKey: true) var userId: Int
    @Persisted(indexed: true) var userName: String
    @Persisted var userAvatar: String
    @Persisted(indexed: true) var title: String?
    @Persisted var count: Int
    @Persisted(originProperty: "owner") var inverseModel: LinkingObjects<TestRRModelContainer>
    @Persisted var directModels: List<TestRRModelContainer>
    @Persisted var nestedModel: Data?
}

extension TestSomeModel: KeyPathConvertible {
    public static func key(for keyPath: PartialKeyPath<TestSomeModel>) -> String {
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
