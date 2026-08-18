import Foundation

@MainActor
final class TransactionListViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []

    private let transactionRepository: TransactionRepository

    init(transactionRepository: TransactionRepository) {
        self.transactionRepository = transactionRepository
    }

    func refresh() {
        transactions = transactionRepository.fetchAll()
    }

    func delete(_ transaction: Transaction) {
        try? transactionRepository.delete(id: transaction.id)
        refresh()
    }
}
