import SwiftUI

@main
struct PointApp: App {
    private let coreDataStack = CoreDataStack()
    private let itemRepository: ItemRepository
    private let stockMovementRepository: StockMovementRepository
    private let transactionRepository: TransactionRepository

    init() {
        let stack = coreDataStack
        itemRepository = CoreDataItemRepository(stack: stack)
        stockMovementRepository = CoreDataStockMovementRepository(stack: stack)
        transactionRepository = CoreDataTransactionRepository(stack: stack)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(
                itemRepository: itemRepository,
                stockMovementRepository: stockMovementRepository,
                transactionRepository: transactionRepository
            )
            .environmentObject(LocalizationManager.shared)
        }
    }
}
