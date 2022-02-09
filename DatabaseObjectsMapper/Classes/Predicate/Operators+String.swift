import Foundation


public enum StringPredicateRightHandExpression {

    /**
     Property value begins with the right hand expression
     */
    case hasPrefix(_ value: CustomStringConvertible?)

    /**
     Property value ends with the right hand expression
     */
    case hasSuffix(_ value: CustomStringConvertible?)

    /**
     Property value contains the right hand expression
     */
    case contains(_ value: CustomStringConvertible?)

    /**
     Property value contains the right hand expression
     */
    case like(_ wildcardPatternString: CustomStringConvertible?)

    /**
     Right hand collection contains `Property value`
     */
    case `in`(_ possibleValues: [CustomStringConvertible])
}


public func ~<Model: KeyPathConvertible, Property: StringEquatableProperty>(lhs: KeyPath<Model, Property>,
                                                                            rhs: StringPredicateRightHandExpression) -> AnyPredicate<Model> {
    switch rhs {
    case .hasPrefix(let prefix):
        return BasicPredicate<Model>(format: "%K BEGINSWITH %@",
                                     arguments: [Model.key(for: lhs), prefix ?? NSNull()])
                .anyPredicate
    case .hasSuffix(let suffix):
        return BasicPredicate<Model>(format: "%K ENDSWITH %@",
                                     arguments: [Model.key(for: lhs), suffix ?? NSNull()])
                .anyPredicate
    case .contains(let substring):
        return BasicPredicate<Model>(format: "%K CONTAINS %@",
                                     arguments: [Model.key(for: lhs), substring ?? NSNull()])
                .anyPredicate
    case .like(let wildcardPatternString):
        return BasicPredicate<Model>(format: "%K LIKE %@",
                                     arguments: [Model.key(for: lhs), wildcardPatternString ?? NSNull()])
                .anyPredicate
    case .in(let possibleValues):
        let inValues = possibleValues.lazy
                                     .map {
                                         $0.description
                                           .replacingOccurrences(of: "\\", with: "\\\\") // replace \ -> \\
                                           .replacingOccurrences(of: "'", with: "\\'") // escape ' -> \'
                                     }
                                     .map { "'\($0)'" }
                                     .joined(separator: ", ")

        return BasicPredicate<Model>(
            format: "%K IN {\(inValues)}",
            arguments: [
                Model.key(for: lhs)
            ]
        )
                .anyPredicate
    }
}
