import SwiftUI

struct ContentView: View {
    let itemRepository: ItemRepository
    let stockMovementRepository: StockMovementRepository
    let transactionRepository: TransactionRepository

    @EnvironmentObject private var localization: LocalizationManager

    var body: some View {
        TabView {
            ItemListView(
                itemRepository: itemRepository,
                stockMovementRepository: stockMovementRepository
            )
            .tabItem {
                Label(localization.strings.tabs.items, systemImage: "shippingbox")
            }

            TransactionListView(
                itemRepository: itemRepository,
                stockMovementRepository: stockMovementRepository,
                transactionRepository: transactionRepository
            )
            .tabItem {
                Label(localization.strings.tabs.sales, systemImage: "cart")
            }

            SettingsView()
                .tabItem {
                    Label(localization.strings.tabs.settings, systemImage: "gearshape")
                }
        }
    }
}
