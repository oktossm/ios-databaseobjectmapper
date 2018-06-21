//
// Created by Mikhail Mulyar on 18/06/2018.
//

import CoreData


open class CoreDataContainer: NSManagedObject {

    /// JSON encoded data that should be persisted to a Realm.
    @NSManaged var data: Data

    /// The name of the type that the encoded data is. Used for retrieving all values.
    @NSManaged var typeName: String

    /// The unique identifier for the data. This property is used as the primary key.
    @NSManaged var id: String

    public static var primaryKeyPath: String? {
        return "id"
    }
}