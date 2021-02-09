// Generated using Sourcery 1.0.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// MARK: - AutoCodable
import Foundation
import DatabaseObjectsMapper

// swiftlint:disable line_length

public protocol DecodingContainerTransformer {
    associatedtype Input
    associatedtype Output
    func transform(_ decoded: Input) throws -> Output
}


public protocol EncodingContainerTransformer {
    associatedtype Input
    associatedtype Output
    func transform(_ encoded: Output) throws -> Input
}


public typealias CodingContainerTransformer = DecodingContainerTransformer & EncodingContainerTransformer


public extension KeyedDecodingContainer {
    func decode<Transformer: DecodingContainerTransformer>(_ key: KeyedDecodingContainer.Key,
                                                                  transformer: Transformer) throws -> Transformer.Output where Transformer.Input: Decodable {
        let decoded: Transformer.Input = try self.decode(key)
        return try transformer.transform(decoded)
    }

    func decode<T>(_ key: KeyedDecodingContainer.Key) throws -> T where T: Decodable {
        return try self.decode(T.self, forKey: key)
    }
}


public extension KeyedEncodingContainer {
    mutating func encode<Transformer: EncodingContainerTransformer>(_ value: Transformer.Output,
                                                                           forKey key: KeyedEncodingContainer.Key,
                                                                           transformer: Transformer) throws where Transformer.Input: Encodable {
        let transformed: Transformer.Input = try transformer.transform(value)
        try self.encode(transformed, forKey: key)
    }
}


public extension Encodable {
    func asDictionary(dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? = nil) throws -> [String: Any] {
        let encoder = JSONEncoder()
        if let s = dateEncodingStrategy {
            encoder.dateEncodingStrategy = s
        }
        let data = try encoder.encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }

    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}


public extension Decodable {
    static func decode(data: Data, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? = nil) throws -> Self {
        let decoder = JSONDecoder()
        if let s = dateDecodingStrategy {
            decoder.dateDecodingStrategy = s
        }
        return try decoder.decode(Self.self, from: data)
    }
}


public extension Encodable {
    func encode(dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? = nil) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let s = dateEncodingStrategy {
            encoder.dateEncodingStrategy = s
        }
        return try encoder.encode(self)
    }
}


public extension Encodable {
    func prettyPrinted() -> String? {
        if let data = try? self.encode() {
            return String(bytes: data, encoding: .utf8)
        }
        return nil
    }
}





