import Foundation

struct Transaction: Identifiable, Codable, Equatable {
    let id: UUID
    var date: Date
    var lines: [TransactionLine]
    /// Flat currency amount subtracted from the subtotal before tax.
    var discount: Decimal
    var taxEnabled: Bool
    /// Percentage (e.g. 11 for 11%), applied to (subtotal - discount) when `taxEnabled`.
    var taxRate: Decimal
    let createdAt: Date

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        lines: [TransactionLine] = [],
        discount: Decimal = 0,
        taxEnabled: Bool = false,
        taxRate: Decimal = 11,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.lines = lines
        self.discount = discount
        self.taxEnabled = taxEnabled
        self.taxRate = taxRate
        self.createdAt = createdAt
    }

    var subtotal: Decimal { lines.reduce(0) { $0 + $1.total } }
    var discountedSubtotal: Decimal { max(0, subtotal - discount) }
    var taxAmount: Decimal { taxEnabled ? discountedSubtotal * taxRate / 100 : 0 }
    var total: Decimal { discountedSubtotal + taxAmount }
    var isValid: Bool { !lines.isEmpty && lines.allSatisfy { $0.quantity > 0 } }
}
