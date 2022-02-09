//
// Created by Mikhail Mulyar on 2019-08-07.
//

import Foundation


public protocol AnySortDescriptor {
    var sortDescriptor: NSSortDescriptor { get }
}


public struct SortDescriptor<Model: KeyPathConvertible>: AnySortDescriptor {
    public let keyPath: PartialKeyPath<Model>
    public let ascending: Bool

    public init(_ keyPath: PartialKeyPath<Model>, ascending: Bool) {
        self.keyPath = keyPath
        self.ascending = ascending
    }

    public var sortDescriptor: NSSortDescriptor {
        NSSortDescriptor(key: Model.key(for: keyPath), ascending: ascending)
    }
}
