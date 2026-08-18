import Foundation

/// Current stock is never stored — it is always the running sum of an
/// item's stock movements in date order, mirroring how the sibling Ledger
/// app derives account balances from journal lines instead of storing them.
enum StockCalculator {
    static func currentStock(itemID: UUID, movements: [StockMovement]) -> Int {
        movements
            .filter { $0.itemID == itemID }
            .reduce(0) { $0 + $1.quantity }
    }

    /// Running balance after each movement, in date order — the "stock
    /// card" shown on an item's detail screen.
    static func stockCard(itemID: UUID, movements: [StockMovement]) -> [(movement: StockMovement, balance: Int)] {
        var running = 0
        return movements
            .filter { $0.itemID == itemID }
            .sorted { $0.date < $1.date }
            .map { movement in
                running += movement.quantity
                return (movement, running)
            }
    }
}
