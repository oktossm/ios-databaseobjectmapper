//
// Created by Mikhail Mulyar on 02/01/2018.
// Copyright (c) 2018 Mikhail Mulyar. All rights reserved.
//

import RealmSwift


/// A RealmContainer allows any type that is JSON encodable to be persisted to a Realm.
final public class RealmContainer: Object, Codable {
    /// JSON encoded data that should be persisted to a Realm.
    @objc public dynamic var data = Data()

    /// The name of the type that the encoded data is. Used for retrieving all values.
    @objc public dynamic var typeName = ""

    /// The unique identifier for the data. This property is used as the primary key.
    @objc public dynamic var id = ""

    /// String param.
    @objc public dynamic var stringParam = ""

    /// Int param.
    @objc public dynamic var intParam = 0

    /// Bool param.
    @objc public dynamic var boolParam = false

    /// Double param.
    @objc public dynamic var doubleParam: Double = 0.0

    /// Creates a new RealmContainer instance with custom parameters.
    public convenience init(stringParam: String = "",
                            intParam: Int = 0,
                            boolParam: Bool = false,
                            doubleParam: Double = 0.0) {
        self.init()
        self.stringParam = stringParam
        self.intParam = intParam
        self.boolParam = boolParam
        self.doubleParam = doubleParam

    }

    public override static func primaryKey() -> String? {
        return "id"
    }

    public override class func indexedProperties() -> [String] {
        return []
    }


    enum CodingKeys: String, CodingKey {
        case data
        case typeName
        case id
    }


    public convenience init(from decoder: Decoder) throws {
        fatalError("Decoding is not supported")
    }

    public func decode(from decoder: Decoder) throws {
        fatalError("Decoding is not supported")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(data, forKey: .data)
        try container.encode(typeName, forKey: .typeName)
        try container.encode(id, forKey: .id)
    }
}
