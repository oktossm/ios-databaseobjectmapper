//
// Created by Mikhail Mulyar on 2019-03-14.
//

import Foundation
import RealmSwift


extension URL: FailableCustomPersistable {
    public typealias PersistedType = String

    public init?(persistedValue: String) {
        self.init(string: persistedValue)
    }

    public var persistableValue: PersistedType {
        self.absoluteString
    }
}
