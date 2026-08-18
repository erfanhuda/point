import Foundation

protocol StockMovementRepository {
    func fetchAll() -> [StockMovement]
    func fetchAll(itemID: UUID) -> [StockMovement]
    func save(_ movement: StockMovement) throws
    func delete(id: UUID) throws
}
