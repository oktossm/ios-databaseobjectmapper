// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// MARK: - AutoObjectDiff
import Foundation
import DatabaseObjectsMapper

// swiftlint:disable file_length
fileprivate func compareOptionals<T>(lhs: T?, rhs: T?, compare: (_ lhs: T, _ rhs: T) -> Bool) -> Bool {
    switch (lhs, rhs) {
    case let (lValue?, rValue?):
        return compare(lValue, rValue)
    case (nil, nil):
        return true
    default:
        return false
    }
}

fileprivate func compareArrays<T>(lhs: [T], rhs: [T], compare: (_ lhs: T, _ rhs: T) -> Bool) -> Bool {
    if lhs.isEmpty || rhs.isEmpty { return lhs.isEmpty == rhs.isEmpty }

    guard lhs.count == rhs.count else { return false }
    for (idx, lhsItem) in lhs.enumerated() {
        guard compare(lhsItem, rhs[idx]) else { return false }
    }

    return true
}

public protocol DictionaryElementRepresentable {
    var key: String { get }
    var value: Any? { get }
}

extension Array where Element: DictionaryElementRepresentable {
    public func dictionaryRepresentation() -> [String: Any?] {
        var dict = [String: Any?]()
        self.forEach { dict[$0.key] = $0.value }
        return dict
    }
}


// MARK: TestCDModel ObjectDiff
internal extension TestCDModel {

    enum Updates: DictionaryElementRepresentable {
        case id(Int)
        case index(Int?)
        case name(String)
        case count(Int)
        case someCount(Int)
        case urls([URL]?)
        case subModel(Relation<TestSomeModel>)
        internal var key: String {
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
        internal var value: Any? {
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
    }
    static func updatesDict(_ _updates: [Updates]) -> [String: Any?] {
        var dict = [String: Any?]()
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
        if compareOptionals(lhs: index, rhs: _model.index, compare: ==) == false { updates.append(.index(index)) }
        if name != _model.name { updates.append(.name(name)) }
        if count != _model.count { updates.append(.count(count)) }
        if someCount != _model.someCount { updates.append(.someCount(someCount)) }
        if compareOptionals(lhs: urls, rhs: _model.urls, compare: ==) == false { updates.append(.urls(urls)) }
        if subModel != _model.subModel { updates.append(.subModel(subModel)) }
        return updates
    }
}
// MARK: TestCDSimpleModel ObjectDiff
internal extension TestCDSimpleModel {

    enum Updates: DictionaryElementRepresentable {
        case title(String)
        case count(Int)
        internal var key: String {
            switch self {
                case .title: return "title"
                case .count: return "count"
            }
        }
        internal var value: Any? {
            switch self {
            case .title(let newValue): return newValue
            case .count(let newValue): return newValue
            }
        }
    }
    static func updatesDict(_ _updates: [Updates]) -> [String: Any?] {
        var dict = [String: Any?]()
        _updates.forEach { dict[$0.key] = $0.value }
        return dict
    }
    func allUpdates() -> [Updates] {
        var updates = [Updates]()
        updates.append(.title(title))
        updates.append(.count(count))
        return updates
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
internal extension TestCollectionsModel {

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
        case someEnum([SomeEnum])
        internal var key: String {
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
                case .someEnum: return "someEnum"
            }
        }
        internal var value: Any? {
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
            case .someEnum(let newValue): return newValue
            }
        }
    }
    static func updatesDict(_ _updates: [Updates]) -> [String: Any?] {
        var dict = [String: Any?]()
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
        updates.append(.someEnum(someEnum))
        return updates
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
            case .someEnum(let newValue):
                return TestCollectionsModel.someEnumLens.set(newValue, self)
        }
    }
    func updated(_ _updates: [Updates]) -> TestCollectionsModel {
        return _updates.reduce(self) { (value, update) in value.updated(update) }
    }
    func difference(from _model: TestCollectionsModel) -> [Updates] {
        var updates = [Updates]()
        if id != _model.id { updates.append(.id(id)) }
        if strings != _model.strings { updates.append(.strings(strings)) }
        if compareOptionals(lhs: intValues, rhs: _model.intValues, compare: ==) == false { updates.append(.intValues(intValues)) }
        if compareOptionals(lhs: doubleValues, rhs: _model.doubleValues, compare: ==) == false { updates.append(.doubleValues(doubleValues)) }
        if compareOptionals(lhs: dates, rhs: _model.dates, compare: ==) == false { updates.append(.dates(dates)) }
        if codable != _model.codable { updates.append(.codable(codable)) }
        if urls != _model.urls { updates.append(.urls(urls)) }
        if dict != _model.dict { updates.append(.dict(dict)) }
        if anotherDict != _model.anotherDict { updates.append(.anotherDict(anotherDict)) }
        if set != _model.set { updates.append(.set(set)) }
        if compareOptionals(lhs: anotherSet, rhs: _model.anotherSet, compare: ==) == false { updates.append(.anotherSet(anotherSet)) }
        if someEnum != _model.someEnum { updates.append(.someEnum(someEnum)) }
        return updates
    }
}
// MARK: TestDateModel ObjectDiff
internal extension TestDateModel {

