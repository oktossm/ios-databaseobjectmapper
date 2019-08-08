//
// Created by Mikhail Mulyar on 13/05/2018.
// Copyright (c) 2018 CocoaPods. All rights reserved.
//

import Foundation
import RealmSwift
import CoreData
import DatabaseObjectsMapper
import SourceryAdditions


public protocol AutoDatabaseMappable {
}


// sourcery: AutoImport=DatabaseObjectsMapper
struct TestModel: Equatable, AutoObjectDiff, AutoLenses {
    let id: Int
    let index: Int?
    let name: String
    let count: Int
    let someCount: Int
    let urls: [URL]?


    let someModel: TestSomeModel?

    var isNew: Bool {
        return self.id == 0
    }
}


// sourcery: indexedProperties=["userName","title"]
struct TestSomeModel: AutoDatabaseMappable, Equatable, AutoObjectDiff, AutoLenses {
    let userId: Int
    let userName: String
    let userAvatar: String
    let title: String?
    let count: Int
    // sourcery: inverseRelation = owner
    let inverseModel = Relation<TestRRModel>(type: .inverse)
    let directModels = Relation<TestRRModel>(type: .direct)


    struct TestNestedModel: Equatable, DictionaryCodable {
        let title: String
        let count: Int
    }


    let nestedModel: TestNestedModel?
}


struct TestSimpleModel: Equatable, AutoObjectDiff, AutoLenses {
    let title: String
    let count: Int
}


struct TestCDSimpleModel: Equatable, AutoObjectDiff, AutoLenses {
    let title: String
    let count: Int
}


struct TestCDModel: Equatable, AutoObjectDiff, AutoLenses {
    let id: Int
    let index: Int?
    let name: String
    let count: Int
    let someCount: Int
    let urls: [URL]?

    let subModel: Relation<TestSomeModel>

    var isNew: Bool {
        return self.id == 0
    }
}


struct TestRRModel: AutoDatabaseMappable, Equatable, AutoObjectDiff, AutoLenses {
    let id: Int
    let name: String

    let owner: TestSomeModel?
    let users = Relation<TestRRModel>(type: .direct)
}

struct SomeCodable: Codable, Equatable, Hashable {
    let key: String
    let index: Int
}


struct TestCollectionsModel: AutoDatabaseMappable, Equatable, AutoObjectDiff, AutoLenses {
    let id: Int
    let strings: [String]
    let intValues: [Int64?]?
    let doubleValues: [Double]?
    let dates: [Date]?
    let codable: [SomeCodable]
    let urls: Array<URL?>
    let dict: [Int: SomeCodable]
    let anotherDict: [SomeCodable: Int]
    let set: Set<URL?>
    let anotherSet: Set<SomeCodable>?
}

extension TestCollectionsModel: UniquelyMappable {
    typealias Container = TestCollectionsModelContainer
    static var idKey = \TestCollectionsModel.id
}

extension TestModel: UniquelyMappable {
    typealias Container = RealmContainer
    static var idKey = \TestModel.id
}


extension TestSomeModel: UniquelyMappable {
    typealias Container = TestSomeModelContainer
    static var idKey = \TestSomeModel.userId
}


extension TestSimpleModel: DatabaseMappable {
    typealias Container = RealmContainer
}


extension TestCDModel: UniquelyMappable {
    typealias Container = DefaultContainer
    static var idKey = \TestCDModel.id
}


extension TestCDSimpleModel: DatabaseMappable {
    typealias Container = DefaultContainer
}


extension TestRRModel: UniquelyMappable {
    typealias Container = TestRRModelContainer
    static var idKey = \TestRRModel.id
}
