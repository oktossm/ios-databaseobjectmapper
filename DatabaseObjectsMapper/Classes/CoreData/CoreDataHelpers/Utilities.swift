//
//  Utilities.swift
//  Moody
//
//  Created by Florian on 08/05/15.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import Foundation


extension Sequence where Self.Element: AnyObject {
    public func containsObjectIdentical(to object: AnyObject) -> Bool {
        contains { $0 === object }
    }
}