    enum Updates: DictionaryElementRepresentable {
        case id(Int)
        case date(Date)
        internal var key: String {
            switch self {
                case .id: return "id"
                case .date: return "date"
            }
        }
        internal var value: Any? {
            switch self {
            case .id(let newValue): return newValue
            case .date(let newValue): return newValue
            }
        }
    }
    static func updatesDict(_ _updates: [Updates]) -> [String: Any?] {
        var dict = [String: Any?]()
        _updates.forEach { dict[$0.key] = $0.value }
        return dict
    }
    func allUpdates() -> [Updates] {
        var updates = [Updates]()
        updates.append(.id(id))
        updates.append(.date(date))
        return updates
    }
    func updated(_ _update: Updates) -> TestDateModel {
        switch _update {
            case .id(let newValue):
                return TestDateModel.idLens.set(newValue, self)
            case .date(let newValue):
                return TestDateModel.dateLens.set(newValue, self)
        }
    }
    func updated(_ _updates: [Updates]) -> TestDateModel {
        return _updates.reduce(self) { (value, update) in value.updated(update) }
    }
    func difference(from _model: TestDateModel) -> [Updates] {
        var updates = [Updates]()
        if id != _model.id { updates.append(.id(id)) }
        if date != _model.date { updates.append(.date(date)) }
        return updates
    }
}
// MARK: TestModel ObjectDiff
internal extension TestModel {

    enum Updates: DictionaryElementRepresentable {
        case id(Int)
        case index(Int?)
        case name(String)
        case count(Int)
        case someCount(Int)
        case urls([URL]?)
        case someModel(TestSomeModel?)
        internal var key: String {
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
        internal var value: Any? {
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
    }
    static func updatesDict(_ _updates: [Updates]) -> [String: Any?] {
        var dict = [String: Any?]()
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
        if compareOptionals(lhs: index, rhs: _model.index, compare: ==) == false { updates.append(.index(index)) }
        if name != _model.name { updates.append(.name(name)) }
        if count != _model.count { updates.append(.count(count)) }
        if someCount != _model.someCount { updates.append(.someCount(someCount)) }
        if compareOptionals(lhs: urls, rhs: _model.urls, compare: ==) == false { updates.append(.urls(urls)) }
        if compareOptionals(lhs: someModel, rhs: _model.someModel, compare: ==) == false { updates.append(.someModel(someModel)) }
        return updates
    }
}
// MARK: TestPrimitivesModel ObjectDiff
internal extension TestPrimitivesModel {

