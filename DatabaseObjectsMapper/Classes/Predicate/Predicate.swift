//
// Created by Mikhail Mulyar on 2019-08-07.
//

import Foundation


public protocol AnyPredicate {
    var predicate: NSPredicate { get }
}


public protocol Predicate: AnyPredicate {
    associatedtype ModelType: KeyPathConvertible
}


public struct BasicPredicate<Model: KeyPathConvertible>: Predicate {
    public typealias ModelType = Model

    let format: String
    let arguments: [Any]

    public var predicate: NSPredicate {
        return NSPredicate(format: format, argumentArray: arguments)
    }
}


public struct AndPredicate<Model: KeyPathConvertible>: Predicate {
    public typealias ModelType = Model

    let left: BasicPredicate<Model>
    let right: BasicPredicate<Model>

    public var predicate: NSPredicate {
        return NSCompoundPredicate(type: .and, subpredicates: [left.predicate, right.predicate])
    }
}


public struct OrPredicate<Model: KeyPathConvertible>: Predicate {
    public typealias ModelType = Model

    let left: BasicPredicate<Model>
    let right: BasicPredicate<Model>

    public var predicate: NSPredicate {
        return NSCompoundPredicate(type: .or, subpredicates: [left.predicate, right.predicate])
    }
}


public struct NotPredicate<Model: KeyPathConvertible>: Predicate {
    public typealias ModelType = Model

    let original: BasicPredicate<Model>

    public var predicate: NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate: original.predicate)
    }
}