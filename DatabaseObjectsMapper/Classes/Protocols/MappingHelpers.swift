//
// Created by Mikhail Mulyar on 2019-03-14.
//

import Foundation
import DictionaryCoding


public protocol DictionaryCodable: Codable {
    /// Inits self with encoded value.
    init?(_ encodedValue: [String: Any])
    /// Returns encoded value.
    // sourcery: skipEquality
    var encodedValue: [String: Any] { get }
}


extension DictionaryCodable {
    public init?(_ encodedValue: [String: Any]) {
        guard let object = try? DictionaryDecoder().decode(Self.self, from: encodedValue) else { return nil }
        self = object
    }

    public var encodedValue: [String: Any] {
        let encoder = DictionaryEncoder()
        return (try? encoder.encode(self)) ?? [:]
    }
}


public extension DatabaseMappable {
    static func databaseType() -> Container.Type {
        return Container.self
    }
}


extension CodingUserInfoKey {
    static let context: CodingUserInfoKey = CodingUserInfoKey(rawValue: "context")!
}

protocol DictionaryCodableCollection {
    var encodedCollectionValue: Any { get }
}

extension Collection where Element: Codable {
    var encodedCollectionValue: Any {
        let encoder = DictionaryEncoder()
        //fixes issue that DictionaryEncoder can not encode arrays/sets as top level elements
        let dictionary: [String: [Element]] = ["value": self.map { $0 }]
        let result: [String: Any]? = try? encoder.encode(dictionary)
        return result?["value"] ?? []
    }
}

extension Array: DictionaryCodable where Element: Codable {}
extension Set: DictionaryCodable where Element: Codable {}
extension Dictionary: DictionaryCodable where Key: Codable, Value: Codable {}

extension Array: DictionaryCodableCollection where Element: Codable {}
extension Set: DictionaryCodableCollection where Element: Codable {}