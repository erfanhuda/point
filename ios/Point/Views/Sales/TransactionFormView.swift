import SwiftUI

struct TransactionFormView: View {
    @StateObject private var viewModel: TransactionFormViewModel
    @EnvironmentObject private var localization: LocalizationManager
    let onSaved: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var showingAddLine = false

    init(
        itemRepository: ItemRepository,
        stockMovementRepository: StockMovementRepository,
        transactionRepository: TransactionRepository,
        onSaved: @escaping () -> Void
    ) {
        self.onSaved = onSaved
        let items = itemRepository.fetchAll()
        let movements = stockMovementRepository.fetchAll()
        let stockByItemID = Dictionary(grouping: movements, by: \.itemID)
            .mapValues { $0.reduce(0) { $0 + $1.quantity } }
        _viewModel = StateObject(
            wrappedValue: TransactionFormViewModel(
                items: items,
                stockByItemID: stockByItemID,
                transactionRepository: transactionRepository,
                stockMovementRepository: stockMovementRepository
            )
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(localization.strings.sales.transactionDateSection) {
                    DatePicker(localization.strings.common.date, selection: $viewModel.date, displayedComponents: [.date])
                }

                Section(localization.strings.sales.itemsSection) {
                    ForEach(viewModel.lines) { line in
                        OrderLineRowView(line: line)
                    }
                    .onDelete { viewModel.removeLines(at: $0) }
                    Button {
                        showingAddLine = true
                    } label: {
                        Label(localization.strings.sales.addItem, systemImage: "plus.circle")
                    }
                    .disabled(viewModel.items.isEmpty)
                }

                Section(localization.strings.sales.discountTaxSection) {
                    HStack {
                        Text(localization.strings.common.discount)
                        Spacer()
                        TextField("0", text: $viewModel.discountText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    Toggle(localization.strings.sales.applyTax, isOn: $viewModel.taxEnabled)
                    if viewModel.taxEnabled {
                        HStack {
                            Text(localization.strings.sales.taxRateLabel)
                            Spacer()
                            TextField("0", text: $viewModel.taxRateText)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                        }
                    }
                }

                Section(localization.strings.sales.summarySection) {
                    LabeledContent(localization.strings.common.subtotal, value: viewModel.subtotal.currencyFormatted)
                    LabeledContent(localization.strings.common.discount, value: "-\(viewModel.discount.currencyFormatted)")
                    if viewModel.taxEnabled {
                        LabeledContent(localization.strings.common.tax, value: viewModel.taxAmount.currencyFormatted)
                    }
                    LabeledContent(localization.strings.common.total, value: viewModel.total.currencyFormatted)
                        .fontWeight(.bold)
                }

                if let error = viewModel.errorMessage {
                    Section { Text(error).foregroundStyle(.red) }
                }
            }
            .navigationTitle(localization.strings.sales.newSaleTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(localization.strings.common.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(localization.strings.common.save) {
                        if viewModel.save() {
                            onSaved()
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .sheet(isPresented: $showingAddLine) {
                AddOrderLineView(items: viewModel.items, stockLookup: viewModel.availableStock) { item, variant, quantity in
                    viewModel.addLine(item: item, variant: variant, quantity: quantity)
                }
            }
        }
    }
}

private struct OrderLineRowView: View {
    let line: TransactionLine

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(line.itemName).font(.subheadline)
                Text(line.variantName.map { "\($0) · \(line.itemCode)" } ?? line.itemCode)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(line.quantity) × \(line.unitPrice.currencyFormatted)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(line.total.currencyFormatted).fontWeight(.medium)
        }
    }
}
