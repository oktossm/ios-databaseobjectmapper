//
// Created by Mikhail Mulyar on 20/12/2017.
// Copyright (c) 2017 Mikhail Mulyar. All rights reserved.
//

import Foundation


public extension DatabaseMappable where DatabaseType: RealmContainer {
    public static func databaseType() -> DatabaseType.Type {
        return DatabaseType.self
    }
}


public extension DatabaseMappable where DatabaseType: CoreDataContainer {
    public static func databaseType() -> DatabaseType.Type {
        return DatabaseType.self
    }
}


extension CoreDataContainer: DatabaseContainerProtocol {
    public var encoded: Data {
        get {
            return self.data
        }
        set {
            self.data = newValue
        }
    }

    public func update(for typeName: String, primaryKey: PrimaryKeyContainer, data: Data) {
        self.typeName = typeName
        self.id = CoreDataContainer.primaryKeyMapping(for: typeName, primaryKey: primaryKey).value as? String ?? ""
        self.data = data
    }
}


extension RealmContainer: DatabaseContainerProtocol {
    public var encoded: Data {
        get {
            return self.data
        }
        set {
            self.data = newValue
        }
    }

    public func update(for typeName: String, primaryKey: PrimaryKeyContainer, data: Data) {
        self.typeName = typeName
        self.data = data

        if self.realm == nil {
            self.id = (RealmContainer.primaryKeyMapping(for: typeName, primaryKey: primaryKey).value as? String) ?? ""
        }
    }
}


extension CodingUserInfoKey {
    static let context: CodingUserInfoKey = CodingUserInfoKey(rawValue: "context")!
}
