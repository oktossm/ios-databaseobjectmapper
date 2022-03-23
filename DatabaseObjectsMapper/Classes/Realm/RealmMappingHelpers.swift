//
// Created by Mikhail Mulyar on 2019-03-14.
//

import Foundation
import RealmSwift


protocol BaseProperty {}


extension Bool: BaseProperty {}


extension Int: BaseProperty {}


extension Int8: BaseProperty {}


extension Int16: BaseProperty {}


extension Int32: BaseProperty {}


extension Int64: BaseProperty {}


extension Float: BaseProperty {}


extension Double: BaseProperty {}


extension String: BaseProperty {}


private class DatabaseMappingEncodingStrategyHelper: ValueAsIsStrategyHelper {
    func useValueAsIs<T>(_ value: inout Any?, ofType type: T.Type) -> Bool {
        if !(T.self is BaseProperty.Type), T.self is _ObjcBridgeable.Type {
            value = (value as! _ObjcBridgeable)._rlmObjcValue
            return true
        }
        return false
    }
}


private class DatabaseMappingDecodingStrategyHelper: ValueAsIsStrategyHelper {
    func useValueAsIs<T>(_ value: inout Any?, ofType type: T.Type) -> Bool {
        if !(T.self is BaseProperty.Type), let unwrapped = value, let type = (T.self as? _ObjcBridgeable.Type) {
            value = type._rlmFromObjc(unwrapped, insideOptional: false)
            return true
        }
        return false
    }
}


extension DatabaseMappable where Container: Object {
    public init?(_ encodedValue: [String: Any?]) {
        let decoder = DatabaseDecoder()
        decoder.valueDecodingStrategy = .asIs(DatabaseMappingDecodingStrategyHelper())
        guard let object = try? decoder.decode(Self.self, from: encodedValue) else { return nil }
        self = object
    }

    public var encodedValue: [String: Any?] {
        let encoder = DatabaseEncoder()
        encoder.valueEncodingStrategy = .asIs(DatabaseMappingEncodingStrategyHelper())
        return (try? encoder.encode(self)) ?? [:]
    }
}


public protocol RealmEncodableDatabaseMappable: Codable {}


extension RealmEncodableDatabaseMappable {
    var realmEncodedValue: [String: Any?] {
        let encoder = DatabaseEncoder()
        encoder.valueEncodingStrategy = .asIs(DatabaseMappingEncodingStrategyHelper())
        return (try? encoder.encode(self)) ?? [:]
    }
}
