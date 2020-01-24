//
// Created by Mikhail Mulyar on 2019-08-07.
//

import Foundation


public protocol NSPredicateConvertible {
    var predicate: NSPredicate { get }
}


public protocol Predicate: NSPredicateConvertible {
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

    let left: AnyPredicate<Model>
    let right: AnyPredicate<Model>

    public var predicate: NSPredicate {
        return NSCompoundPredicate(type: .and, subpredicates: [left.predicate, right.predicate])
    }
}


public struct OrPredicate<Model: KeyPathConvertible>: Predicate {
    public typealias ModelType = Model

    let left: AnyPredicate<Model>
    let right: AnyPredicate<Model>

    public var predicate: NSPredicate {
        return NSCompoundPredicate(type: .or, subpredicates: [left.predicate, right.predicate])
    }
}


public struct NotPredicate<Model: KeyPathConvertible>: Predicate {
    public typealias ModelType = Model

    let original: AnyPredicate<Model>

    public var predicate: NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate: original.predicate)
    }
}
