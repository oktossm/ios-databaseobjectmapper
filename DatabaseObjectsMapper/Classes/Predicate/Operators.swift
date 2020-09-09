//
// Created by Mikhail Mulyar on 2019-08-07.
//

import Foundation
import DictionaryCoding


// MARK: Logical Operators
public func &&<Model: KeyPathConvertible>(lhs: AnyPredicate<Model>, rhs: AnyPredicate<Model>) -> AnyPredicate<Model> {
    return AndPredicate(left: lhs, right: rhs)
        .anyPredicate
}

public func ||<Model: KeyPathConvertible>(lhs: AnyPredicate<Model>, rhs: AnyPredicate<Model>) -> AnyPredicate<Model> {
    return OrPredicate(left: lhs, right: rhs)
        .anyPredicate
}

public prefix func !<Model: KeyPathConvertible>(predicate: AnyPredicate<Model>) -> AnyPredicate<Model> {
    return NotPredicate(original: predicate)
        .anyPredicate
}

// MARK: AnyEquatableProperty
public func ==<Model: KeyPathConvertible, Property: AnyEquatableProperty>(lhs: KeyPath<Model, Property>, rhs: Property) -> AnyPredicate<Model> {
    return BasicPredicate<Model>(format: "%K == %@",
                                 arguments: [Model.key(for: lhs), processRhs(rhs)])
        .anyPredicate
}

public func !=<Model: KeyPathConvertible, Property: AnyEquatableProperty>(lhs: KeyPath<Model, Property>, rhs: Property) -> AnyPredicate<Model> {
    return BasicPredicate<Model>(format: "%K != %@",
                                 arguments: [Model.key(for: lhs), processRhs(rhs)])
        .anyPredicate
}

// MARK: Optional<AnyEquatableProperty>
public func ==<Model: KeyPathConvertible, Property: AnyEquatableProperty>(lhs: KeyPath<Model, Property?>, rhs: Property?) -> AnyPredicate<Model> {
    return BasicPredicate<Model>(format: "%K == %@",
                                 arguments: [Model.key(for: lhs), processOptionalRhs(rhs)])
        .anyPredicate
}

public func !=<Model: KeyPathConvertible, Property: AnyEquatableProperty>(lhs: KeyPath<Model, Property?>, rhs: Property?) -> AnyPredicate<Model> {
    return BasicPredicate<Model>(format: "%K != %@",
                                 arguments: [Model.key(for: lhs), processOptionalRhs(rhs)])
        .anyPredicate
}


// MARK: AnyComparableProperty
public func <<Model: KeyPathConvertible, Property: AnyComparableProperty>(lhs: KeyPath<Model, Property>, rhs: Property) -> AnyPredicate<Model> {
    return BasicPredicate<Model>(format: "%K < %@",
                                 arguments: [Model.key(for: lhs), processRhs(rhs)])
        .anyPredicate
}

public func ><Model: KeyPathConvertible, Property: AnyComparableProperty>(lhs: KeyPath<Model, Property>, rhs: Property) -> AnyPredicate<Model> {
    return BasicPredicate<Model>(format: "%K > %@",
                                 arguments: [Model.key(for: lhs), processRhs(rhs)])
        .anyPredicate
}

public func <=<Model: KeyPathConvertible, Property: AnyComparableProperty>(lhs: KeyPath<Model, Property>, rhs: Property) -> AnyPredicate<Model> {
    return BasicPredicate<Model>(format: "%K <= %@",
                                 arguments: [Model.key(for: lhs), processRhs(rhs)])
        .anyPredicate
}

public func >=<Model: KeyPathConvertible, Property: AnyComparableProperty>(lhs: KeyPath<Model, Property>, rhs: Property) -> AnyPredicate<Model> {
    return BasicPredicate<Model>(format: "%K >= %@",
                                 arguments: [Model.key(for: lhs), processRhs(rhs)])
        .anyPredicate
}

// MARK: Optional<AnyComparableProperty>
public func <<Model: KeyPathConvertible, Property: AnyComparableProperty>(lhs: KeyPath<Model, Property?>, rhs: Property?) -> AnyPredicate<Model> {
    return BasicPredicate<Model>(format: "%K < %@",
                                 arguments: [Model.key(for: lhs), processOptionalRhs(rhs)])
        .anyPredicate
}

public func ><Model: KeyPathConvertible, Property: AnyComparableProperty>(lhs: KeyPath<Model, Property?>, rhs: Property?) -> AnyPredicate<Model> {
    return BasicPredicate<Model>(format: "%K > %@",
                                 arguments: [Model.key(for: lhs), processOptionalRhs(rhs)])
        .anyPredicate
}

public func <=<Model: KeyPathConvertible, Property: AnyComparableProperty>(lhs: KeyPath<Model, Property?>, rhs: Property?) -> AnyPredicate<Model> {
    return BasicPredicate<Model>(format: "%K <= %@",
                                 arguments: [Model.key(for: lhs), processOptionalRhs(rhs)])
        .anyPredicate
}

public func >=<Model: KeyPathConvertible, Property: AnyComparableProperty>(lhs: KeyPath<Model, Property?>, rhs: Property?) -> AnyPredicate<Model> {
    return BasicPredicate<Model>(format: "%K >= %@",
                                 arguments: [Model.key(for: lhs), processOptionalRhs(rhs)])
        .anyPredicate
}

private let dictionaryEncoder = DictionaryEncoder()
private func processRhs(_ rhs: AnyProperty) -> Any {
    if let date = rhs as? Date {
        return date.encodedValue as? Double ?? 0
    } else {
        return rhs
    }
}


private func processOptionalRhs(_ rhs: AnyProperty?) -> Any {
    if let optionalDate = rhs as? Optional<Date>, let date = optionalDate {
        return date.encodedValue as? Double ?? 0
    } else {
        return rhs ?? NSNull()
    }
}

// MARK: Operator for Numeric && String operators
infix operator ~: MultiplicationPrecedence

// MARK: Assign operator

infix operator <-

public func <-<Model: KeyPathConvertible, Property>(lhs: KeyPath<Model, Property>, rhs: Property) -> RootKeyPathUpdate<Model> {
    return KeyPathUpdate(keyPath: lhs, value: rhs)
}
