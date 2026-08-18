import Foundation

@MainActor
final class ItemFormViewModel: ObservableObject {
    @Published var name: String
    @Published var itemDescription: String
    @Published var sellPriceText: String
    @Published var imageData: Data?
    @Published var variants: [ItemVariant]
    @Published var errorMessage: String?

    let editingItem: Item?
    /// Candidates for a variant's "link to another item" picker — every
    /// other item, excluding the one currently being edited.
    let linkableItems: [Item]

    private let itemRepository: ItemRepository

    init(itemRepository: ItemRepository, editingItem: Item?, allItems: [Item]) {
        self.itemRepository = itemRepository
        self.editingItem = editingItem
        self.linkableItems = allItems.filter { $0.id != editingItem?.id }
        name = editingItem?.name ?? ""
        itemDescription = editingItem?.itemDescription ?? ""
        sellPriceText = editingItem.map { NSDecimalNumber(decimal: $0.sellPrice).stringValue } ?? ""
        imageData = editingItem?.imageData
        variants = editingItem?.variants ?? []
    }

    var isEditing: Bool { editingItem != nil }

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && DecimalParser.parse(sellPriceText) != nil
    }

    func addVariant() {
        variants.append(ItemVariant(name: "", addOnPrice: 0))
    }

    func removeVariants(at offsets: IndexSet) {
        variants.remove(atOffsets: offsets)
    }

    func linkedItemName(for variant: ItemVariant) -> String? {
        guard let linkedItemID = variant.linkedItemID else { return nil }
        return linkableItems.first(where: { $0.id == linkedItemID })?.name
    }

    @discardableResult
    func save() -> Bool {
        guard canSave, let sellPrice = DecimalParser.parse(sellPriceText) else {
            errorMessage = LocalizationManager.shared.strings.errors.itemNameAndPrice
            return false
        }
        let trimmedVariants = variants.filter { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }
        do {
            if let editingItem {
                let updated = Item(
                    id: editingItem.id,
                    code: editingItem.code,
                    name: name,
                    itemDescription: itemDescription,
                    imageData: imageData,
                    sellPrice: sellPrice,
                    variants: trimmedVariants,
                    createdAt: editingItem.createdAt
                )
                try itemRepository.update(updated)
            } else {
                let newItem = Item(
                    code: "",
                    name: name,
                    itemDescription: itemDescription,
                    imageData: imageData,
                    sellPrice: sellPrice,
                    variants: trimmedVariants
                )
                try itemRepository.create(newItem)
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
