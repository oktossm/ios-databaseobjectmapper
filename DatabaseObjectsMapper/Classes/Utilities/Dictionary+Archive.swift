//
// Created by Mikhail Mulyar on 2019-07-22.
// Copyright (c) 2019 CocoaPods. All rights reserved.
//

import Foundation


extension Dictionary where Key == String, Value == Any {
    var archived: Data {
        (try? PropertyListSerialization.data(fromPropertyList: self, format: .binary, options: 0)) ?? Data()
    }

    init?(archive: Data) {
        guard let value = try? PropertyListSerialization.propertyList(from: archive, format: nil) as? [String: Any] else { return nil }
        self = value
    }
}


extension Array where Element == Any {
    var archived: Data {
        (try? PropertyListSerialization.data(fromPropertyList: self, format: .binary, options: 0)) ?? Data()
    }

    init?(archive: Data) {
        guard let value = try? PropertyListSerialization.propertyList(from: archive, format: nil) as? [Any] else { return nil }
        self = value
    }
}
