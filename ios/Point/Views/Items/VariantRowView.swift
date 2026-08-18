import SwiftUI

struct VariantRowView: View {
    @Binding var variant: ItemVariant
    let linkableItems: [Item]
    @EnvironmentObject private var localization: LocalizationManager

    private var addOnPriceText: Binding<String> {
        Binding(
            get: { NSDecimalNumber(decimal: variant.addOnPrice).stringValue },
            set: { variant.addOnPrice = DecimalParser.parse($0) ?? 0 }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField(localization.strings.itemForm.variantNamePlaceholder, text: $variant.name)
                .autocorrectionDisabled()
            HStack {
                Text(localization.strings.itemForm.addOnPriceLabel)
                Spacer()
                TextField("0", text: addOnPriceText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
            }
            if !linkableItems.isEmpty {
                Picker(localization.strings.itemForm.linkedItemLabel, selection: $variant.linkedItemID) {
                    Text(localization.strings.common.none).tag(UUID?.none)
                    ForEach(linkableItems) { item in
                        Text(item.name).tag(Optional(item.id))
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
