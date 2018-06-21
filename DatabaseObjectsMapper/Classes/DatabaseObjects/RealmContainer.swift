//
// Created by Mikhail Mulyar on 02/01/2018.
// Copyright (c) 2018 Mikhail Mulyar. All rights reserved.
//

import RealmSwift


/// A RealmContainer allows any type that is JSON encodable to be persisted to a Realm.
open class RealmContainer: Object {
    /// JSON encoded data that should be persisted to a Realm.
    @objc public dynamic var data = Data()

    /// The name of the type that the encoded data is. Used for retrieving all values.
    @objc public dynamic var typeName = ""

    /// The unique identifpier for the data. This property is used as the primary key.
    @objc public dynamic var id = ""
    
    open override static func primaryKey() -> String? {
        return "id"
    }

    open override class func indexedProperties() -> [String] {
        return []
    }
}
