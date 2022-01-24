//
// Created by Mikhail Mulyar on 2019-02-27.
//

import Foundation


public final class Relation<Related: UniquelyMappable>: Codable {

    public enum RelationType: Int, Codable {
        case direct
        case inverse
    }


    public enum Update {
        /// Sets already existing models to relation
        case set(keys: [Related.ID])
        /// Adds already existing models to relation
        case add(keys: [Related.ID])
        /// Adds already existing models to relation and checks if they already added. Do not add object if it is already added.
        case addUnique(keys: [Related.ID])
        /// Removes already existing models from relation
        case remove(keys: [Related.ID])
        /// Creates and sets new models to relation
        case setModels(models: [Related])
        /// Creates and adds new models to relation
        case addModels(models: [Related])
    }


    public let type: RelationType
    public internal(set) var cachedValue: [Related]?

    public init(type: RelationType = .direct) {
        self.type = type
    }
}


extension Relation: Equatable {
    public static func ==(lhs: Relation<Related>, rhs: Relation<Related>) -> Bool {
        lhs.type == rhs.type
    }
}
