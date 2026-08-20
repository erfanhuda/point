import Foundation

@MainActor
final class TransactionFormViewModel: ObservableObject {
    @Published var date: Date = Date()
    @Published var lines: [TransactionLine] = []
    @Published var discountText: String = "0"
    @Published var taxEnabled: Bool = false
    @Published var taxRateText: String = "11"
    @Published var errorMessage: String?

    let items: [Item]
    private let stockByItemID: [UUID: Int]
    private let transactionRepository: TransactionRepository
    private let stockMovementRepository: StockMovementRepository

    init(
        items: [Item],
        stockByItemID: [UUID: Int],
        transactionRepository: TransactionRepository,
        stockMovementRepository: StockMovementRepository
    ) {
        self.items = items
        self.stockByItemID = stockByItemID
        self.transactionRepository = transactionRepository
        self.stockMovementRepository = stockMovementRepository
    }

    var discount: Decimal { DecimalParser.parse(discountText) ?? 0 }
    var taxRate: Decimal { DecimalParser.parse(taxRateText) ?? 0 }
    var subtotal: Decimal { lines.reduce(0) { $0 + $1.total } }
    var discountedSubtotal: Decimal { max(0, subtotal - discount) }
    var taxAmount: Decimal { taxEnabled ? discountedSubtotal * taxRate / 100 : 0 }
    var total: Decimal { discountedSubtotal + taxAmount }
    var canSave: Bool { !lines.isEmpty }

    func availableStock(for item: Item) -> Int { stockByItemID[item.id] ?? 0 }

    func addLine(item: Item, variant: ItemVariant?, quantity: Int) {
        let unitPrice = item.sellPrice + (variant?.addOnPrice ?? 0)
        let line = TransactionLine(
            itemID: item.id,
            itemCode: item.code,
            itemName: item.name,
            variantID: variant?.id,
            variantName: variant?.name,
            quantity: quantity,
            unitPrice: unitPrice
        )
        lines.append(line)
    }

    func removeLines(at offsets: IndexSet) {
        lines.remove(atOffsets: offsets)
    }

    /// A not-yet-persisted `Transaction` built from the form's current
    /// fields — used to render the receipt preview in the save-confirmation
    /// sheet before the user commits. Pass the exact same value back into
    /// `save(_:)` so the previewed receipt and the persisted record match.
    var draftTransaction: Transaction {
        Transaction(date: date, lines: lines, discount: discount, taxEnabled: taxEnabled, taxRate: taxRate)
    }

    /// Persists `transaction` (normally `draftTransaction`, previewed by the
    /// caller before confirming) and returns it on success, or `nil` on
    /// failure — `errorMessage` explains why.
    @discardableResult
    func save(_ transaction: Transaction) -> Transaction? {
        guard canSave else {
            errorMessage = LocalizationManager.shared.strings.errors.emptyOrder
            return nil
        }
        do {
            try transactionRepository.save(transaction)
            for line in transaction.lines {
                let movement = StockMovement(
                    itemID: line.itemID,
                    variantID: line.variantID,
                    type: .stockOut,
                    quantity: -line.quantity,
                    date: transaction.date,
                    note: LocalizationManager.shared.strings.sales.soldInTransactionNote,
                    transactionID: transaction.id
                )
                try stockMovementRepository.save(movement)
            }
            return transaction
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
