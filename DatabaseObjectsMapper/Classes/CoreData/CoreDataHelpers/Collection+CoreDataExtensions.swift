//
//  Collection+CoreDataExtensions.swift
//  psctest
//
//  Created by Florian on 18/08/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData


extension Collection where Iterator.Element: NSManagedObject {
    public func fetchFaults() {
        guard !isEmpty else { return }
        guard let context = first?.managedObjectContext else { fatalError("Managed object must have context") }
        let faults = filter { $0.isFault }
        guard let object = faults.first else { return }
        let request = NSFetchRequest<Iterator.Element>()
        request.entity = object.entity
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "self in %@", faults)
        let _ = try! context.fetch(request)
    }
}

