//
// Created by Mikhail Mulyar on 2019-08-07.
//

import Foundation


// MARK: Logical Operators
public func &&<Model: KeyPathConvertible>(lhs: BasicPredicate<Model>, rhs: BasicPredicate<Model>) -> AndPredicate<Model> {
    return AndPredicate(left: lhs, right: rhs)
}

public func ||<Model: KeyPathConvertible>(lhs: BasicPredicate<Model>, rhs: BasicPredicate<Model>) -> OrPredicate<Model> {
    return OrPredicate(left: lhs, right: rhs)
}

public prefix func !<Model: KeyPathConvertible>(predicate: BasicPredicate<Model>) -> NotPredicate<Model> {
    return NotPredicate(original: predicate)
}

// MARK: AnyEquatableProperty
public func ==<Model: KeyPathConvertible, Property: AnyEquatableProperty>(lhs: KeyPath<Model, Property>, rhs: Property) -> BasicPredicate<Model> {
    return BasicPredicate<Model>(format: "%K == %@", arguments: [Model.key(for: lhs), rhs])
}

public func !=<Model: KeyPathConvertible, Property: AnyEquatableProperty>(lhs: KeyPath<Model, Property>, rhs: Property) -> BasicPredicate<Model> {
    return BasicPredicate<Model>(format: "%K != %@", arguments: [Model.key(for: lhs), rhs])
}

// MARK: Optional<AnyEquatableProperty>
public func ==<Model: KeyPathConvertible, Property: AnyEquatableProperty>(lhs: KeyPath<Model, Property?>, rhs: Property?) -> BasicPredicate<Model> {
    return BasicPredicate<Model>(format: "%K == %@", arguments: [Model.key(for: lhs), rhs ?? NSNull()])
}

public func !=<Model: KeyPathConvertible, Property: AnyEquatableProperty>(lhs: KeyPath<Model, Property?>, rhs: Property?) -> BasicPredicate<Model> {
    return BasicPredicate<Model>(format: "%K != %@", arguments: [Model.key(for: lhs), rhs ?? NSNull()])
}


// MARK: AnyComparableProperty
public func <<Model: KeyPathConvertible, Property: AnyComparableProperty>(lhs: KeyPath<Model, Property>, rhs: Property) -> BasicPredicate<Model> {
    return BasicPredicate<Model>(format: "%K < %@", arguments: [Model.key(for: lhs), rhs])
}

public func ><Model: KeyPathConvertible, Property: AnyComparableProperty>(lhs: KeyPath<Model, Property>, rhs: Property) -> BasicPredicate<Model> {
    return BasicPredicate<Model>(format: "%K > %@", arguments: [Model.key(for: lhs), rhs])
}

public func <=<Model: KeyPathConvertible, Property: AnyComparableProperty>(lhs: KeyPath<Model, Property>, rhs: Property) -> BasicPredicate<Model> {
    return BasicPredicate<Model>(format: "%K <= %@", arguments: [Model.key(for: lhs), rhs])
}

public func >=<Model: KeyPathConvertible, Property: AnyComparableProperty>(lhs: KeyPath<Model, Property>, rhs: Property) -> BasicPredicate<Model> {
    return BasicPredicate<Model>(format: "%K >= %@", arguments: [Model.key(for: lhs), rhs])
}

// MARK: Optional<AnyComparableProperty>
public func <<Model: KeyPathConvertible, Property: AnyComparableProperty>(lhs: KeyPath<Model, Property?>, rhs: Property?) -> BasicPredicate<Model> {
    return BasicPredicate<Model>(format: "%K < %@", arguments: [Model.key(for: lhs), rhs ?? NSNull()])
}

public func ><Model: KeyPathConvertible, Property: AnyComparableProperty>(lhs: KeyPath<Model, Property?>, rhs: Property?) -> BasicPredicate<Model> {
    return BasicPredicate<Model>(format: "%K > %@", arguments: [Model.key(for: lhs), rhs ?? NSNull()])
}

public func <=<Model: KeyPathConvertible, Property: AnyComparableProperty>(lhs: KeyPath<Model, Property?>, rhs: Property?) -> BasicPredicate<Model> {
    return BasicPredicate<Model>(format: "%K <= %@", arguments: [Model.key(for: lhs), rhs ?? NSNull()])
}

public func >=<Model: KeyPathConvertible, Property: AnyComparableProperty>(lhs: KeyPath<Model, Property?>, rhs: Property?) -> BasicPredicate<Model> {
    return BasicPredicate<Model>(format: "%K >= %@", arguments: [Model.key(for: lhs), rhs ?? NSNull()])
}

// MARK: Assign operator

infix operator <-

public func <-<Model: KeyPathConvertible, Property>(lhs: KeyPath<Model, Property>, rhs: Property) -> RootKeyPathUpdate<Model> {
    return KeyPathUpdate(keyPath: lhs, value: rhs)
}
