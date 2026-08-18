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

    @discardableResult
    func save() -> Bool {
        guard canSave else {
            errorMessage = LocalizationManager.shared.strings.errors.emptyOrder
            return false
        }
        let transaction = Transaction(date: date, lines: lines, discount: discount, taxEnabled: taxEnabled, taxRate: taxRate)
        do {
            try transactionRepository.save(transaction)
            for line in lines {
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
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
