import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var localization: LocalizationManager
    @ObservedObject private var printerManager = PrinterManager.shared

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(localization.strings.settings.languageSection, selection: languageBinding) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.nativeName).tag(language)
                        }
                    }
                    .pickerStyle(.inline)
                } header: {
                    Text(localization.strings.settings.languageSection)
                } footer: {
                    Text(localization.strings.settings.languageFooter)
                }

                Section {
                    if let name = printerManager.boundPrinterName {
                        LabeledContent(localization.strings.settings.printerSection, value: name)
                    } else {
                        LabeledContent(
                            localization.strings.settings.printerSection,
                            value: localization.strings.settings.printerNotConfigured
                        )
                    }
                    Button(localization.strings.settings.selectPrinterAction) {
                        printerManager.presentPicker()
                    }
                    if printerManager.isConfigured {
                        Button(localization.strings.settings.removePrinterAction, role: .destructive) {
                            printerManager.clearBoundPrinter()
                        }
                    }
                } header: {
                    Text(localization.strings.settings.printerSection)
                } footer: {
                    Text(localization.strings.settings.printerFooter)
                }
            }
            .navigationTitle(localization.strings.settings.navigationTitle)
        }
    }

    private var languageBinding: Binding<AppLanguage> {
        Binding(
            get: { localization.language },
            set: { localization.setLanguage($0) }
        )
    }
}
