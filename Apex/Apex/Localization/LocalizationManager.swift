//
//  LocalizationManager.swift
//  Apex
//
//  Created by Ryne Cheow on 21/7/25.
//

import SwiftUI
import Foundation

/// Central manager for app localization
@MainActor
final class LocalizationManager: ObservableObject {
    /// Singleton instance
    static let shared = LocalizationManager()

    /// Current app language
    @Published var currentLanguage: SupportedLanguage = .english {
        didSet {
            UserDefaults.standard.set(currentLanguage.code, forKey: "app_language")
            updateBundle()
            clearCache()
        }
    }

    /// Available languages in the app
    let supportedLanguages: [SupportedLanguage] = [.english, .spanish, .french, .german, .japanese]

    private var bundle: Bundle = .main
    private var stringCache: [String: String] = [:]
    private let cacheQueue = DispatchQueue(label: "localization.cache", qos: .userInitiated)

    private init() {
        setupInitialLanguage()
        updateBundle()
    }

    /// Get localized string for given key with caching
    func localizedString(for key: LocalizationKey, comment: String = "") -> String {
        let keyString = key.rawValue
        let cacheKey = "\(currentLanguage.code)_\(keyString)"

        // Check cache first
        if let cachedString = stringCache[cacheKey] {
            return cachedString
        }

        // Load and cache the string
        let commentString = comment.isEmpty ? keyString : comment
        // swiftlint:disable:next nslocalizedstring_key
        let localizedString = NSLocalizedString(keyString, bundle: bundle, comment: commentString)

        // Cache the result
        stringCache[cacheKey] = localizedString

        return localizedString
    }

    /// Get localized string with format arguments
    func localizedString(for key: LocalizationKey, arguments: CVarArg...) -> String {
        let format = localizedString(for: key)
        return String(format: format, arguments: arguments)
    }

    /// Preload commonly used strings for better performance
    func preloadCommonStrings() {
        let commonKeys: [LocalizationKey] = [
            .helloWorld, .welcome, .appName, .appTagline, .settings,
            .home, .profile, .loading, .okay, .cancel, .done
        ]

        for key in commonKeys {
            _ = localizedString(for: key)
        }
    }

    private func setupInitialLanguage() {
        if let savedLanguage = UserDefaults.standard.string(forKey: "app_language"),
           let language = SupportedLanguage(rawValue: savedLanguage) {
            currentLanguage = language
        } else {
            // Use system language if supported, otherwise default to English
            let systemLanguage = Locale.current.language.languageCode?.identifier ?? "en"
            currentLanguage = SupportedLanguage(rawValue: systemLanguage) ?? .english
        }
    }

    private func updateBundle() {
        if let path = Bundle.main.path(forResource: currentLanguage.code, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            self.bundle = bundle
        } else {
            self.bundle = .main
        }

        // Preload common strings after bundle update
        preloadCommonStrings()
    }

    private func clearCache() {
        stringCache.removeAll()
    }
}

// MARK: - Supported Languages
enum SupportedLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case japanese = "ja"

    var id: String { rawValue }

    var code: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .japanese: return "日本語"
        }
    }

    var nativeName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .japanese: return "日本語"
        }
    }
}

// MARK: - Localization Keys
enum LocalizationKey: String, CaseIterable {
    // MARK: - General
    case helloWorld = "hello_world"
    case welcome = "welcome"
    case continueAction = "continue"
    case cancel = "cancel"
    case okay = "ok"
    case done = "done"
    case save = "save"
    case delete = "delete"
    case edit = "edit"
    case back = "back"
    case next = "next"

    // MARK: - App Specific
    case appName = "app_name"
    case appTagline = "app_tagline"

    // MARK: - Navigation
    case home = "home"
    case settings = "settings"
    case profile = "profile"

    // MARK: - Error Messages
    case errorTitle = "error_title"
    case errorGeneric = "error_generic"
    case errorNetwork = "error_network"

    // MARK: - Loading States
    case loading = "loading"
    case pleaseWait = "please_wait"

    // MARK: - Confirmation Messages
    case areYouSure = "are_you_sure"
    case cannotBeUndone = "cannot_be_undone"
}
