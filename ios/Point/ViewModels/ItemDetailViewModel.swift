import Foundation

@MainActor
final class ItemDetailViewModel: ObservableObject {
    @Published var item: Item
    /// Most recent movement first.
    @Published var stockCard: [(movement: StockMovement, balance: Int)] = []

    private let stockMovementRepository: StockMovementRepository

    init(item: Item, stockMovementRepository: StockMovementRepository) {
        self.item = item
        self.stockMovementRepository = stockMovementRepository
    }

    var currentStock: Int { stockCard.first?.balance ?? 0 }

    func refresh() {
        let movements = stockMovementRepository.fetchAll(itemID: item.id)
        stockCard = StockCalculator.stockCard(itemID: item.id, movements: movements).reversed()
    }
}
