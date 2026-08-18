import SwiftUI

enum ItemFormContext: Identifiable {
    case new
    case edit(Item)

    var id: String {
        switch self {
        case .new: return "new"
        case .edit(let item): return "edit-\(item.id)"
        }
    }

    var editingItem: Item? {
        if case .edit(let item) = self { return item }
        return nil
    }
}

struct ItemListView: View {
    @StateObject private var viewModel: ItemListViewModel
    @EnvironmentObject private var localization: LocalizationManager
    private let itemRepository: ItemRepository
    private let stockMovementRepository: StockMovementRepository

    @State private var formContext: ItemFormContext?

    init(itemRepository: ItemRepository, stockMovementRepository: StockMovementRepository) {
        self.itemRepository = itemRepository
        self.stockMovementRepository = stockMovementRepository
        _viewModel = StateObject(
            wrappedValue: ItemListViewModel(
                itemRepository: itemRepository,
                stockMovementRepository: stockMovementRepository
            )
        )
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.items.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(viewModel.filteredItems) { item in
                            NavigationLink {
                                ItemDetailView(
                                    item: item,
                                    itemRepository: itemRepository,
                                    stockMovementRepository: stockMovementRepository
                                )
                            } label: {
                                ItemRowView(item: item, stock: viewModel.stock(for: item))
                            }
                        }
                        .onDelete { offsets in
                            for index in offsets {
                                viewModel.delete(viewModel.filteredItems[index])
                            }
                        }
                    }
                    .searchable(text: $viewModel.searchText, prompt: localization.strings.items.searchPrompt)
                }
            }
            .navigationTitle(localization.strings.items.navigationTitle)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        formContext = .new
                    } label: {
                        Image(systemName: "plus")
                    }
                    .help(localization.strings.items.addItemTooltip)
                }
            }
            .onAppear { viewModel.refresh() }
            .sheet(item: $formContext) { context in
                ItemFormView(
                    viewModel: ItemFormViewModel(
                        itemRepository: itemRepository,
                        editingItem: context.editingItem,
                        allItems: viewModel.items
                    ),
                    onSaved: { viewModel.refresh() }
                )
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "shippingbox")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text(localization.strings.items.emptyTitle)
                .font(.headline)
            Text(localization.strings.items.emptySubtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

private struct ItemRowView: View {
    let item: Item
    let stock: Int
    @EnvironmentObject private var localization: LocalizationManager

    var body: some View {
        HStack(spacing: 12) {
            thumbnail
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name).font(.body)
                Text(item.code).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(item.sellPrice.currencyFormatted).font(.subheadline)
                Text("\(localization.strings.items.stockPrefix): \(stock)")
                    .font(.caption)
                    .foregroundStyle(stock > 0 ? Color.secondary : Color.red)
            }
        }
        .padding(.vertical, 2)
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let data = item.imageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(Image(systemName: "shippingbox").foregroundStyle(.secondary))
        }
    }
}
