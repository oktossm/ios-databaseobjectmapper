//
// Created by Mikhail Mulyar on 2019-06-17.
//

import Foundation


protocol OptionalProtocol {
    func isSome() -> Bool
    func unwrap() -> Any
}


extension Optional: OptionalProtocol {
    func isSome() -> Bool {
        switch self {
        case .none: return false
        case .some: return true
        }
    }

    func unwrap() -> Any {
        switch self {
        case .none: preconditionFailure("trying to unwrap nil")
        case .some(let unwrapped): return unwrapped
        }
    }
}


func unwrapUsingProtocol<T>(_ any: T) -> Any {
    guard let optional = any as? OptionalProtocol, optional.isSome() else {
        return any
    }
    return optional.unwrap()
}