// Generated using Sourcery 0.16.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// MARK: - AutoObjectDiff
import Foundation
import DatabaseObjectsMapper

// swiftlint:disable file_length

public protocol DictionaryElementRepresentable {
    var key: String { get }
    var value: Any? { get }
    init?(key: String, value: Any?)
}

extension Array where Element: DictionaryElementRepresentable {
    public func dictionaryRepresentation() -> [String: Any?] {
        var dict = [String: Any?]()
        self.forEach { dict.updateValue($0.value, forKey: $0.key) }
        return dict
    }
    public init?(dictionary: [String: Any?]) {
        self.init(dictionary.compactMap { key, value in Element(key: key, value: value) })
    }
}


// MARK: TestCDModel ObjectDiff
extension TestCDModel {

    enum Updates: DictionaryElementRepresentable {
        case id(Int)
        case index(Int?)
        case name(String)
        case count(Int)
        case someCount(Int)
        case urls([URL]?)
        case subModel(Relation<TestSomeModel>)
        var key: String {
            switch self {
                case .id: return "id"
                case .index: return "index"
                case .name: return "name"
                case .count: return "count"
                case .someCount: return "someCount"
                case .urls: return "urls"
                case .subModel: return "subModel"
            }
        }
        var value: Any? {
            switch self {
            case .id(let newValue): return newValue
            case .index(let newValue): return newValue
            case .name(let newValue): return newValue
            case .count(let newValue): return newValue
            case .someCount(let newValue): return newValue
            case .urls(let newValue): return newValue
            case .subModel(let newValue): return newValue
            }
        }
        init?(key: String, value: Any?) {
            switch key {
            case "id":
                if let value = value as? Int {
                    self = .id(value)
                } else { return nil }
            case "index":
                if let value = value as? Int? {
                    self = .index(value)
                } else { return nil }
            case "name":
                if let value = value as? String {
                    self = .name(value)
                } else { return nil }
            case "count":
                if let value = value as? Int {
                    self = .count(value)
                } else { return nil }
            case "someCount":
                if let value = value as? Int {
                    self = .someCount(value)
                } else { return nil }
            case "urls":
                if let value = value as? [URL]? {
                    self = .urls(value)
                } else { return nil }
            case "subModel":
                if let value = value as? Relation<TestSomeModel> {
                    self = .subModel(value)
                } else { return nil }
            default: return nil
            }
        }
    }

    static func updatesDict(_ _updates: [Updates]) -> [String: Any] {
        var dict = [String: Any]()
        _updates.forEach { dict[$0.key] = $0.value }
        return dict
    }

    func allUpdates() -> [Updates] {
        var updates = [Updates]()
        updates.append(.id(id))
        updates.append(.index(index))
        updates.append(.name(name))
        updates.append(.count(count))
        updates.append(.someCount(someCount))
        updates.append(.urls(urls))
        updates.append(.subModel(subModel))
        return updates
    }

    func updated(_ _updates: [String: Any]) -> TestCDModel {
        guard let updates = [Updates].init(dictionary: _updates) else { return self }
        return updated(updates)
    }
    func updated(_ _update: Updates) -> TestCDModel {
        switch _update {
            case .id(let newValue):
                return TestCDModel.idLens.set(newValue, self)
            case .index(let newValue):
                return TestCDModel.indexLens.set(newValue, self)
            case .name(let newValue):
                return TestCDModel.nameLens.set(newValue, self)
            case .count(let newValue):
                return TestCDModel.countLens.set(newValue, self)
            case .someCount(let newValue):
                return TestCDModel.someCountLens.set(newValue, self)
            case .urls(let newValue):
                return TestCDModel.urlsLens.set(newValue, self)
            case .subModel(let newValue):
                return TestCDModel.subModelLens.set(newValue, self)
        }
    }
    func updated(_ _updates: [Updates]) -> TestCDModel {
        return _updates.reduce(self) { (value, update) in value.updated(update) }
    }
    func difference(from _model: TestCDModel) -> [Updates] {
        var updates = [Updates]()
        if id != _model.id { updates.append(.id(id)) }
        if index != _model.index { updates.append(.index(index)) }
        if name != _model.name { updates.append(.name(name)) }
        if count != _model.count { updates.append(.count(count)) }
        if someCount != _model.someCount { updates.append(.someCount(someCount)) }
        if urls != _model.urls { updates.append(.urls(urls)) }
        if subModel != _model.subModel { updates.append(.subModel(subModel)) }
        return updates
    }
}
// MARK: TestCDSimpleModel ObjectDiff
extension TestCDSimpleModel {

