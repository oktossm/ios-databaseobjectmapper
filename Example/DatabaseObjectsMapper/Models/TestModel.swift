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
    // sourcery: inverseRelation = owner, skipLens, skipObjectDiff
    let inverseModel = Relation<TestRRModel>(type: .inverse)
    // sourcery: skipLens, skipObjectDiff
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
    // sourcery: skipLens, skipDifference, skipUpdatesEquality
    let users = Relation<TestRRModel>(type: .direct)
}

struct TestRNModel: AutoDatabaseMappable, Equatable, AutoObjectDiff, AutoLenses {
    let id: Int
    let name: String

    let owner: TestSomeModel
}

struct SomeCodable: Codable, Equatable, Hashable {
    let key: String
    let index: Int
}


enum SomeEnum: Int, Codable {
   case firstCase
   case secondCase
   case thirdCase
}

enum SomeStringEnum: String, Codable {
    case firstCase
    case secondCase
    case thirdCase
}

struct TestPrimitivesModel: AutoDatabaseMappable, Equatable, AutoObjectDiff, AutoLenses {
    let id: Int
    let value: Int32?
    let doubleValue: Double
    let floatValue: Float?
    let boolValue: Bool?
    let urlValue: URL?
    let someEnum: SomeEnum
    let someEnumOpt: SomeEnum?
    let stringEnum: SomeStringEnum
    let stringEnumOpt: SomeStringEnum?
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
    let someEnum: [SomeEnum]
}

extension TestPrimitivesModel: UniquelyMappable {
    typealias Container = TestPrimitivesModelContainer
    static var idKey = \TestPrimitivesModel.id
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

extension TestRNModel: UniquelyMappable {
    typealias Container = TestRNModelContainer
    static var idKey = \TestRNModel.id
}

// For date tests
struct TestDateModel: AutoDatabaseMappable, Equatable, AutoObjectDiff, AutoLenses {
    let id: Int
    let date: Date
}

extension TestDateModel: UniquelyMappable {
    typealias Container = TestDateModelContainer
    static var idKey = \TestDateModel.id
}
