import CoreData

@objc(ItemEntity)
final class ItemEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var code: String
    @NSManaged var name: String
    @NSManaged var itemDescription: String
    @NSManaged var imageData: Data?
    @NSManaged var sellPrice: NSDecimalNumber
    @NSManaged var variantsData: Data?
    @NSManaged var createdAt: Date
}

extension ItemEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<ItemEntity> {
        NSFetchRequest<ItemEntity>(entityName: "ItemEntity")
    }

    func toDomain() -> Item {
        let variants = variantsData.flatMap { try? JSONDecoder().decode([ItemVariant].self, from: $0) } ?? []
        return Item(
            id: id,
            code: code,
            name: name,
            itemDescription: itemDescription,
            imageData: imageData,
            sellPrice: sellPrice as Decimal,
            variants: variants,
            createdAt: createdAt
        )
    }

    func update(from item: Item) {
        id = item.id
        code = item.code
        name = item.name
        itemDescription = item.itemDescription
        imageData = item.imageData
        sellPrice = NSDecimalNumber(decimal: item.sellPrice)
        variantsData = try? JSONEncoder().encode(item.variants)
        createdAt = item.createdAt
    }
}