    enum Updates: DictionaryElementRepresentable {
        case title(String)
        case count(Int)
        var key: String {
            switch self {
                case .title: return "title"
                case .count: return "count"
            }
        }
        var value: Any? {
            switch self {
            case .title(let newValue): return newValue
            case .count(let newValue): return newValue
            }
        }
        init?(key: String, value: Any?) {
            switch key {
            case "title":
                if let value = value as? String {
                    self = .title(value)
                } else { return nil }
            case "count":
                if let value = value as? Int {
                    self = .count(value)
                } else { return nil }
            default: return nil
            }
        }
    }

    static func updatesDict(_ _updates: [Updates]) -> [String: Any] {
        var dict = [String: Any]()
        _updates.forEach { dict[$0.key] = $0.value }
        return dict
    }

    func allUpdates() -> [Updates] {
        var updates = [Updates]()
        updates.append(.title(title))
        updates.append(.count(count))
        return updates
    }

    func updated(_ _updates: [String: Any]) -> TestCDSimpleModel {
        guard let updates = [Updates].init(dictionary: _updates) else { return self }
        return updated(updates)
    }
    func updated(_ _update: Updates) -> TestCDSimpleModel {
        switch _update {
            case .title(let newValue):
                return TestCDSimpleModel.titleLens.set(newValue, self)
            case .count(let newValue):
                return TestCDSimpleModel.countLens.set(newValue, self)
        }
    }
    func updated(_ _updates: [Updates]) -> TestCDSimpleModel {
        return _updates.reduce(self) { (value, update) in value.updated(update) }
    }
    func difference(from _model: TestCDSimpleModel) -> [Updates] {
        var updates = [Updates]()
        if title != _model.title { updates.append(.title(title)) }
        if count != _model.count { updates.append(.count(count)) }
        return updates
    }
}
// MARK: TestCollectionsModel ObjectDiff
extension TestCollectionsModel {

    enum Updates: DictionaryElementRepresentable {
        case id(Int)
        case strings([String])
        case intValues([Int64?]?)
        case doubleValues([Double]?)
        case dates([Date]?)
        case codable([SomeCodable])
        case urls(Array<URL?>)
        case dict([Int: SomeCodable])
        case anotherDict([SomeCodable: Int])
        case set(Set<URL?>)
        case anotherSet(Set<SomeCodable>?)
        var key: String {
            switch self {
                case .id: return "id"
                case .strings: return "strings"
                case .intValues: return "intValues"
                case .doubleValues: return "doubleValues"
                case .dates: return "dates"
                case .codable: return "codable"
                case .urls: return "urls"
                case .dict: return "dict"
                case .anotherDict: return "anotherDict"
                case .set: return "set"
                case .anotherSet: return "anotherSet"
            }
        }
        var value: Any? {
            switch self {
            case .id(let newValue): return newValue
            case .strings(let newValue): return newValue
            case .intValues(let newValue): return newValue
            case .doubleValues(let newValue): return newValue
            case .dates(let newValue): return newValue
            case .codable(let newValue): return newValue
            case .urls(let newValue): return newValue
            case .dict(let newValue): return newValue
            case .anotherDict(let newValue): return newValue
            case .set(let newValue): return newValue
            case .anotherSet(let newValue): return newValue
            }
        }
        init?(key: String, value: Any?) {
            switch key {
            case "id":
                if let value = value as? Int {
                    self = .id(value)
                } else { return nil }
            case "strings":
                if let value = value as? [String] {
                    self = .strings(value)
                } else { return nil }
            case "intValues":
                if let value = value as? [Int64?]? {
                    self = .intValues(value)
                } else { return nil }
            case "doubleValues":
                if let value = value as? [Double]? {
                    self = .doubleValues(value)
                } else { return nil }
            case "dates":
                if let value = value as? [Date]? {
                    self = .dates(value)
                } else { return nil }
            case "codable":
                if let value = value as? [SomeCodable] {
                    self = .codable(value)
                } else { return nil }
            case "urls":
                if let value = value as? Array<URL?> {
                    self = .urls(value)
                } else { return nil }
            case "dict":
                if let value = value as? [Int: SomeCodable] {
                    self = .dict(value)
                } else { return nil }
            case "anotherDict":
                if let value = value as? [SomeCodable: Int] {
                    self = .anotherDict(value)
                } else { return nil }
            case "set":
                if let value = value as? Set<URL?> {
                    self = .set(value)
                } else { return nil }
            case "anotherSet":
                if let value = value as? Set<SomeCodable>? {
                    self = .anotherSet(value)
                } else { return nil }
            default: return nil
            }
        }
    }

