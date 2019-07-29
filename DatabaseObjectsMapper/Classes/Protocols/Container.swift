//
// Created by Mikhail Mulyar on 2019-07-06.
//

import Foundation


public protocol AnyDatabaseContainer: class {
    /// `Data` stored in Container properties for `DatabaseMappable`.
    var encodedValue: [String: Any] { get set }
}


public protocol DatabaseContainer: AnyDatabaseContainer {

    /// Id type.
    associatedtype ID: LosslessStringConvertible, Hashable

    associatedtype Container = Self where Container: DatabaseContainer

    /// Id Key.
    static var idKey: WritableKeyPath<Container, ID> { get }
}


/// A container type that is able to store several models to make basic setups easier.
/// It should store type of model, item key, and value
public protocol SharedDatabaseContainer: DatabaseContainer {
    associatedtype ID = String
    /// Database container additionally need to store typeName.
    var typeName: String { get set }
}
