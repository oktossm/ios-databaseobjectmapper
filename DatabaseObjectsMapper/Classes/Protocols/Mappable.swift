//
// Created by Mikhail Mulyar on 20/12/2017.
// Copyright (c) 2017 Mikhail Mulyar. All rights reserved.
//

/// A type that is able to be saved to a database by mapping to database object.
/// Any type conforming to this protocol must also conform to the `Codable` protocol so that it can be converted to and from `JSON`.
public protocol DatabaseMappable: DictionaryCodable, AnyDatabaseMappable {

    associatedtype Container: DatabaseContainer

    /// Creates an instance of a `Container` type from a `DatabaseMappable`.
    /// - parameter userInfo: User info can be passed here.
    func container(with userInfo: Any?) throws -> Container

    /// Creates an instance of a `DatabaseMappable` type for a `Container`.
    /// - parameter object: Container that stores the encoded type.
    static func mappable(for container: Container) throws -> Self

    /// Updates an instance of a `Container` type.
    /// By default uses `func update(_ container: Container, updates: [String: Any])` passing encoded value
    func update(_ container: Container)

    /// Updates an instance of a `Container` type using updates.
    /// - parameter container: Container that should be updated.
    /// - parameter updates: updates dictionary.
    func update(_ container: Container, updates: [String: Any])

    /// Used for type fetching for example in case when single Container can store multiple different types (used by DatabaseContainerProtocol).
    static func internalPredicate() -> NSPredicate?
}


public extension DatabaseMappable {
    static func mappable(for container: Container) throws -> Self {
        guard let mappable = self.init(container.encodedValue) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Mappable not created"))
        }
        return mappable
    }

    func update(_ container: Container) {
        self.update(container, updates: encodedValue)
    }

    static func internalPredicate() -> NSPredicate? {
        return nil
    }

    static var typeName: String {
        return String(describing: Self.self)
    }

    static var databaseTypeName: String {
        return String(describing: Self.Container.self)
    }
}


public protocol UniquelyMappable: DatabaseMappable, Identifiable {
    /// The id mapped value. This used when retrieving values from a database. Database type can modify id before using it.
    /// Default containers add type name to key to store models of different types.
    /// Default implementation returns non modified key
    static func idMapping(_ primaryKey: ID) -> Container.ID
}


public extension UniquelyMappable {
    var idValue: ID {
        return self[keyPath: Self.idKey]
    }

    var objectKeyValue: Container.ID {
        return Self.idMapping(idValue)
    }

    static func idMapping(_ id: ID) -> Container.ID {
        if Container.ID.self == ID.self {
            return id as! Container.ID
        } else if Container.ID.self == String.self {
            return String(id) as! Container.ID
        } else {
            fatalError("Need to implement idMapping for custom types")
        }
    }
}


public extension UniquelyMappable where Container.ID == String, Container: SharedDatabaseContainer {
    static func idMapping(_ id: ID) -> Container.ID {
        return Self.typeName + "_" + String(id)
    }
}


/// Helper protocol to support relationships
public protocol AnyDatabaseMappable {
    func existingContainer(with userInfo: Any?) throws -> AnyDatabaseContainer?
    func container(with userInfo: Any?) throws -> AnyDatabaseContainer
    func update(_ container: AnyDatabaseContainer)
}


public extension DatabaseMappable {
    func existingContainer(with userInfo: Any?) throws -> AnyDatabaseContainer? {
        return nil
    }

    func container(with userInfo: Any?) throws -> AnyDatabaseContainer {
        let object: Container = try self.container(with: userInfo)
        return object
    }

    func update(_ container: AnyDatabaseContainer) {
        guard let container = container as? Container else { fatalError("Wrong container type") }
        self.update(container)
    }
}
