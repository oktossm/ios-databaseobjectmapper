//
// Created by Mikhail Mulyar on 20/12/2017.
// Copyright (c) 2017 Mikhail Mulyar. All rights reserved.
//

import CoreData
import RealmSwift


public enum PrimaryKeyValue {
    case none
    case int(value: Int, key: String)
    case string(value: String, key: String)

    var value: Any? {
        switch self {
        case .none: return nil
        case .int(let val, _): return val
        case .string(let val, _): return val
        }
    }

    var key: String {
        switch self {
        case .none: return ""
        case .int(_, let key): return key
        case .string(_, let key): return key
        }
    }
}

extension PrimaryKeyValue: Hashable {
    public var hashValue: Int {
        switch self {
        case .none:
            return 1.hashValue
        case .int(let data):
            let hash = 2
            let valHash = data.value.hashValue
            let keyHash = data.key.hashValue
            return hash ^ valHash ^ keyHash
        case .string(let data):
            let hash = 3
            let valHash = data.value.hashValue
            let keyHash = data.key.hashValue
            return hash ^ valHash ^ keyHash
        }
    }
}


extension PrimaryKeyValue: Equatable {}
public func == (lhs: PrimaryKeyValue, rhs: PrimaryKeyValue) -> Bool {
    switch (lhs, rhs) {
    case (.none, .none):
        return true
    case (.int(let lhs), .int(let rhs)):
        if lhs.value != rhs.value { return false }
        if lhs.key != rhs.key { return false }
        return true
    case (.string(let lhs), .string(let rhs)):
        if lhs.value != rhs.value { return false }
        if lhs.key != rhs.key { return false }
        return true
    default: return false
    }
}


public protocol DatabaseTypeProtocol {
    /// `Data` stored in DatabaseType for `DatabaseMappable` decoding.
    var encoded: Data { get set }
}


public protocol DatabasePropertyUpdates {
    /// Dictionary representation of updates. Keys and values for properties to be updated
    func dictionaryRepresentation() -> [String: Any?]
}


/// A type that is able to be saved to a database by mapping to database object.
/// Any type conforming to this protocol must also conform to the `Codable` protocol so that it can be converted to and from `JSON`.
public protocol DatabaseMappable: Codable {

    associatedtype DatabaseType: DatabaseTypeProtocol
    associatedtype DatabaseUpdates: DatabasePropertyUpdates

    static func databaseType() -> DatabaseType.Type

    /// The primary key of the instance. This used when retrieving values from a database.
    static var primaryKeyPath: String { get }
    var primaryKey: PrimaryKeyValue { get }

    /// The primary key value. This used when retrieving values from a database.
    static func primaryKeyValue(for primaryKey: PrimaryKeyValue) -> Any?

    /// Creates an instance of a `DatabaseType` type from a `DatabaseMappable`.
    /// - parameter userInfo: User info can be passed here.
    func createObject(userInfo: Any?) throws -> DatabaseType

    /// Creates an instance of a `DatabaseMappable` type from a `DatabaseType`.
    /// - parameter object: DatabaseType that stores the encoded type.
    static func createMappable(from object: DatabaseType) throws -> Self

    /// Creates an instance of a `DatabaseMappable` type from a `Data`.
    /// - parameter data: Data that stores the `JSON` encoded type.
    static func create(from data: Data) throws -> Self

    /// Creates a `Data` from a `DatabaseMappable` instance.
    func encoded() throws -> Data

    /// Returns a `Updates` for a `DatabaseMappable` instance.
    func allUpdates() -> DatabaseUpdates

    /// Updates an instance of a `DatabaseType` type using a `DatabaseUpdates`.
    /// - parameter object: DatabaseType that should be updated.
    /// - parameter primaryKey: PrimaryKeyValue of object.
    /// - parameter updates: DatabaseUpdates updates array.
    /// - parameter data: Data that stores the `JSON` encoded type.
    static func update(_ object: DatabaseType, primaryKey: PrimaryKeyValue, data: Data, updates: DatabaseUpdates)

    /// Used for type fetching for example in case when single DatabaseType can store multiple different types.
    static func internalPredicate() -> NSPredicate?
}


public extension DatabaseMappable {
    public static func create(from data: Data) throws -> Self {
        return try JSONDecoder().decode(Self.self, from: data)
    }

    public static func createMappable(from object: DatabaseType) throws -> Self {
        return try self.create(from: object.encoded)
    }

    public func encoded() throws -> Data {
        return try JSONEncoder().encode(self)
    }

    public static var primaryKeyPath: String {
        return ""
    }
    public var primaryKey: PrimaryKeyValue {
        return .none
    }

    public static func primaryKeyValue(for primaryKey: PrimaryKeyValue) -> Any? {
        return primaryKey.value
    }

    public func update(_ object: DatabaseType) {
        guard let data = try? self.encoded() else { return }
        Self.update(object, primaryKey: self.primaryKey, data: data, updates: self.allUpdates())
    }

    public func allRelationships() -> [DatabaseRelationshipUpdate] {
        return []
    }

    public static func internalPredicate() -> NSPredicate? {
        return nil
    }
}


public protocol DatabaseContainerProtocol: DatabaseTypeProtocol {
    /// Database container need to store `Data`, primaryKey `PrimaryKeyValue`, and typeName.
    func set(typeName: String, primaryKey: PrimaryKeyValue, data: Data)
}


extension DatabaseContainerProtocol {
    public static func primaryKeyValue(for typeName: String, primaryKeyType: PrimaryKeyValue) -> String {
        switch primaryKeyType {
        case .none:
            return typeName + UUID().uuidString
        case .int(let val, _):
            return typeName + String(val)
        case .string(let val, _):
            return typeName + val
        }
    }
}


public extension DatabaseMappable where DatabaseType: DatabaseContainerProtocol {
    public static func update(_ object: DatabaseType, primaryKey: PrimaryKeyValue, data: Data, updates: DatabaseUpdates) {
        object.set(typeName: Self.typeName, primaryKey: primaryKey, data: data)
    }

    public static func internalPredicate() -> NSPredicate? {
        return NSPredicate(format: "typeName == %@", argumentArray: [Self.typeName])
    }

    public static var typeName: String {
        return String(describing: Self.self)
    }
}
