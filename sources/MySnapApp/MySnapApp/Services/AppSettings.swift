import Foundation

/// UserDefaults のキー。View の @AppStorage と AppSettings で共有する。
enum SettingsKey {
    static let saveDirectory = "saveDirectory"
    static let saveDirectoryBookmark = "saveDirectoryBookmark"
    static let imageFormat = "imageFormat"
    static let jpegQuality = "jpegQuality"
    static let fileNamePattern = "fileNamePattern"
    static let showInMenuBar = "showInMenuBar"
    static let appLanguage = "appLanguage"
}

/// 設定値の読み書き。UserDefaults を注入できるためテスト可能。
struct AppSettings {

    /// 未設定時のデフォルト値
    enum Default {
        static var saveDirectory: String { FileService.defaultSaveDirectory }
        static let imageFormat = "PNG"
        static let jpegQuality = 85.0
        static let fileNamePattern = "Screenshot_{date}_{time}"
        static let showInMenuBar = true
        static let appLanguage = "system"
    }

    static let jpegQualityRange: ClosedRange<Double> = 1...100

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var saveDirectory: String {
        get { defaults.string(forKey: SettingsKey.saveDirectory) ?? Default.saveDirectory }
        nonmutating set { defaults.set(newValue, forKey: SettingsKey.saveDirectory) }
    }

    var saveDirectoryBookmark: Data? {
        get {
            let data = defaults.data(forKey: SettingsKey.saveDirectoryBookmark)
            // 空データは「未設定」と同じ扱いにする
            return (data?.isEmpty ?? true) ? nil : data
        }
        nonmutating set { defaults.set(newValue ?? Data(), forKey: SettingsKey.saveDirectoryBookmark) }
    }

    var imageFormat: String {
        get { defaults.string(forKey: SettingsKey.imageFormat) ?? Default.imageFormat }
        nonmutating set { defaults.set(newValue, forKey: SettingsKey.imageFormat) }
    }

    /// 1...100 にクランプして返す／保存する
    var jpegQuality: Double {
        get {
            guard defaults.object(forKey: SettingsKey.jpegQuality) != nil else {
                return Default.jpegQuality
            }
            return Self.clampedJPEGQuality(defaults.double(forKey: SettingsKey.jpegQuality))
        }
        nonmutating set {
            defaults.set(Self.clampedJPEGQuality(newValue), forKey: SettingsKey.jpegQuality)
        }
    }

    var fileNamePattern: String {
        get { defaults.string(forKey: SettingsKey.fileNamePattern) ?? Default.fileNamePattern }
        nonmutating set { defaults.set(newValue, forKey: SettingsKey.fileNamePattern) }
    }

    var showInMenuBar: Bool {
        get {
            guard defaults.object(forKey: SettingsKey.showInMenuBar) != nil else {
                return Default.showInMenuBar
            }
            return defaults.bool(forKey: SettingsKey.showInMenuBar)
        }
        nonmutating set { defaults.set(newValue, forKey: SettingsKey.showInMenuBar) }
    }

    var appLanguage: String {
        get { defaults.string(forKey: SettingsKey.appLanguage) ?? Default.appLanguage }
        nonmutating set { defaults.set(newValue, forKey: SettingsKey.appLanguage) }
    }

    static func clampedJPEGQuality(_ value: Double) -> Double {
        guard value.isFinite else { return Default.jpegQuality }
        return min(max(value, jpegQualityRange.lowerBound), jpegQualityRange.upperBound)
    }
}
