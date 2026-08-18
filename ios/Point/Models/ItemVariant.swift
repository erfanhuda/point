import Foundation

/// A dynamic variant of an `Item`. Either a free-form name with its own
/// add-on price, or a reference to another existing `Item` profile (e.g. a
/// "variant" that is really a bundled/related product), or both at once —
/// `linkedItemID` just adds a relationship on top of the name/add-on price.
struct ItemVariant: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var addOnPrice: Decimal
    var linkedItemID: UUID?

    init(
        id: UUID = UUID(),
        name: String,
        addOnPrice: Decimal = 0,
        linkedItemID: UUID? = nil
    ) {
        self.id = id
        self.name = name
        self.addOnPrice = addOnPrice
        self.linkedItemID = linkedItemID
    }
}
