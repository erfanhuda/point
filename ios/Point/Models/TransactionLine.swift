import Foundation

/// One line of a sell `Transaction`. Item/variant details are snapshotted at
/// sale time (rather than looked up live through `itemID`) so a later edit
/// or deletion of the item never rewrites the historical receipt.
struct TransactionLine: Identifiable, Codable, Equatable {
    let id: UUID
    var itemID: UUID
    var itemCode: String
    var itemName: String
    var variantID: UUID?
    var variantName: String?
    var quantity: Int
    var unitPrice: Decimal

    init(
        id: UUID = UUID(),
        itemID: UUID,
        itemCode: String,
        itemName: String,
        variantID: UUID? = nil,
        variantName: String? = nil,
        quantity: Int,
        unitPrice: Decimal
    ) {
        self.id = id
        self.itemID = itemID
        self.itemCode = itemCode
        self.itemName = itemName
        self.variantID = variantID
        self.variantName = variantName
        self.quantity = quantity
        self.unitPrice = unitPrice
    }

    var total: Decimal { unitPrice * Decimal(quantity) }
}
