import XCTest
@testable import Point

final class StockCalculatorTests: XCTestCase {
    func testCurrentStockSumsMovementsForItem() {
        let itemID = UUID()
        let otherItemID = UUID()
        let movements = [
            StockMovement(itemID: itemID, type: .stockIn, quantity: 10),
            StockMovement(itemID: itemID, type: .stockOut, quantity: -3),
            StockMovement(itemID: otherItemID, type: .stockIn, quantity: 100)
        ]

        XCTAssertEqual(StockCalculator.currentStock(itemID: itemID, movements: movements), 7)
    }

    func testStockCardProducesRunningBalanceInDateOrder() {
        let itemID = UUID()
        let earlier = Date(timeIntervalSince1970: 0)
        let later = Date(timeIntervalSince1970: 1000)
        let movements = [
            StockMovement(itemID: itemID, type: .stockOut, quantity: -2, date: later),
            StockMovement(itemID: itemID, type: .stockIn, quantity: 10, date: earlier)
        ]

        let card = StockCalculator.stockCard(itemID: itemID, movements: movements)

        XCTAssertEqual(card.map(\.balance), [10, 8])
    }
}
