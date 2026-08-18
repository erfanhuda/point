import SwiftUI

struct ItemDetailView: View {
    @StateObject private var viewModel: ItemDetailViewModel
    @EnvironmentObject private var localization: LocalizationManager
    private let itemRepository: ItemRepository
    private let stockMovementRepository: StockMovementRepository

    @State private var showingEditItem = false
    @State private var movementType: StockMovementType?

    init(item: Item, itemRepository: ItemRepository, stockMovementRepository: StockMovementRepository) {
        self.itemRepository = itemRepository
        self.stockMovementRepository = stockMovementRepository
        _viewModel = StateObject(
            wrappedValue: ItemDetailViewModel(item: item, stockMovementRepository: stockMovementRepository)
        )
    }

    var body: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    thumbnail
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.item.name).font(.headline)
                        Text(viewModel.item.code).font(.subheadline).foregroundStyle(.secondary)
                        Text(viewModel.item.sellPrice.currencyFormatted).font(.subheadline)
                    }
                    Spacer()
                }
                if !viewModel.item.itemDescription.isEmpty {
                    Text(viewModel.item.itemDescription)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                LabeledContent(localization.strings.itemDetail.currentStockLabel, value: "\(viewModel.currentStock)")
            }

            if !viewModel.item.variants.isEmpty {
                Section(localization.strings.itemDetail.variantsSection) {
                    ForEach(viewModel.item.variants) { variant in
                        HStack {
                            Text(variant.name)
                            Spacer()
                            Text(variant.addOnPrice.currencyFormatted).foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section(localization.strings.itemDetail.stockCardSection) {
                if viewModel.stockCard.isEmpty {
                    Text(localization.strings.itemDetail.noMovementsText).foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.stockCard, id: \.movement.id) { entry in
                        StockCardRowView(movement: entry.movement, balance: entry.balance)
                    }
                }
            }
        }
        .navigationTitle(viewModel.item.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(localization.strings.itemDetail.editItemAction) { showingEditItem = true }
                    Divider()
                    ForEach(StockMovementType.manualCases) { type in
                        Button(localization.displayName(for: type)) { movementType = type }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .help(localization.strings.itemDetail.moreOptionsTooltip)
            }
        }
        .onAppear { viewModel.refresh() }
        .sheet(isPresented: $showingEditItem) {
            ItemFormView(
                viewModel: ItemFormViewModel(
                    itemRepository: itemRepository,
                    editingItem: viewModel.item,
                    allItems: itemRepository.fetchAll()
                ),
                onSaved: {
                    if let refreshed = itemRepository.fetchAll().first(where: { $0.id == viewModel.item.id }) {
                        viewModel.item = refreshed
                    }
                    viewModel.refresh()
                }
            )
        }
        .sheet(item: $movementType) { type in
            StockMovementFormView(
                viewModel: StockMovementFormViewModel(
                    item: viewModel.item,
                    currentStock: viewModel.currentStock,
                    stockMovementRepository: stockMovementRepository,
                    type: type
                ),
                onSaved: { viewModel.refresh() }
            )
        }
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let data = viewModel.item.imageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.15))
                .frame(width: 64, height: 64)
                .overlay(Image(systemName: "shippingbox").foregroundStyle(.secondary))
        }
    }
}
