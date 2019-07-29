//
// Created by Mikhail Mulyar on 2019-07-06.
//

import Foundation


/// Conform to `Identifiable` protocol in uniquely identified objects you want to store.
public protocol Identifiable {

    /// Id type.
    associatedtype ID: LosslessStringConvertible, Hashable

    /// Id Key.
    static var idKey: KeyPath<Self, ID> { get }
}