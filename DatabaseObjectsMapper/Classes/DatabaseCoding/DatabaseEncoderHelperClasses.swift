//===----------------------------------------------------------------------===//
//
// This source file is largely a copy of code from Swift.org open source project's
// files JSONEncoder.swift and Codeable.swift.
//
// Unfortunately those files do not expose the internal _JSONEncoder and
// _JSONDecoder classes, which are in fact dictionary encoder/decoders and
// precisely what we want...
//
// The original code is copyright (c) 2014 - 2017 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
// Modifications and additional code here is copyright (c) 2018 Sam Deane, and
// is licensed under the same terms.
//
//===----------------------------------------------------------------------===//

class BoxedArray<T>: MutableCollection, RandomAccessCollection, RangeReplaceableCollection {
    var array = [T]()

    required init() {}

    @inlinable subscript(index: Int) -> T {
        get { return array[index] }
        set { array[index] = newValue }
    }
    @inlinable var startIndex: Int {
        array.startIndex
    }
    @inlinable var endIndex: Int {
        array.endIndex
    }

    @inlinable func append(_ newElement: T) {
        array.append(newElement)
    }

    @inlinable func insert(_ newElement: T, at i: Int) {
        array.insert(newElement, at: i)
    }

    @inlinable func popLast() -> T? {
        array.popLast()
    }
}


class BoxedDictionary<K: Hashable, V>: Collection {
    var dictionary = Dictionary<K, V>()

    @inlinable var startIndex: Dictionary<K, V>.Index {
        dictionary.startIndex
    }
    @inlinable var endIndex: Dictionary<K, V>.Index {
        dictionary.endIndex
    }

    @inlinable subscript(position: Dictionary<K, V>.Index) -> Dictionary<K, V>.Element {
        dictionary[position]
    }

    @inlinable func index(after i: Dictionary<K, V>.Index) -> Dictionary<K, V>.Index {
        dictionary.index(after: i)
    }

    @inlinable func updateValue(_ value: V, forKey key: K) -> V? {
        dictionary.updateValue(value, forKey: key)
    }

    @inlinable subscript(key: K) -> V? {
        get { dictionary[key] }
        set { dictionary[key] = newValue }
    }
}


public protocol ValueAsIsStrategyHelper {
    func useValueAsIs<T>(_ value: inout Any?, ofType: T.Type) -> Bool
}
