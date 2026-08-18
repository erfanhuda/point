import SwiftUI

struct TransactionListView: View {
    @StateObject private var viewModel: TransactionListViewModel
    @EnvironmentObject private var localization: LocalizationManager
    private let itemRepository: ItemRepository
    private let stockMovementRepository: StockMovementRepository
    private let transactionRepository: TransactionRepository

    @State private var showingNewSale = false

    init(
        itemRepository: ItemRepository,
        stockMovementRepository: StockMovementRepository,
        transactionRepository: TransactionRepository
    ) {
        self.itemRepository = itemRepository
        self.stockMovementRepository = stockMovementRepository
        self.transactionRepository = transactionRepository
        _viewModel = StateObject(wrappedValue: TransactionListViewModel(transactionRepository: transactionRepository))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.transactions.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(viewModel.transactions) { transaction in
                            NavigationLink {
                                TransactionDetailView(transaction: transaction)
                            } label: {
                                TransactionRowView(transaction: transaction)
                            }
                        }
                        .onDelete { offsets in
                            for index in offsets {
                                viewModel.delete(viewModel.transactions[index])
                            }
                        }
                    }
                }
            }
            .navigationTitle(localization.strings.sales.navigationTitle)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewSale = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .help(localization.strings.sales.addSaleTooltip)
                    .disabled(itemRepository.fetchAll().isEmpty)
                }
            }
            .onAppear { viewModel.refresh() }
            .sheet(isPresented: $showingNewSale) {
                TransactionFormView(
                    itemRepository: itemRepository,
                    stockMovementRepository: stockMovementRepository,
                    transactionRepository: transactionRepository,
                    onSaved: { viewModel.refresh() }
                )
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "cart")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text(localization.strings.sales.emptyTitle)
                .font(.headline)
            Text(localization.strings.sales.emptySubtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

private struct TransactionRowView: View {
    let transaction: Transaction
    @EnvironmentObject private var localization: LocalizationManager

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.date.formatted(date: .abbreviated, time: .shortened)).font(.subheadline)
                Text("\(transaction.lines.count) \(localization.strings.sales.itemsCountSuffix)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(transaction.total.currencyFormatted).fontWeight(.semibold)
        }
    }
}
