import Foundation

@MainActor
final class ItemListViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var searchText: String = ""
    private var stockByItemID: [UUID: Int] = [:]

    private let itemRepository: ItemRepository
    private let stockMovementRepository: StockMovementRepository

    init(itemRepository: ItemRepository, stockMovementRepository: StockMovementRepository) {
        self.itemRepository = itemRepository
        self.stockMovementRepository = stockMovementRepository
    }

    var filteredItems: [Item] {
        let trimmed = searchText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return items }
        return items.filter {
            $0.name.localizedCaseInsensitiveContains(trimmed) || $0.code.localizedCaseInsensitiveContains(trimmed)
        }
    }

    func refresh() {
        items = itemRepository.fetchAll()
        let movements = stockMovementRepository.fetchAll()
        stockByItemID = Dictionary(grouping: movements, by: \.itemID)
            .mapValues { $0.reduce(0) { $0 + $1.quantity } }
    }

    func stock(for item: Item) -> Int { stockByItemID[item.id] ?? 0 }

    func delete(_ item: Item) {
        try? itemRepository.delete(id: item.id)
        refresh()
    }
}