    static func updatesDict(_ _updates: [Updates]) -> [String: Any] {
        var dict = [String: Any]()
        _updates.forEach { dict[$0.key] = $0.value }
        return dict
    }

    func allUpdates() -> [Updates] {
        var updates = [Updates]()
        updates.append(.id(id))
        updates.append(.strings(strings))
        updates.append(.intValues(intValues))
        updates.append(.doubleValues(doubleValues))
        updates.append(.dates(dates))
        updates.append(.codable(codable))
        updates.append(.urls(urls))
        updates.append(.dict(dict))
        updates.append(.anotherDict(anotherDict))
        updates.append(.set(set))
        updates.append(.anotherSet(anotherSet))
        return updates
    }

    func updated(_ _updates: [String: Any]) -> TestCollectionsModel {
        guard let updates = [Updates].init(dictionary: _updates) else { return self }
        return updated(updates)
    }
    func updated(_ _update: Updates) -> TestCollectionsModel {
        switch _update {
            case .id(let newValue):
                return TestCollectionsModel.idLens.set(newValue, self)
            case .strings(let newValue):
                return TestCollectionsModel.stringsLens.set(newValue, self)
            case .intValues(let newValue):
                return TestCollectionsModel.intValuesLens.set(newValue, self)
            case .doubleValues(let newValue):
                return TestCollectionsModel.doubleValuesLens.set(newValue, self)
            case .dates(let newValue):
                return TestCollectionsModel.datesLens.set(newValue, self)
            case .codable(let newValue):
                return TestCollectionsModel.codableLens.set(newValue, self)
            case .urls(let newValue):
                return TestCollectionsModel.urlsLens.set(newValue, self)
            case .dict(let newValue):
                return TestCollectionsModel.dictLens.set(newValue, self)
            case .anotherDict(let newValue):
                return TestCollectionsModel.anotherDictLens.set(newValue, self)
            case .set(let newValue):
                return TestCollectionsModel.setLens.set(newValue, self)
            case .anotherSet(let newValue):
                return TestCollectionsModel.anotherSetLens.set(newValue, self)
        }
    }
    func updated(_ _updates: [Updates]) -> TestCollectionsModel {
        return _updates.reduce(self) { (value, update) in value.updated(update) }
    }
    func difference(from _model: TestCollectionsModel) -> [Updates] {
        var updates = [Updates]()
        if id != _model.id { updates.append(.id(id)) }
        if strings != _model.strings { updates.append(.strings(strings)) }
        if intValues != _model.intValues { updates.append(.intValues(intValues)) }
        if doubleValues != _model.doubleValues { updates.append(.doubleValues(doubleValues)) }
        if dates != _model.dates { updates.append(.dates(dates)) }
        if codable != _model.codable { updates.append(.codable(codable)) }
        if urls != _model.urls { updates.append(.urls(urls)) }
        if dict != _model.dict { updates.append(.dict(dict)) }
        if anotherDict != _model.anotherDict { updates.append(.anotherDict(anotherDict)) }
        if set != _model.set { updates.append(.set(set)) }
        if anotherSet != _model.anotherSet { updates.append(.anotherSet(anotherSet)) }
        return updates
    }
}
// MARK: TestModel ObjectDiff
extension TestModel {

