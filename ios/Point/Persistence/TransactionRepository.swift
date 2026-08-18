import Foundation

protocol TransactionRepository {
    func fetchAll() -> [Transaction]
    func save(_ transaction: Transaction) throws
    func delete(id: UUID) throws
}
