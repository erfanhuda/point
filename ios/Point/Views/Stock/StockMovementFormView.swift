import SwiftUI

struct StockMovementFormView: View {
    @ObservedObject var viewModel: StockMovementFormViewModel
    @EnvironmentObject private var localization: LocalizationManager
    let onSaved: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent(localization.strings.stock.itemLabel, value: viewModel.item.name)
                    LabeledContent(localization.strings.stock.currentStockLabel, value: "\(viewModel.currentStock)")
                }
                Section(localization.strings.stock.movementSection) {
                    Picker(localization.strings.stock.typeLabel, selection: $viewModel.type) {
                        ForEach(StockMovementType.manualCases) { type in
                            Text(localization.displayName(for: type)).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    DatePicker(localization.strings.common.date, selection: $viewModel.date, displayedComponents: [.date])
                    HStack {
                        Text(viewModel.quantityFieldLabel)
                        Spacer()
                        TextField("0", text: $viewModel.quantityText)
                            .keyboardType(.numbersAndPunctuation)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    TextField(localization.strings.stock.notePlaceholder, text: $viewModel.note)
                        .autocorrectionDisabled()
                }
                if let error = viewModel.errorMessage {
                    Section { Text(error).foregroundStyle(.red) }
                }
            }
            .navigationTitle(localization.displayName(for: viewModel.type))
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
                }
            }
        }
    }
}