    enum Updates: DictionaryElementRepresentable {
        case id(Int)
        case index(Int?)
        case name(String)
        case count(Int)
        case someCount(Int)
        case urls([URL]?)
        case someModel(TestSomeModel?)
        var key: String {
            switch self {
                case .id: return "id"
                case .index: return "index"
                case .name: return "name"
                case .count: return "count"
                case .someCount: return "someCount"
                case .urls: return "urls"
                case .someModel: return "someModel"
            }
        }
        var value: Any? {
            switch self {
            case .id(let newValue): return newValue
            case .index(let newValue): return newValue
            case .name(let newValue): return newValue
            case .count(let newValue): return newValue
            case .someCount(let newValue): return newValue
            case .urls(let newValue): return newValue
            case .someModel(let newValue): return newValue
            }
        }
        init?(key: String, value: Any?) {
            switch key {
            case "id":
                if let value = value as? Int {
                    self = .id(value)
                } else { return nil }
            case "index":
                if let value = value as? Int? {
                    self = .index(value)
                } else { return nil }
            case "name":
                if let value = value as? String {
                    self = .name(value)
                } else { return nil }
            case "count":
                if let value = value as? Int {
                    self = .count(value)
                } else { return nil }
            case "someCount":
                if let value = value as? Int {
                    self = .someCount(value)
                } else { return nil }
            case "urls":
                if let value = value as? [URL]? {
                    self = .urls(value)
                } else { return nil }
            case "someModel":
                if let value = value as? TestSomeModel? {
                    self = .someModel(value)
                } else { return nil }
            default: return nil
            }
        }
    }

    static func updatesDict(_ _updates: [Updates]) -> [String: Any] {
        var dict = [String: Any]()
        _updates.forEach { dict[$0.key] = $0.value }
        return dict
    }

    func allUpdates() -> [Updates] {
        var updates = [Updates]()
        updates.append(.id(id))
        updates.append(.index(index))
        updates.append(.name(name))
        updates.append(.count(count))
        updates.append(.someCount(someCount))
        updates.append(.urls(urls))
        updates.append(.someModel(someModel))
        return updates
    }

    func updated(_ _updates: [String: Any]) -> TestModel {
        guard let updates = [Updates].init(dictionary: _updates) else { return self }
        return updated(updates)
    }
    func updated(_ _update: Updates) -> TestModel {
        switch _update {
            case .id(let newValue):
                return TestModel.idLens.set(newValue, self)
            case .index(let newValue):
                return TestModel.indexLens.set(newValue, self)
            case .name(let newValue):
                return TestModel.nameLens.set(newValue, self)
            case .count(let newValue):
                return TestModel.countLens.set(newValue, self)
            case .someCount(let newValue):
                return TestModel.someCountLens.set(newValue, self)
            case .urls(let newValue):
                return TestModel.urlsLens.set(newValue, self)
            case .someModel(let newValue):
                return TestModel.someModelLens.set(newValue, self)
        }
    }
    func updated(_ _updates: [Updates]) -> TestModel {
        return _updates.reduce(self) { (value, update) in value.updated(update) }
    }
    func difference(from _model: TestModel) -> [Updates] {
        var updates = [Updates]()
        if id != _model.id { updates.append(.id(id)) }
        if index != _model.index { updates.append(.index(index)) }
        if name != _model.name { updates.append(.name(name)) }
        if count != _model.count { updates.append(.count(count)) }
        if someCount != _model.someCount { updates.append(.someCount(someCount)) }
        if urls != _model.urls { updates.append(.urls(urls)) }
        if someModel != _model.someModel { updates.append(.someModel(someModel)) }
        return updates
    }
}
// MARK: TestRRModel ObjectDiff
extension TestRRModel {

    enum Updates: DictionaryElementRepresentable {
        case id(Int)
        case name(String)
        case owner(TestSomeModel?)
        case users(Relation<TestRRModel>)
        var key: String {
            switch self {
                case .id: return "id"
                case .name: return "name"
                case .owner: return "owner"
                case .users: return "users"
            }
        }
        var value: Any? {
            switch self {
            case .id(let newValue): return newValue
            case .name(let newValue): return newValue
            case .owner(let newValue): return newValue
            case .users(let newValue): return newValue
            }
        }
        init?(key: String, value: Any?) {
            switch key {
            case "id":
                if let value = value as? Int {
                    self = .id(value)
                } else { return nil }
            case "name":
                if let value = value as? String {
                    self = .name(value)
                } else { return nil }
            case "owner":
                if let value = value as? TestSomeModel? {
                    self = .owner(value)
                } else { return nil }
            case "users":
                if let value = value as? Relation<TestRRModel> {
                    self = .users(value)
                } else { return nil }
            default: return nil
            }
        }
    }

