//
// Created by Mikhail Mulyar on 13/05/2018.
// Copyright (c) 2018 CocoaPods. All rights reserved.
//

import Foundation
import RealmSwift
import CoreData
import DatabaseObjectsMapper
import SourceryAdditions


struct TestModel: Codable, Equatable, AutoObjectDiff, AutoLenses {
    let id: Int
    let index: Int?
    let name: String
    let count: Int
    let superCount: Int
    let urls: [URL]?


    let subModel: TestSubModel?
    let children: [TestModel]?

    var isSuper: Bool {
        return self.id == 0
    }
}


struct TestSubModel: Codable, Equatable, AutoObjectDiff, AutoLenses {
    let userId: Int
    let userName: String
    let userAvatar: String
    let title: String
    let count: Int
}


struct TestSimpleModel: Codable, Equatable, AutoObjectDiff, AutoLenses {
    let title: String
    let count: Int
}


struct TestCDModel: Codable, Equatable, AutoObjectDiff, AutoLenses {
    let id: Int
    let index: Int?
    let name: String
    let count: Int
    let superCount: Int
    let urls: [URL]?


    let subModel: TestSubModel?
    let children: [TestModel]?

    var isSuper: Bool {
        return self.id == 0
    }
}


extension TestModel: DatabaseMappable, DatabaseRelationshipMappable {
    typealias DatabaseType = RealmContainer
    typealias DatabaseUpdates = [Updates]

    public var primaryKey: PrimaryKeyContainer {
        return .int(value: self.id, key: "id")
    }
}


extension TestSubModel: DatabaseMappable, DatabaseRelationshipMappable {
    typealias DatabaseType = TestContainer
    typealias DatabaseUpdates = [Updates]

    public var primaryKey: PrimaryKeyContainer {
        return .int(value: self.userId, key: "userId")
    }

    public static func databaseType() -> DatabaseType.Type {
        return TestContainer.self
    }
}


extension TestSimpleModel: DatabaseMappable, DatabaseRelationshipMappable {
    typealias DatabaseType = RealmContainer
    typealias DatabaseUpdates = [Updates]

    public var primaryKey: PrimaryKeyContainer {
        return .none
    }
}


extension TestCDModel: DatabaseMappable, DatabaseRelationshipMappable {
    typealias DatabaseType = DefaultContainer
    typealias DatabaseUpdates = [Updates]

    public var primaryKey: PrimaryKeyContainer {
        return .int(value: self.id, key: "id")
    }
}


extension Array: DatabasePropertyUpdates where Element: DictionaryElementRepresentable {

}
