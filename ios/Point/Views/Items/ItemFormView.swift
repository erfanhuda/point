import PhotosUI
import SwiftUI

struct ItemFormView: View {
    @ObservedObject var viewModel: ItemFormViewModel
    @EnvironmentObject private var localization: LocalizationManager
    let onSaved: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var photoPickerItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            Form {
                Section(localization.strings.itemForm.photoSection) {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            photo
                            PhotosPicker(localization.strings.itemForm.choosePhoto, selection: $photoPickerItem, matching: .images)
                            if viewModel.imageData != nil {
                                Button(localization.strings.itemForm.removePhoto, role: .destructive) {
                                    viewModel.imageData = nil
                                    photoPickerItem = nil
                                }
                            }
                        }
                        Spacer()
                    }
                }

                Section(localization.strings.itemForm.detailsSection) {
                    if let code = viewModel.editingItem?.code {
                        LabeledContent(localization.strings.itemForm.codeLabel, value: code)
                    }
                    TextField(localization.strings.itemForm.namePlaceholder, text: $viewModel.name)
                        .autocorrectionDisabled()
                    TextField(localization.strings.itemForm.descriptionPlaceholder, text: $viewModel.itemDescription, axis: .vertical)
                        .lineLimit(2...4)
                        .autocorrectionDisabled()
                    HStack {
                        Text(localization.strings.itemForm.sellPriceLabel)
                        Spacer()
                        TextField("0", text: $viewModel.sellPriceText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section {
                    ForEach($viewModel.variants) { $variant in
                        VariantRowView(variant: $variant, linkableItems: viewModel.linkableItems)
                    }
                    .onDelete { viewModel.removeVariants(at: $0) }
                    Button {
                        viewModel.addVariant()
                    } label: {
                        Label(localization.strings.itemForm.addVariant, systemImage: "plus.circle")
                    }
                } header: {
                    Text(localization.strings.itemForm.variantsSection)
                } footer: {
                    Text(localization.strings.itemForm.variantsFooter)
                }

                if let error = viewModel.errorMessage {
                    Section { Text(error).foregroundStyle(.red) }
                }
            }
            .navigationTitle(viewModel.isEditing ? localization.strings.itemForm.editTitle : localization.strings.itemForm.newTitle)
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
            .onChange(of: photoPickerItem) { newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        viewModel.imageData = data
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var photo: some View {
        if let imageData = viewModel.imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondary.opacity(0.15))
                .frame(width: 120, height: 120)
                .overlay(Image(systemName: "photo").foregroundStyle(.secondary))
        }
    }
}
