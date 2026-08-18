import Foundation

@MainActor
final class StockMovementFormViewModel: ObservableObject {
    @Published var type: StockMovementType
    @Published var quantityText: String = ""
    @Published var note: String = ""
    @Published var date: Date = Date()
    @Published var errorMessage: String?

    let item: Item
    let currentStock: Int
    private let stockMovementRepository: StockMovementRepository

    init(item: Item, currentStock: Int, stockMovementRepository: StockMovementRepository, type: StockMovementType = .stockIn) {
        self.item = item
        self.currentStock = currentStock
        self.stockMovementRepository = stockMovementRepository
        self.type = type
    }

    var quantityFieldLabel: String {
        let strings = LocalizationManager.shared.strings.stock
        switch type {
        case .stockIn: return strings.quantityToAdd
        case .correction: return strings.adjustmentQuantity
        case .opname: return strings.opnameQuantity
        case .stockOut: return strings.stockOutQuantity
        }
    }

    @discardableResult
    func save() -> Bool {
        guard let enteredQuantity = Int(quantityText.trimmingCharacters(in: .whitespaces)) else {
            errorMessage = LocalizationManager.shared.strings.errors.quantityWholeNumber
            return false
        }

        let delta: Int
        switch type {
        case .stockIn:
            guard enteredQuantity > 0 else {
                errorMessage = LocalizationManager.shared.strings.errors.stockInPositive
                return false
            }
            delta = enteredQuantity
        case .correction:
            delta = enteredQuantity
        case .opname:
            delta = enteredQuantity - currentStock
        case .stockOut:
            delta = -abs(enteredQuantity)
        }

        guard delta != 0 else {
            errorMessage = LocalizationManager.shared.strings.errors.noStockChange
            return false
        }

        let movement = StockMovement(itemID: item.id, type: type, quantity: delta, date: date, note: note)
        do {
            try stockMovementRepository.save(movement)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
