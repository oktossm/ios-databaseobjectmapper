//
// Created by Mikhail Mulyar on 18/06/2018.
//

import CoreData


open class CoreDataContainer: NSManagedObject, SharedDatabaseContainer {
    public static var idKey: WritableKeyPath<CoreDataContainer, String> = \CoreDataContainer.id

    @NSManaged var value: Data?

    public var encodedValue: [String: Any?] {
        get {
            value.flatMap { Dictionary<String, Any?>(archive: $0) } ?? [:]
        }
        set {
            value = newValue.archived
        }
    }
    /// The name of the type that the encoded data is. Used for retrieving all values.
    @NSManaged public var typeName: String

    /// The unique identifier for the data. This property is used as the primary key.
    @NSManaged var id: String
}
