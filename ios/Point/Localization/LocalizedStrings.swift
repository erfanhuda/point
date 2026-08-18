import Foundation

/// All user-facing text in the app, loaded from `Resources/Localization/<lang>.json`
/// and decoded straight into this type — field names match the JSON keys
/// exactly, so no `CodingKeys` are needed. See `LocalizationManager`.
struct LocalizedStrings: Codable {
    let tabs: TabsStrings
    let common: CommonStrings
    let items: ItemsStrings
    let itemForm: ItemFormStrings
    let itemDetail: ItemDetailStrings
    let stock: StockStrings
    let sales: SalesStrings
    let addOrderLine: AddOrderLineStrings
    let transactionDetail: TransactionDetailStrings
    let settings: SettingsStrings
    let errors: ErrorStrings
}

struct TabsStrings: Codable {
    let items: String
    let sales: String
    let settings: String
}

struct CommonStrings: Codable {
    let cancel: String
    let save: String
    let add: String
    let none: String
    let subtotal: String
    let discount: String
    let tax: String
    let total: String
    let date: String
    let quantity: String
    let note: String
}

struct ItemsStrings: Codable {
    let navigationTitle: String
    let searchPrompt: String
    let emptyTitle: String
    let emptySubtitle: String
    let stockPrefix: String
    let addItemTooltip: String
}

struct ItemFormStrings: Codable {
    let newTitle: String
    let editTitle: String
    let photoSection: String
    let choosePhoto: String
    let removePhoto: String
    let detailsSection: String
    let codeLabel: String
    let namePlaceholder: String
    let descriptionPlaceholder: String
    let sellPriceLabel: String
    let variantsSection: String
    let variantsFooter: String
    let addVariant: String
    let variantNamePlaceholder: String
    let addOnPriceLabel: String
    let linkedItemLabel: String
}

struct ItemDetailStrings: Codable {
    let currentStockLabel: String
    let variantsSection: String
    let stockCardSection: String
    let noMovementsText: String
    let editItemAction: String
    let moreOptionsTooltip: String
    let balancePrefix: String
}

struct StockStrings: Codable {
    let itemLabel: String
    let currentStockLabel: String
    let movementSection: String
    let typeLabel: String
    let notePlaceholder: String
    let quantityToAdd: String
    let adjustmentQuantity: String
    let opnameQuantity: String
    let stockOutQuantity: String
    let stockInName: String
    let stockOutName: String
    let correctionName: String
    let opnameName: String
}

struct SalesStrings: Codable {
    let navigationTitle: String
    let emptyTitle: String
    let emptySubtitle: String
    let itemsCountSuffix: String
    let addSaleTooltip: String
    let newSaleTitle: String
    let transactionDateSection: String
    let itemsSection: String
    let addItem: String
    let discountTaxSection: String
    let applyTax: String
    let taxRateLabel: String
    let summarySection: String
    let soldInTransactionNote: String
}

struct AddOrderLineStrings: Codable {
    let navigationTitle: String
    let itemSection: String
    let selectItemPlaceholder: String
    let variantSection: String
    let inStockLabel: String
    let unitPriceLabel: String
    let searchPrompt: String
    let addAction: String
}

struct TransactionDetailStrings: Codable {
    let navigationTitle: String
    let detailsSection: String
    let itemsSection: String
    let summarySection: String
}

struct SettingsStrings: Codable {
    let navigationTitle: String
    let languageSection: String
    let languageFooter: String
}

struct ErrorStrings: Codable {
    let itemNameAndPrice: String
    let quantityWholeNumber: String
    let stockInPositive: String
    let noStockChange: String
    let emptyOrder: String
}
