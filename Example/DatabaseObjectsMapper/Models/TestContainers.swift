//
// Created by Mikhail Mulyar on 18/06/2018.
// Copyright (c) 2018 CocoaPods. All rights reserved.
//

import Foundation
import RealmSwift
import CoreData
import DatabaseObjectsMapper


final class TestContainer: Object, DatabaseTypeProtocol {
    /// JSON encoded data that should be persisted to a Realm.
    @objc public dynamic var encoded = Data()

    /// The unique identifier for the data. This property is used as the primary key.
    @objc public dynamic var userId = 0

    @objc public dynamic var userName = ""

    @objc public dynamic var userAvatar = ""

    @objc public dynamic var title = ""

    @objc public dynamic var count = 0

    public override static func primaryKey() -> String? {
        return "userId"
    }

    public override class func indexedProperties() -> [String] {
        return []
    }
}


class DefaultContainer: CoreDataContainer {
    @NSManaged var name: String
}
