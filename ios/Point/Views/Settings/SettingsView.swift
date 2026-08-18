import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var localization: LocalizationManager

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
