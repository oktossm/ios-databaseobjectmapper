//
// Created by Mikhail Mulyar on 20/12/2017.
// Copyright (c) 2017 Mikhail Mulyar. All rights reserved.
//

import CoreData
import RealmSwift


public enum PrimaryKeyContainer: Equatable, Hashable {
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


public protocol DatabaseTypeProtocol {
    /// `Data` stored in DatabaseType for `DatabaseMappable` decoding.
    var encoded: Data { get set }

    /// The primary key path. This used when retrieving values from a database.
    static var primaryKeyPath: String? { get }

    /// The primary key mapped value. This used when retrieving values from a database. Database type can modify primary key before using it.
    /// For example default containers add type name to store objects of different types.
    /// Default implementation returns non modified key
    static func primaryKeyMapping(for type: String, primaryKey: PrimaryKeyContainer) -> PrimaryKeyContainer
}


public extension DatabaseTypeProtocol {
    static var primaryKeyPath: String {
        return "id"
    }

    static func primaryKeyMapping(for type: String, primaryKey: PrimaryKeyContainer) -> PrimaryKeyContainer {
        return primaryKey
    }
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
    var primaryKey: PrimaryKeyContainer { get }

    /// Creates an instance of a `DatabaseType` type from a `DatabaseMappable`.
    /// - parameter userInfo: User info can be passed here.
    func createObject(userInfo: Any?) throws -> DatabaseType

    /// Creates an instance of a `DatabaseMappable` type from a `DatabaseType`.
    /// - parameter object: DatabaseType that stores the encoded type.
    static func createMappable(from object: DatabaseType) throws -> Self

    /// Creates an instance of a `DatabaseMappable` type from a `Data`.
    /// - parameter data: Data that stores the `JSON` encoded type.
    static func create(from data: Data) throws -> Self

    /// Returns `Data` for `DatabaseMappable` instance.
    func encoded() throws -> Data

    /// Returns `Updates` for `DatabaseMappable` instance.
    func allUpdates() -> DatabaseUpdates

    /// Returns updated self.
    func updated(_ _updates: DatabaseUpdates) -> Self

    /// Updates an instance of a `DatabaseType` type using a `DatabaseUpdates`.
    /// - parameter object: DatabaseType that should be updated.
    /// - parameter primaryKey: PrimaryKeyValue of object.
    /// - parameter updates: DatabaseUpdates updates array.
    /// - parameter data: Data that stores the `JSON` encoded type.
    func update(_ object: DatabaseType, primaryKey: PrimaryKeyContainer, data: Data, updates: DatabaseUpdates)

    /// Used for type fetching for example in case when single DatabaseType can store multiple different types (used by DatabaseContainerProtocol).
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

    public var primaryKey: PrimaryKeyContainer {
        return .none
    }

    var primaryKeyValue: PrimaryKeyContainer {
        return Self.primaryKeyMapped(for: self.primaryKey)
    }

    static func primaryKeyMapped(for primaryKey: PrimaryKeyContainer) -> PrimaryKeyContainer {
        return Self.DatabaseType.primaryKeyMapping(for: self.typeName, primaryKey: primaryKey)
    }

    public func update(_ object: DatabaseType) {
        guard let data = try? self.encoded() else { return }
        self.update(object, primaryKey: self.primaryKey, data: data, updates: self.allUpdates())
    }

    public static func internalPredicate() -> NSPredicate? {
        return nil
    }

    public static var typeName: String {
        return String(describing: Self.self)
    }

    public func databaseTypeName() -> String {
        return String(describing: Self.DatabaseType.self)
    }
}


public protocol DatabaseContainerProtocol: DatabaseTypeProtocol {
    /// Database container need to store `Data`, primaryKey `PrimaryKey`, and typeName.
    func update(for typeName: String, primaryKey: PrimaryKeyContainer, data: Data)
}


extension DatabaseContainerProtocol {
    public static func primaryKeyMapping(for type: String, primaryKey: PrimaryKeyContainer) -> PrimaryKeyContainer {
        switch primaryKey {
        case .none:
            return .string(value: type + UUID().uuidString, key: self.primaryKeyPath ?? "")
        case .int(let val, _):
            return .string(value: type + String(val), key: self.primaryKeyPath ?? "")
        case .string(let val, _):
            return .string(value: type + val, key: self.primaryKeyPath ?? "")
        }
    }
}