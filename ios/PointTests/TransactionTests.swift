import XCTest
@testable import Point

final class TransactionTests: XCTestCase {
    func testTotalsWithDiscountAndTax() {
        let line = TransactionLine(itemID: UUID(), itemCode: "ITM-0001", itemName: "Coffee", quantity: 2, unitPrice: 20000)
        var transaction = Transaction(lines: [line], discount: 5000, taxEnabled: true, taxRate: 10)

        XCTAssertEqual(transaction.subtotal, 40000)
        XCTAssertEqual(transaction.discountedSubtotal, 35000)
        XCTAssertEqual(transaction.taxAmount, 3500)
        XCTAssertEqual(transaction.total, 38500)

        transaction.taxEnabled = false
        XCTAssertEqual(transaction.total, 35000)
    }

    func testDiscountNeverPushesSubtotalNegative() {
        let line = TransactionLine(itemID: UUID(), itemCode: "ITM-0001", itemName: "Coffee", quantity: 1, unitPrice: 10000)
        let transaction = Transaction(lines: [line], discount: 50000)

        XCTAssertEqual(transaction.discountedSubtotal, 0)
        XCTAssertEqual(transaction.total, 0)
    }

    func testIsValidRequiresNonEmptyLinesWithPositiveQuantity() {
        XCTAssertFalse(Transaction(lines: []).isValid)

        let zeroQuantityLine = TransactionLine(itemID: UUID(), itemCode: "ITM-0001", itemName: "Coffee", quantity: 0, unitPrice: 10000)
        XCTAssertFalse(Transaction(lines: [zeroQuantityLine]).isValid)

        let validLine = TransactionLine(itemID: UUID(), itemCode: "ITM-0001", itemName: "Coffee", quantity: 1, unitPrice: 10000)
        XCTAssertTrue(Transaction(lines: [validLine]).isValid)
    }
}
