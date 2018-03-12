//
// Created by Mikhail Mulyar on 20/12/2017.
// Copyright (c) 2017 Mikhail Mulyar. All rights reserved.
//

import Foundation


public extension DatabaseMappable where DatabaseType == RealmContainer {
    public static func databaseType() -> DatabaseType.Type {
        return RealmContainer.self
    }
}


//public extension DatabaseMappable where DatabaseType == CoreDataContainer {
//    public static func databaseType() -> DatabaseType.Type {
//        return CoreDataContainer.self
//    }
//}


//extension CoreDataContainer: DatabaseContainerProtocol {
//    public var encoded: Data {
//        get {
//            return self.data ?? Data()
//        }
//        set {
//            self.data = newValue
//        }
//    }
//
//    public func set(typeName: String, primaryKey: PrimaryKeyValue, data: Data) {
//        self.typeName = typeName
//        self.id = CoreDataContainer.primaryKeyValue(for: typeName, primaryKeyType: primaryKey)
//        self.data = data
//    }
//}


extension RealmContainer: DatabaseContainerProtocol {
    public var encoded: Data {
        get {
            return self.data
        }
        set {
            self.data = newValue
        }
    }

    public func set(typeName: String, primaryKey: PrimaryKeyValue, data: Data) {
        self.typeName = typeName
        self.data = data
        self.id = RealmContainer.primaryKeyValue(for: typeName, primaryKeyType: primaryKey)
    }
}

extension CodingUserInfoKey {
    static let context: CodingUserInfoKey = CodingUserInfoKey(rawValue: "context")!
}


/// Conditional conformances is not implemented yet. We need to add default implementation.
/// Specific implementation can be found in `extension Array where Element: DictionaryElementRepresentable`
extension Array: DatabasePropertyUpdates {
    public func dictionaryRepresentation() -> [String: Any?] {
        return [String: Any?]()
    }
}