    static func updatesDict(_ _updates: [Updates]) -> [String: Any] {
        var dict = [String: Any]()
        _updates.forEach { dict[$0.key] = $0.value }
        return dict
    }

    func allUpdates() -> [Updates] {
        var updates = [Updates]()
        updates.append(.id(id))
        updates.append(.name(name))
        updates.append(.owner(owner))
        updates.append(.users(users))
        return updates
    }

    func updated(_ _updates: [String: Any]) -> TestRRModel {
        guard let updates = [Updates].init(dictionary: _updates) else { return self }
        return updated(updates)
    }
    func updated(_ _update: Updates) -> TestRRModel {
        switch _update {
            case .id(let newValue):
                return TestRRModel.idLens.set(newValue, self)
            case .name(let newValue):
                return TestRRModel.nameLens.set(newValue, self)
            case .owner(let newValue):
                return TestRRModel.ownerLens.set(newValue, self)
            case .users(let newValue):
                return TestRRModel.usersLens.set(newValue, self)
        }
    }
    func updated(_ _updates: [Updates]) -> TestRRModel {
        return _updates.reduce(self) { (value, update) in value.updated(update) }
    }
    func difference(from _model: TestRRModel) -> [Updates] {
        var updates = [Updates]()
        if id != _model.id { updates.append(.id(id)) }
        if name != _model.name { updates.append(.name(name)) }
        if owner != _model.owner { updates.append(.owner(owner)) }
        if users != _model.users { updates.append(.users(users)) }
        return updates
    }
}
// MARK: TestSimpleModel ObjectDiff
extension TestSimpleModel {

    enum Updates: DictionaryElementRepresentable {
        case title(String)
        case count(Int)
        var key: String {
            switch self {
                case .title: return "title"
                case .count: return "count"
            }
        }
        var value: Any? {
            switch self {
            case .title(let newValue): return newValue
            case .count(let newValue): return newValue
            }
        }
        init?(key: String, value: Any?) {
            switch key {
            case "title":
                if let value = value as? String {
                    self = .title(value)
                } else { return nil }
            case "count":
                if let value = value as? Int {
                    self = .count(value)
                } else { return nil }
            default: return nil
            }
        }
    }

    static func updatesDict(_ _updates: [Updates]) -> [String: Any] {
        var dict = [String: Any]()
        _updates.forEach { dict[$0.key] = $0.value }
        return dict
    }

    func allUpdates() -> [Updates] {
        var updates = [Updates]()
        updates.append(.title(title))
        updates.append(.count(count))
        return updates
    }

    func updated(_ _updates: [String: Any]) -> TestSimpleModel {
        guard let updates = [Updates].init(dictionary: _updates) else { return self }
        return updated(updates)
    }
    func updated(_ _update: Updates) -> TestSimpleModel {
        switch _update {
            case .title(let newValue):
                return TestSimpleModel.titleLens.set(newValue, self)
            case .count(let newValue):
                return TestSimpleModel.countLens.set(newValue, self)
        }
    }
    func updated(_ _updates: [Updates]) -> TestSimpleModel {
        return _updates.reduce(self) { (value, update) in value.updated(update) }
    }
    func difference(from _model: TestSimpleModel) -> [Updates] {
        var updates = [Updates]()
        if title != _model.title { updates.append(.title(title)) }
        if count != _model.count { updates.append(.count(count)) }
        return updates
    }
}
// MARK: TestSomeModel ObjectDiff
extension TestSomeModel {

