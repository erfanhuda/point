import CoreData

/// Builds the Core Data model entirely in code, the same approach the
/// sibling Ledger app uses (this environment's Xcode has no visual
/// `.xcdatamodeld` editor) — this file is the single source of truth for
/// the schema.
///
/// `ItemVariant` lists and `TransactionLine` lists are stored as JSON-encoded
/// `Data` blobs on their owning entity rather than as separate related
/// entities: nothing ever needs to query a variant or a line independently
/// of its parent, so a relationship would only add ceremony without buying
/// anything — deliberately simple over "fully idiomatic" Core Data.
enum CoreDataModel {
    /// Memoized for the same reason as Ledger's: Core Data resolves
    /// `NSManagedObject` subclasses to entities by class name across every
    /// live `NSManagedObjectModel`, so building a fresh model per
    /// `CoreDataStack` makes that resolution ambiguous.
    static let shared: NSManagedObjectModel = make()

    private static func make() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let item = NSEntityDescription()
        item.name = "ItemEntity"
        item.managedObjectClassName = NSStringFromClass(ItemEntity.self)
        item.properties = [
            attribute("id", .UUIDAttributeType),
            attribute("code", .stringAttributeType),
            attribute("name", .stringAttributeType),
            attribute("itemDescription", .stringAttributeType, defaultValue: ""),
            attribute("imageData", .binaryDataAttributeType, optional: true),
            attribute("sellPrice", .decimalAttributeType),
            attribute("variantsData", .binaryDataAttributeType, optional: true),
            attribute("createdAt", .dateAttributeType)
        ]

        let stockMovement = NSEntityDescription()
        stockMovement.name = "StockMovementEntity"
        stockMovement.managedObjectClassName = NSStringFromClass(StockMovementEntity.self)
        stockMovement.properties = [
            attribute("id", .UUIDAttributeType),
            attribute("itemID", .UUIDAttributeType),
            attribute("variantID", .UUIDAttributeType, optional: true),
            attribute("type", .stringAttributeType),
            attribute("quantity", .integer32AttributeType),
            attribute("date", .dateAttributeType),
            attribute("note", .stringAttributeType, defaultValue: ""),
            attribute("transactionID", .UUIDAttributeType, optional: true),
            attribute("createdAt", .dateAttributeType)
        ]

        let transaction = NSEntityDescription()
        transaction.name = "TransactionEntity"
        transaction.managedObjectClassName = NSStringFromClass(TransactionEntity.self)
        transaction.properties = [
            attribute("id", .UUIDAttributeType),
            attribute("date", .dateAttributeType),
            attribute("linesData", .binaryDataAttributeType, optional: true),
            attribute("discount", .decimalAttributeType, defaultValue: NSDecimalNumber(value: 0)),
            attribute("taxEnabled", .booleanAttributeType, defaultValue: false),
            attribute("taxRate", .decimalAttributeType, defaultValue: NSDecimalNumber(value: 0)),
            attribute("createdAt", .dateAttributeType)
        ]

        model.entities = [item, stockMovement, transaction]
        return model
    }

    private static func attribute(
        _ name: String,
        _ type: NSAttributeType,
        optional: Bool = false,
        defaultValue: Any? = nil
    ) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = optional
        attribute.defaultValue = defaultValue
        return attribute
    }
}
