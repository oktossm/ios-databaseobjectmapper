// Generated using Sourcery 0.12.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// MARK: - AutoObjectDiff
import Foundation

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
extension TestCDModel {

    enum Updates: DictionaryElementRepresentable {
        case id(Int)
        case index(Int?)
        case name(String)
        case count(Int)
        case superCount(Int)
        case urls([URL]?)
        case subModel(TestSubModel?)
        case children([TestModel]?)
        var key: String {
            switch self {
                case .id: return "id"
                case .index: return "index"
                case .name: return "name"
                case .count: return "count"
                case .superCount: return "superCount"
                case .urls: return "urls"
                case .subModel: return "subModel"
                case .children: return "children"
            }
        }
        var value: Any? {
            switch self {
            case .id(let newValue): return newValue
            case .index(let newValue): return newValue
            case .name(let newValue): return newValue
            case .count(let newValue): return newValue
            case .superCount(let newValue): return newValue
            case .urls(let newValue): return newValue
            case .subModel(let newValue): return newValue
            case .children(let newValue): return newValue
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
        updates.append(.superCount(superCount))
        updates.append(.urls(urls))
        updates.append(.subModel(subModel))
        updates.append(.children(children))
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
            case .superCount(let newValue):
                return TestCDModel.superCountLens.set(newValue, self)
            case .urls(let newValue):
                return TestCDModel.urlsLens.set(newValue, self)
            case .subModel(let newValue):
                return TestCDModel.subModelLens.set(newValue, self)
            case .children(let newValue):
                return TestCDModel.childrenLens.set(newValue, self)
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
        if superCount != _model.superCount { updates.append(.superCount(superCount)) }
        if compareOptionals(lhs: urls, rhs: _model.urls, compare: ==) == false { updates.append(.urls(urls)) }
        if compareOptionals(lhs: subModel, rhs: _model.subModel, compare: ==) == false { updates.append(.subModel(subModel)) }
        if compareOptionals(lhs: children, rhs: _model.children, compare: ==) == false { updates.append(.children(children)) }
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
        case superCount(Int)
        case urls([URL]?)
        case subModel(TestSubModel?)
        case children([TestModel]?)
        var key: String {
            switch self {
                case .id: return "id"
                case .index: return "index"
                case .name: return "name"
                case .count: return "count"
                case .superCount: return "superCount"
                case .urls: return "urls"
                case .subModel: return "subModel"
                case .children: return "children"
            }
        }
        var value: Any? {
            switch self {
            case .id(let newValue): return newValue
            case .index(let newValue): return newValue
            case .name(let newValue): return newValue
            case .count(let newValue): return newValue
            case .superCount(let newValue): return newValue
            case .urls(let newValue): return newValue
            case .subModel(let newValue): return newValue
            case .children(let newValue): return newValue
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
        updates.append(.superCount(superCount))
        updates.append(.urls(urls))
        updates.append(.subModel(subModel))
        updates.append(.children(children))
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
            case .superCount(let newValue):
                return TestModel.superCountLens.set(newValue, self)
            case .urls(let newValue):
                return TestModel.urlsLens.set(newValue, self)
            case .subModel(let newValue):
                return TestModel.subModelLens.set(newValue, self)
            case .children(let newValue):
                return TestModel.childrenLens.set(newValue, self)
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
        if superCount != _model.superCount { updates.append(.superCount(superCount)) }
        if compareOptionals(lhs: urls, rhs: _model.urls, compare: ==) == false { updates.append(.urls(urls)) }
        if compareOptionals(lhs: subModel, rhs: _model.subModel, compare: ==) == false { updates.append(.subModel(subModel)) }
        if compareOptionals(lhs: children, rhs: _model.children, compare: ==) == false { updates.append(.children(children)) }
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
// MARK: TestSubModel ObjectDiff
extension TestSubModel {

    enum Updates: DictionaryElementRepresentable {
        case userId(Int)
        case userName(String)
        case userAvatar(String)
        case title(String)
        case count(Int)
        var key: String {
            switch self {
                case .userId: return "userId"
                case .userName: return "userName"
                case .userAvatar: return "userAvatar"
                case .title: return "title"
                case .count: return "count"
            }
        }
        var value: Any? {
            switch self {
            case .userId(let newValue): return newValue
            case .userName(let newValue): return newValue
            case .userAvatar(let newValue): return newValue
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
        updates.append(.userId(userId))
        updates.append(.userName(userName))
        updates.append(.userAvatar(userAvatar))
        updates.append(.title(title))
        updates.append(.count(count))
        return updates
    }
    func updated(_ _update: Updates) -> TestSubModel {
        switch _update {
            case .userId(let newValue):
                return TestSubModel.userIdLens.set(newValue, self)
            case .userName(let newValue):
                return TestSubModel.userNameLens.set(newValue, self)
            case .userAvatar(let newValue):
                return TestSubModel.userAvatarLens.set(newValue, self)
            case .title(let newValue):
                return TestSubModel.titleLens.set(newValue, self)
            case .count(let newValue):
                return TestSubModel.countLens.set(newValue, self)
        }
    }
    func updated(_ _updates: [Updates]) -> TestSubModel {
        return _updates.reduce(self) { (value, update) in value.updated(update) }
    }
    func difference(from _model: TestSubModel) -> [Updates] {
        var updates = [Updates]()
        if userId != _model.userId { updates.append(.userId(userId)) }
        if userName != _model.userName { updates.append(.userName(userName)) }
        if userAvatar != _model.userAvatar { updates.append(.userAvatar(userAvatar)) }
        if title != _model.title { updates.append(.title(title)) }
        if count != _model.count { updates.append(.count(count)) }
        return updates
    }
}
