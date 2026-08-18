import SwiftUI

struct AddOrderLineView: View {
    let items: [Item]
    let stockLookup: (Item) -> Int
    let onAdd: (Item, ItemVariant?, Int) -> Void
    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedItem: Item?
    @State private var selectedVariant: ItemVariant?
    @State private var quantityText: String = "1"
    @State private var searchText: String = ""

    private var filteredItems: [Item] {
        guard !searchText.isEmpty else { return items }
        return items.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) || $0.code.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(localization.strings.addOrderLine.itemSection) {
                    Picker(localization.strings.addOrderLine.itemSection, selection: $selectedItem) {
                        Text(localization.strings.addOrderLine.selectItemPlaceholder).tag(Item?.none)
                        ForEach(filteredItems) { item in
                            Text("\(item.name) (\(item.code))").tag(Optional(item))
                        }
                    }
                }

                if let selectedItem, !selectedItem.variants.isEmpty {
                    Section(localization.strings.addOrderLine.variantSection) {
                        Picker(localization.strings.addOrderLine.variantSection, selection: $selectedVariant) {
                            Text(localization.strings.common.none).tag(ItemVariant?.none)
                            ForEach(selectedItem.variants) { variant in
                                Text("\(variant.name) (+\(variant.addOnPrice.currencyFormatted))").tag(Optional(variant))
                            }
                        }
                    }
                }

                if let selectedItem {
                    Section {
                        LabeledContent(localization.strings.addOrderLine.inStockLabel, value: "\(stockLookup(selectedItem))")
                        HStack {
                            Text(localization.strings.common.quantity)
                            Spacer()
                            TextField("1", text: $quantityText)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                        }
                        HStack {
                            Text(localization.strings.addOrderLine.unitPriceLabel)
                            Spacer()
                            Text(unitPrice(for: selectedItem).currencyFormatted)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: localization.strings.addOrderLine.searchPrompt)
            .navigationTitle(localization.strings.addOrderLine.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(localization.strings.common.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(localization.strings.addOrderLine.addAction) {
                        if let selectedItem, let quantity = Int(quantityText), quantity > 0 {
                            onAdd(selectedItem, selectedVariant, quantity)
                            dismiss()
                        }
                    }
                    .disabled(selectedItem == nil || !(Int(quantityText).map { $0 > 0 } ?? false))
                }
            }
            .onChange(of: selectedItem) { _ in
                selectedVariant = nil
            }
        }
    }

    private func unitPrice(for item: Item) -> Decimal {
        item.sellPrice + (selectedVariant?.addOnPrice ?? 0)
    }
}
