//
// Created by Mikhail Mulyar on 15/01/2018.
// Copyright (c) 2018 Mikhail Mulyar. All rights reserved.
//

import Foundation


/// Objects must be DatabaseMappable
public enum DatabaseRelationshipUpdate {
    case toOne(key: String, object: DatabaseRelationshipMappable?, createNew: Bool)
    case toManySet(key: String, objects: [DatabaseRelationshipMappable]?, createNew: Bool)
    case toManyAdd(key: String, objects: [DatabaseRelationshipMappable], createNew: Bool)
    case toManyRemove(key: String, objects: [DatabaseRelationshipMappable])
}


public protocol DatabaseRelationshipMappable {
    /// The primary key of the instance. This used when retrieving values from a database.
    var primaryKey: PrimaryKeyContainer { get }

    /// The primary key value of the instance. This used when retrieving values from a database.
    func primaryKeyValue() -> Any?

    /// Creates an instance of a `DatabaseType` type from a `DatabaseRelationshipMappable`.
    /// - parameter userInfo: User info can be passed here.
    func createRelationObject(userInfo: Any?) throws -> Any

    /// Name of the DatabaseType. This used when retrieving values from a database.
    func databaseTypeName() -> String
}


public extension DatabaseRelationshipMappable where Self: DatabaseMappable {
    public func primaryKeyValue() -> Any? {
        return self.primaryKeyValue.objcValue
    }

    func createRelationObject(userInfo: Any?) throws -> Any {
        let object = try self.createObject(userInfo: userInfo)
        return object
    }
}


extension PrimaryKeyContainer {
    var objcValue: AnyObject? {
        switch self {
        case .none: return nil
        case .int(let val, _): return NSNumber(value: val)
        case .string(let val, _): return val as NSString
        }
    }
}