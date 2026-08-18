import SwiftUI

struct StockCardRowView: View {
    let movement: StockMovement
    let balance: Int
    @EnvironmentObject private var localization: LocalizationManager

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(localization.displayName(for: movement.type)).font(.subheadline).fontWeight(.medium)
                Text(movement.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !movement.note.isEmpty {
                    Text(movement.note).font(.caption).foregroundStyle(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(movement.quantity > 0 ? "+\(movement.quantity)" : "\(movement.quantity)")
                    .foregroundStyle(movement.quantity >= 0 ? Color.green : Color.red)
                Text("\(localization.strings.itemDetail.balancePrefix): \(balance)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
