import CoreData

@objc(StockMovementEntity)
final class StockMovementEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var itemID: UUID
    @NSManaged var variantID: UUID?
    @NSManaged var type: String
    @NSManaged var quantity: Int32
    @NSManaged var date: Date
    @NSManaged var note: String
    @NSManaged var transactionID: UUID?
    @NSManaged var createdAt: Date
}

extension StockMovementEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<StockMovementEntity> {
        NSFetchRequest<StockMovementEntity>(entityName: "StockMovementEntity")
    }

    func toDomain() -> StockMovement {
        StockMovement(
            id: id,
            itemID: itemID,
            variantID: variantID,
            type: StockMovementType(rawValue: type) ?? .correction,
            quantity: Int(quantity),
            date: date,
            note: note,
            transactionID: transactionID,
            createdAt: createdAt
        )
    }

    func update(from movement: StockMovement) {
        id = movement.id
        itemID = movement.itemID
        variantID = movement.variantID
        type = movement.type.rawValue
        quantity = Int32(movement.quantity)
        date = movement.date
        note = movement.note
        transactionID = movement.transactionID
        createdAt = movement.createdAt
    }
}
