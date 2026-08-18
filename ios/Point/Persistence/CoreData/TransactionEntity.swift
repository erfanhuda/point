import CoreData

@objc(TransactionEntity)
final class TransactionEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var date: Date
    @NSManaged var linesData: Data?
    @NSManaged var discount: NSDecimalNumber
    @NSManaged var taxEnabled: Bool
    @NSManaged var taxRate: NSDecimalNumber
    @NSManaged var createdAt: Date
}

extension TransactionEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<TransactionEntity> {
        NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
    }

    func toDomain() -> Transaction {
        let lines = linesData.flatMap { try? JSONDecoder().decode([TransactionLine].self, from: $0) } ?? []
        return Transaction(
            id: id,
            date: date,
            lines: lines,
            discount: discount as Decimal,
            taxEnabled: taxEnabled,
            taxRate: taxRate as Decimal,
            createdAt: createdAt
        )
    }

    func update(from transaction: Transaction) {
        id = transaction.id
        date = transaction.date
        linesData = try? JSONEncoder().encode(transaction.lines)
        discount = NSDecimalNumber(decimal: transaction.discount)
        taxEnabled = transaction.taxEnabled
        taxRate = NSDecimalNumber(decimal: transaction.taxRate)
        createdAt = transaction.createdAt
    }
}
