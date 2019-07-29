//
// Created by Mikhail Mulyar on 18/06/2018.
// Copyright (c) 2018 CocoaPods. All rights reserved.
//

import Foundation
import RealmSwift
import CoreData
import DatabaseObjectsMapper


class DefaultContainer: CoreDataContainer {
    @NSManaged var name: String
}
