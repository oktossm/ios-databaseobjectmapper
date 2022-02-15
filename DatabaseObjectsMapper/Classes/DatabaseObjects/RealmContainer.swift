//
// Created by Mikhail Mulyar on 02/01/2018.
// Copyright (c) 2018 Mikhail Mulyar. All rights reserved.
//

import RealmSwift


/// A RealmContainer allows any Codable type to be persisted to a Realm.
public final class RealmContainer: Object, UniqueDatabaseContainer {
    public static var idKey: WritableKeyPath<RealmContainer, String> = \RealmContainer._id

    @objc dynamic var _value: Data? = nil

    public var encodedValue: [String: Any?] {
        get {
            _value.flatMap { Dictionary<String, Any?>(archive: $0) } ?? [:]
        }
        set {
            _value = newValue.archived
        }
    }

    /// The unique identifier for the data. This property is used as the primary key.
    @objc public dynamic var _id = ""

    public override class func primaryKey() -> String? {
        "_id"
    }

    public override class func indexedProperties() -> [String] {
        []
    }
}
