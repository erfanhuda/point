import Foundation

enum StockMovementType: String, Codable, CaseIterable, Identifiable {
    case stockIn
    case stockOut
    case correction
    case opname

    var id: String { rawValue }

    /// Movement types a user can create by hand from the Stock tab.
    /// `.stockOut` is deliberately excluded — it is only ever recorded
    /// automatically when a sell transaction is saved.
    static var manualCases: [StockMovementType] { [.stockIn, .correction, .opname] }
}
