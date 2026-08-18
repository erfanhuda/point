import Foundation

enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case english = "en"
    case indonesian = "id"

    var id: String { rawValue }

    /// The name of the JSON resource file (without extension) holding this
    /// language's strings — see `Resources/Localization/`.
    var resourceName: String { rawValue }

    /// Each language's own name for itself, always shown in its own script
    /// regardless of the app's current language — the same convention iOS's
    /// own language picker uses. Not sourced from `LocalizedStrings` since
    /// it isn't really "translated" content.
    var nativeName: String {
        switch self {
        case .english: return "English"
        case .indonesian: return "Bahasa Indonesia"
        }
    }
}