    enum Updates: DictionaryElementRepresentable {
        case id(Int)
        case value(Int32?)
        case doubleValue(Double)
        case floatValue(Float?)
        case boolValue(Bool?)
        case urlValue(URL?)
        case someEnum(SomeEnum)
        case someEnumOpt(SomeEnum?)
        case stringEnum(SomeStringEnum)
        case stringEnumOpt(SomeStringEnum?)
        internal var key: String {
            switch self {
                case .id: return "id"
                case .value: return "value"
                case .doubleValue: return "doubleValue"
                case .floatValue: return "floatValue"
                case .boolValue: return "boolValue"
                case .urlValue: return "urlValue"
                case .someEnum: return "someEnum"
                case .someEnumOpt: return "someEnumOpt"
                case .stringEnum: return "stringEnum"
                case .stringEnumOpt: return "stringEnumOpt"
            }
        }
        internal var value: Any? {
            switch self {
            case .id(let newValue): return newValue
            case .value(let newValue): return newValue
            case .doubleValue(let newValue): return newValue
            case .floatValue(let newValue): return newValue
            case .boolValue(let newValue): return newValue
            case .urlValue(let newValue): return newValue
            case .someEnum(let newValue): return newValue
            case .someEnumOpt(let newValue): return newValue
            case .stringEnum(let newValue): return newValue
            case .stringEnumOpt(let newValue): return newValue
            }
        }
    }
    static func updatesDict(_ _updates: [Updates]) -> [String: Any?] {
        var dict = [String: Any?]()
        _updates.forEach { dict[$0.key] = $0.value }
        return dict
    }
    func allUpdates() -> [Updates] {
        var updates = [Updates]()
        updates.append(.id(id))
        updates.append(.value(value))
        updates.append(.doubleValue(doubleValue))
        updates.append(.floatValue(floatValue))
        updates.append(.boolValue(boolValue))
        updates.append(.urlValue(urlValue))
        updates.append(.someEnum(someEnum))
        updates.append(.someEnumOpt(someEnumOpt))
        updates.append(.stringEnum(stringEnum))
        updates.append(.stringEnumOpt(stringEnumOpt))
        return updates
    }
    func updated(_ _update: Updates) -> TestPrimitivesModel {
        switch _update {
            case .id(let newValue):
                return TestPrimitivesModel.idLens.set(newValue, self)
            case .value(let newValue):
                return TestPrimitivesModel.valueLens.set(newValue, self)
            case .doubleValue(let newValue):
                return TestPrimitivesModel.doubleValueLens.set(newValue, self)
            case .floatValue(let newValue):
                return TestPrimitivesModel.floatValueLens.set(newValue, self)
            case .boolValue(let newValue):
                return TestPrimitivesModel.boolValueLens.set(newValue, self)
            case .urlValue(let newValue):
                return TestPrimitivesModel.urlValueLens.set(newValue, self)
            case .someEnum(let newValue):
                return TestPrimitivesModel.someEnumLens.set(newValue, self)
            case .someEnumOpt(let newValue):
                return TestPrimitivesModel.someEnumOptLens.set(newValue, self)
            case .stringEnum(let newValue):
                return TestPrimitivesModel.stringEnumLens.set(newValue, self)
            case .stringEnumOpt(let newValue):
                return TestPrimitivesModel.stringEnumOptLens.set(newValue, self)
        }
    }
    func updated(_ _updates: [Updates]) -> TestPrimitivesModel {
        return _updates.reduce(self) { (value, update) in value.updated(update) }
    }
    func difference(from _model: TestPrimitivesModel) -> [Updates] {
        var updates = [Updates]()
        if id != _model.id { updates.append(.id(id)) }
        if compareOptionals(lhs: value, rhs: _model.value, compare: ==) == false { updates.append(.value(value)) }
        if doubleValue != _model.doubleValue { updates.append(.doubleValue(doubleValue)) }
        if compareOptionals(lhs: floatValue, rhs: _model.floatValue, compare: ==) == false { updates.append(.floatValue(floatValue)) }
        if compareOptionals(lhs: boolValue, rhs: _model.boolValue, compare: ==) == false { updates.append(.boolValue(boolValue)) }
        if compareOptionals(lhs: urlValue, rhs: _model.urlValue, compare: ==) == false { updates.append(.urlValue(urlValue)) }
        if someEnum != _model.someEnum { updates.append(.someEnum(someEnum)) }
        if compareOptionals(lhs: someEnumOpt, rhs: _model.someEnumOpt, compare: ==) == false { updates.append(.someEnumOpt(someEnumOpt)) }
        if stringEnum != _model.stringEnum { updates.append(.stringEnum(stringEnum)) }
        if compareOptionals(lhs: stringEnumOpt, rhs: _model.stringEnumOpt, compare: ==) == false { updates.append(.stringEnumOpt(stringEnumOpt)) }
        return updates
    }
}
// MARK: TestRNModel ObjectDiff
internal extension TestRNModel {

    enum Updates: DictionaryElementRepresentable {
        case id(Int)
        case name(String)
        case owner(TestSomeModel)
        internal var key: String {
            switch self {
                case .id: return "id"
                case .name: return "name"
                case .owner: return "owner"
            }
        }
        internal var value: Any? {
            switch self {
            case .id(let newValue): return newValue
            case .name(let newValue): return newValue
            case .owner(let newValue): return newValue
            }
        }
    }
    static func updatesDict(_ _updates: [Updates]) -> [String: Any?] {
        var dict = [String: Any?]()
        _updates.forEach { dict[$0.key] = $0.value }
        return dict
    }
    func allUpdates() -> [Updates] {
        var updates = [Updates]()
        updates.append(.id(id))
        updates.append(.name(name))
        updates.append(.owner(owner))
        return updates
    }
    func updated(_ _update: Updates) -> TestRNModel {
        switch _update {
            case .id(let newValue):
                return TestRNModel.idLens.set(newValue, self)
            case .name(let newValue):
                return TestRNModel.nameLens.set(newValue, self)
            case .owner(let newValue):
                return TestRNModel.ownerLens.set(newValue, self)
        }
    }
    func updated(_ _updates: [Updates]) -> TestRNModel {
        return _updates.reduce(self) { (value, update) in value.updated(update) }
    }
    func difference(from _model: TestRNModel) -> [Updates] {
        var updates = [Updates]()
        if id != _model.id { updates.append(.id(id)) }
        if name != _model.name { updates.append(.name(name)) }
        if owner != _model.owner { updates.append(.owner(owner)) }
        return updates
    }
}
// MARK: TestRRModel ObjectDiff
internal extension TestRRModel {

