import SwiftUI

struct TransactionDetailView: View {
    let transaction: Transaction
    @EnvironmentObject private var localization: LocalizationManager

    var body: some View {
        List {
            Section(localization.strings.transactionDetail.detailsSection) {
                LabeledContent(localization.strings.common.date, value: transaction.date.formatted(date: .abbreviated, time: .shortened))
            }
            Section(localization.strings.transactionDetail.itemsSection) {
                ForEach(transaction.lines) { line in
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(line.itemName)
                            Spacer()
                            Text(line.total.currencyFormatted)
                        }
                        Text(line.variantName.map { "\($0) · \(line.itemCode)" } ?? line.itemCode)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(line.quantity) × \(line.unitPrice.currencyFormatted)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Section(localization.strings.transactionDetail.summarySection) {
                LabeledContent(localization.strings.common.subtotal, value: transaction.subtotal.currencyFormatted)
                LabeledContent(localization.strings.common.discount, value: "-\(transaction.discount.currencyFormatted)")
                if transaction.taxEnabled {
                    LabeledContent(
                        "\(localization.strings.common.tax) (\(NSDecimalNumber(decimal: transaction.taxRate))%)",
                        value: transaction.taxAmount.currencyFormatted
                    )
                }
                LabeledContent(localization.strings.common.total, value: transaction.total.currencyFormatted)
                    .fontWeight(.bold)
            }
        }
        .navigationTitle(localization.strings.transactionDetail.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}