    enum Updates: DictionaryElementRepresentable {
        case userId(Int)
        case userName(String)
        case userAvatar(String)
        case title(String?)
        case count(Int)
        case inverseModel(Relation<TestRRModel>)
        case directModels(Relation<TestRRModel>)
        case nestedModel(TestNestedModel?)
        var key: String {
            switch self {
                case .userId: return "userId"
                case .userName: return "userName"
                case .userAvatar: return "userAvatar"
                case .title: return "title"
                case .count: return "count"
                case .inverseModel: return "inverseModel"
                case .directModels: return "directModels"
                case .nestedModel: return "nestedModel"
            }
        }
        var value: Any? {
            switch self {
            case .userId(let newValue): return newValue
            case .userName(let newValue): return newValue
            case .userAvatar(let newValue): return newValue
            case .title(let newValue): return newValue
            case .count(let newValue): return newValue
            case .inverseModel(let newValue): return newValue
            case .directModels(let newValue): return newValue
            case .nestedModel(let newValue): return newValue
            }
        }
        init?(key: String, value: Any?) {
            switch key {
            case "userId":
                if let value = value as? Int {
                    self = .userId(value)
                } else { return nil }
            case "userName":
                if let value = value as? String {
                    self = .userName(value)
                } else { return nil }
            case "userAvatar":
                if let value = value as? String {
                    self = .userAvatar(value)
                } else { return nil }
            case "title":
                if let value = value as? String? {
                    self = .title(value)
                } else { return nil }
            case "count":
                if let value = value as? Int {
                    self = .count(value)
                } else { return nil }
            case "inverseModel":
                if let value = value as? Relation<TestRRModel> {
                    self = .inverseModel(value)
                } else { return nil }
            case "directModels":
                if let value = value as? Relation<TestRRModel> {
                    self = .directModels(value)
                } else { return nil }
            case "nestedModel":
                if let value = value as? TestNestedModel? {
                    self = .nestedModel(value)
                } else { return nil }
            default: return nil
            }
        }
    }

    static func updatesDict(_ _updates: [Updates]) -> [String: Any] {
        var dict = [String: Any]()
        _updates.forEach { dict[$0.key] = $0.value }
        return dict
    }

    func allUpdates() -> [Updates] {
        var updates = [Updates]()
        updates.append(.userId(userId))
        updates.append(.userName(userName))
        updates.append(.userAvatar(userAvatar))
        updates.append(.title(title))
        updates.append(.count(count))
        updates.append(.inverseModel(inverseModel))
        updates.append(.directModels(directModels))
        updates.append(.nestedModel(nestedModel))
        return updates
    }

    func updated(_ _updates: [String: Any]) -> TestSomeModel {
        guard let updates = [Updates].init(dictionary: _updates) else { return self }
        return updated(updates)
    }
    func updated(_ _update: Updates) -> TestSomeModel {
        switch _update {
            case .userId(let newValue):
                return TestSomeModel.userIdLens.set(newValue, self)
            case .userName(let newValue):
                return TestSomeModel.userNameLens.set(newValue, self)
            case .userAvatar(let newValue):
                return TestSomeModel.userAvatarLens.set(newValue, self)
            case .title(let newValue):
                return TestSomeModel.titleLens.set(newValue, self)
            case .count(let newValue):
                return TestSomeModel.countLens.set(newValue, self)
            case .inverseModel(let newValue):
                return TestSomeModel.inverseModelLens.set(newValue, self)
            case .directModels(let newValue):
                return TestSomeModel.directModelsLens.set(newValue, self)
            case .nestedModel(let newValue):
                return TestSomeModel.nestedModelLens.set(newValue, self)
        }
    }
    func updated(_ _updates: [Updates]) -> TestSomeModel {
        return _updates.reduce(self) { (value, update) in value.updated(update) }
    }
    func difference(from _model: TestSomeModel) -> [Updates] {
        var updates = [Updates]()
        if userId != _model.userId { updates.append(.userId(userId)) }
        if userName != _model.userName { updates.append(.userName(userName)) }
        if userAvatar != _model.userAvatar { updates.append(.userAvatar(userAvatar)) }
        if title != _model.title { updates.append(.title(title)) }
        if count != _model.count { updates.append(.count(count)) }
        if inverseModel != _model.inverseModel { updates.append(.inverseModel(inverseModel)) }
        if directModels != _model.directModels { updates.append(.directModels(directModels)) }
        if nestedModel != _model.nestedModel { updates.append(.nestedModel(nestedModel)) }
        return updates
    }
}
