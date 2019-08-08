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

extension Array: DictionaryCodable where Element: Codable {}
extension Set: DictionaryCodable where Element: Codable {}
extension Dictionary: DictionaryCodable where Key: Codable, Value: Codable {}