import Foundation

/// Loads `LocalizedStrings` from the bundled `<lang>.json` resource for the
/// current `AppLanguage`, persists the user's choice, and publishes both so
/// SwiftUI views re-render on a language change. Default is `.english`.
///
/// A single `shared` instance is used everywhere — both by Views (as an
/// `@EnvironmentObject`, for reactivity) and by ViewModels (as a plain
/// `LocalizationManager.shared.strings` read, for validation-message text)
/// — rather than threading it through every initializer, since app language
/// is genuinely global state.
@MainActor
final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @Published private(set) var language: AppLanguage
    @Published private(set) var strings: LocalizedStrings

    private static let defaultsKey = "com.vesk.point.selectedLanguage"

    private init() {
        let saved = UserDefaults.standard.string(forKey: Self.defaultsKey)
        let resolved = saved.flatMap(AppLanguage.init(rawValue:)) ?? .english
        language = resolved
        strings = Self.load(resolved)
    }

    func setLanguage(_ language: AppLanguage) {
        guard language != self.language else { return }
        self.language = language
        strings = Self.load(language)
        UserDefaults.standard.set(language.rawValue, forKey: Self.defaultsKey)
    }

    func displayName(for type: StockMovementType) -> String {
        switch type {
        case .stockIn: return strings.stock.stockInName
        case .stockOut: return strings.stock.stockOutName
        case .correction: return strings.stock.correctionName
        case .opname: return strings.stock.opnameName
        }
    }

    private static func load(_ language: AppLanguage) -> LocalizedStrings {
        guard
            let url = Bundle.main.url(forResource: language.resourceName, withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode(LocalizedStrings.self, from: data)
        else {
            fatalError("Missing or invalid localization resource '\(language.resourceName).json'")
        }
        return decoded
    }
}
