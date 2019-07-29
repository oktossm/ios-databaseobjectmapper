//
// Created by Mikhail Mulyar on 02/01/2018.
// Copyright (c) 2018 Mikhail Mulyar. All rights reserved.
//

import RealmSwift


/// A RealmContainer allows any Codable type to be persisted to a Realm.
public final class RealmContainer: Object, SharedDatabaseContainer {
    public static var idKey: WritableKeyPath<RealmContainer, String> = \RealmContainer.id

    @objc dynamic var _value: Data? = nil

    public var encodedValue: [String: Any] {
        get {
            return _value.flatMap { Dictionary<String, Any>(archive: $0) } ?? [:]
        }
        set {
            _value = newValue.archived
        }
    }

    /// The name of the type that the encoded data is. Used for retrieving all values.
    @objc public dynamic var typeName = ""

    /// The unique identifier for the data. This property is used as the primary key.
    @objc public dynamic var id = ""

    public override class func primaryKey() -> String? {
        return "id"
    }

    public override class func indexedProperties() -> [String] {
        return []
    }
}
