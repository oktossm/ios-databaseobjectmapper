//
// Created by Mikhail Mulyar on 2019-07-22.
// Copyright (c) 2019 CocoaPods. All rights reserved.
//

import Foundation

extension Dictionary where Key == String, Value == Any {
    var archived: Data {
        return NSKeyedArchiver.archivedData(withRootObject: self as NSDictionary)
    }

    init?(archive: Data) {
        guard let value = NSKeyedUnarchiver.unarchiveObject(with: archive) as? [String: Any] else {
            return nil
        }
        self = value
    }
}
