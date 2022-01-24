import Foundation


public enum NumericPredicateRightHandExpression<T: NumericComparableProperty> {
    /**
     Right hand collection contains `Property value`
     */
    case `in`([T])
    /**
     Right hand inclusive range contains `Property value`
     */
    case between(ClosedRange<T>)
    case betweenValues(T, T)
}


/**
 Utils for numeric range queries
 */
public func ~<Model: KeyPathConvertible, Property: NumericComparableProperty>
    (lhs: KeyPath<Model, Property>, rhs: NumericPredicateRightHandExpression<Property>) -> AnyPredicate<Model> {

    switch rhs {

    case .in(let possibleValues):
        let inValues = possibleValues.lazy
                                     .map {
                                         $0.description
                                           .replacingOccurrences(of: "\\", with: "\\\\") // replace \ -> \\
                                           .replacingOccurrences(of: "'", with: "\'") // escape ' -> \'
                                     }
                                     .joined(separator: ", ")


        return BasicPredicate<Model>(
            format: "%K IN {\(inValues)}",
            arguments: [
                Model.key(for: lhs),

            ]
        )
                .anyPredicate
    case .between(let range):
        return BasicPredicate<Model>(
            format: "%K BETWEEN {%@,%@}",
            arguments: [
                Model.key(for: lhs),
                range.lowerBound,
                range.upperBound
            ]
        )
                .anyPredicate
    case .betweenValues(let startInclusive, let endInclusive):
        return BasicPredicate<Model>(
            format: "%K BETWEEN {%@,%@}",
            arguments: [Model.key(for: lhs), startInclusive, endInclusive]
        )
                .anyPredicate
    }
}
