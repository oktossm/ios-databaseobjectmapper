//
// Created by Mikhail Mulyar on 2019-08-07.
//

import Foundation


public protocol KeyPathConvertible {
    static func key(for keyPath: PartialKeyPath<Self>) -> String
}


public class RootKeyPathUpdate<Root: KeyPathConvertible> {
    var update: (String, Any) {
        return ("", NSNull())
    }
}


public class KeyPathUpdate<Root: KeyPathConvertible, Value>: RootKeyPathUpdate<Root> {
    let keyPath: KeyPath<Root, Value>
    let value: Value

    init(keyPath: KeyPath<Root, Value>, value: Value) {
        self.keyPath = keyPath
        self.value = value
    }

    override var update: (String, Any) {
        return (Root.key(for: keyPath), value)
    }
}
