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


extension URL: FailableCustomPersistable {
    public typealias PersistedType = String

    public init?(persistedValue: String) {
        self.init(string: persistedValue)
    }

    public var persistableValue: PersistedType {
        self.absoluteString
    }
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


struct TestSomeModel: AutoDatabaseMappable, Equatable, AutoObjectDiff, AutoLenses {
    let userId: Int
    // sourcery: indexed
    let userName: String
    let userAvatar: String
    // sourcery: indexed
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
    let user: TestERRModel?
    // sourcery: skipLens, skipDifference, skipUpdatesEquality
    let users = Relation<TestRRModel>(type: .direct)
    let owners = EmbeddedRelation<TestERRModel>(type: .direct)
}


// sourcery: embedded
struct TestERRModel: AutoDatabaseMappable, Equatable, AutoObjectDiff, AutoLenses {
    let name: String
    let someCount: Int
    let url: URL?
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


struct SomePersistable: DictionaryCodable, Equatable, Hashable, CustomPersistable {
    let index: Int

    public typealias PersistedType = Int

    public init(persistedValue: Int) {
        self.index = persistedValue
    }

    public var persistableValue: PersistedType {
        self.index
    }
}


enum SomeEnum: Int, Codable, PersistableEnum {
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
    let someComplexCodable: SomeComplexCodable?
}


struct TestCollectionsModel: AutoDatabaseMappable, Equatable, AutoObjectDiff, AutoLenses {
    let id: Int
    let strings: [String]
    let intValues: [Int64?]
    let doubleValues: [Double]?
    let dates: [Date]?
    let codable: [SomeCodable]
    let persistable: [SomePersistable]
    let urls: Array<URL>
    let dict: [String: SomePersistable]
    let anotherDict: [SomeCodable: SomeStringEnum]
    let set: Set<URL>
    let anotherSet: Set<SomeCodable?>
    let someEnum: [SomeEnum]
    let someList: [String]
    let codableEnums: [Link]
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


extension TestERRModel: DatabaseMappable {
    typealias Container = TestERRModelContainer
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


struct SomeComplexCodable: Codable, Equatable, Hashable, DictionaryCodable {
    let key: String
    let index: Int
    let link: Link?
}


enum Link: Hashable, Codable {
    case chat(Int64)
    case program(Int64)
    case profile(Int64)

    public var chatId: Int64? {
        switch self {
        case .chat(let id): return id
        default: return nil
        }
    }
    public var programId: Int64? {
        switch self {
        case .program(let id): return id
        default: return nil
        }
    }
    public var profileId: Int64? {
        switch self {
        case .profile(let id): return id
        default: return nil
        }
    }
}


extension Link {

    enum CodingKeys: String, CodingKey {
        case chat
        case program
        case profile
    }


    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.allKeys.contains(.chat), try container.decodeNil(forKey: .chat) == false {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .chat)
            let associatedValue0 = try associatedValues.decode(Int64.self)
            self = .chat(associatedValue0)
            return
        }
        if container.allKeys.contains(.program), try container.decodeNil(forKey: .program) == false {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .program)
            let associatedValue0 = try associatedValues.decode(Int64.self)
            self = .program(associatedValue0)
            return
        }
        if container.allKeys.contains(.profile), try container.decodeNil(forKey: .profile) == false {
            var associatedValues = try container.nestedUnkeyedContainer(forKey: .profile)
            let associatedValue0 = try associatedValues.decode(Int64.self)
            self = .profile(associatedValue0)
            return
        }
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case"))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .chat(associatedValue0):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .chat)
            try associatedValues.encode(associatedValue0)
        case let .program(associatedValue0):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .program)
            try associatedValues.encode(associatedValue0)
        case let .profile(associatedValue0):
            var associatedValues = container.nestedUnkeyedContainer(forKey: .profile)
            try associatedValues.encode(associatedValue0)
        }
    }
}