    enum Updates: DictionaryElementRepresentable {
        case id(Int)
        case name(String)
        case owner(TestSomeModel?)
        internal var key: String {
            switch self {
                case .id: return "id"
                case .name: return "name"
                case .owner: return "owner"
            }
        }
        internal var value: Any? {
            switch self {
            case .id(let newValue): return newValue
            case .name(let newValue): return newValue
            case .owner(let newValue): return newValue
            }
        }
    }
    static func updatesDict(_ _updates: [Updates]) -> [String: Any?] {
        var dict = [String: Any?]()
        _updates.forEach { dict[$0.key] = $0.value }
        return dict
    }
    func allUpdates() -> [Updates] {
        var updates = [Updates]()
        updates.append(.id(id))
        updates.append(.name(name))
        updates.append(.owner(owner))
        return updates
    }
    func updated(_ _update: Updates) -> TestRRModel {
        switch _update {
            case .id(let newValue):
                return TestRRModel.idLens.set(newValue, self)
            case .name(let newValue):
                return TestRRModel.nameLens.set(newValue, self)
            case .owner(let newValue):
                return TestRRModel.ownerLens.set(newValue, self)
        }
    }
    func updated(_ _updates: [Updates]) -> TestRRModel {
        return _updates.reduce(self) { (value, update) in value.updated(update) }
    }
    func difference(from _model: TestRRModel) -> [Updates] {
        var updates = [Updates]()
        if id != _model.id { updates.append(.id(id)) }
        if name != _model.name { updates.append(.name(name)) }
        if compareOptionals(lhs: owner, rhs: _model.owner, compare: ==) == false { updates.append(.owner(owner)) }
        return updates
    }
}
// MARK: TestSimpleModel ObjectDiff
internal extension TestSimpleModel {

    enum Updates: DictionaryElementRepresentable {
        case title(String)
        case count(Int)
        internal var key: String {
            switch self {
                case .title: return "title"
                case .count: return "count"
            }
        }
        internal var value: Any? {
            switch self {
            case .title(let newValue): return newValue
            case .count(let newValue): return newValue
            }
        }
    }
    static func updatesDict(_ _updates: [Updates]) -> [String: Any?] {
        var dict = [String: Any?]()
        _updates.forEach { dict[$0.key] = $0.value }
        return dict
    }
    func allUpdates() -> [Updates] {
        var updates = [Updates]()
        updates.append(.title(title))
        updates.append(.count(count))
        return updates
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
internal extension TestSomeModel {

    enum Updates: DictionaryElementRepresentable {
        case userId(Int)
        case userName(String)
        case userAvatar(String)
        case title(String?)
        case count(Int)
        case nestedModel(TestNestedModel?)
        internal var key: String {
            switch self {
                case .userId: return "userId"
                case .userName: return "userName"
                case .userAvatar: return "userAvatar"
                case .title: return "title"
                case .count: return "count"
                case .nestedModel: return "nestedModel"
            }
        }
        internal var value: Any? {
            switch self {
            case .userId(let newValue): return newValue
            case .userName(let newValue): return newValue
            case .userAvatar(let newValue): return newValue
            case .title(let newValue): return newValue
            case .count(let newValue): return newValue
            case .nestedModel(let newValue): return newValue
            }
        }
    }
    static func updatesDict(_ _updates: [Updates]) -> [String: Any?] {
        var dict = [String: Any?]()
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
        updates.append(.nestedModel(nestedModel))
        return updates
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
        if compareOptionals(lhs: title, rhs: _model.title, compare: ==) == false { updates.append(.title(title)) }
        if count != _model.count { updates.append(.count(count)) }
        if compareOptionals(lhs: nestedModel, rhs: _model.nestedModel, compare: ==) == false { updates.append(.nestedModel(nestedModel)) }
        return updates
    }
}

