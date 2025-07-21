//
//  LocalizationExtensions.swift
//  Apex
//
//  Created by Ryne Cheow on 21/7/25.
//

import SwiftUI
import Foundation

// MARK: - String Extension for Localization
extension String {
    /// Returns localized string using LocalizationManager
    var localized: String {
        guard let key = LocalizationKey(rawValue: self) else {
            // swiftlint:disable:next nslocalizedstring_key
            return NSLocalizedString(self, comment: self)
        }
        return LocalizationManager.shared.localizedString(for: key)
    }

    /// Returns localized string with format arguments
    func localized(with arguments: CVarArg...) -> String {
        guard let key = LocalizationKey(rawValue: self) else {
            // swiftlint:disable:next nslocalizedstring_key
            return String(format: NSLocalizedString(self, comment: self), arguments: arguments)
        }
        return LocalizationManager.shared.localizedString(for: key, arguments: arguments)
    }
}

// MARK: - LocalizationKey Extension
extension LocalizationKey {
    /// Convenience property to get localized string
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }

    /// Returns localized string with format arguments
    func localized(with arguments: CVarArg...) -> String {
        return LocalizationManager.shared.localizedString(for: self, arguments: arguments)
    }
}

// MARK: - SwiftUI Text Extension
extension Text {
    /// Creates Text view with localized string from key
    init(_ key: LocalizationKey) {
        self.init(key.localized)
    }

    /// Creates Text view with localized string and format arguments
    init(_ key: LocalizationKey, arguments: CVarArg...) {
        self.init(key.localized(with: arguments))
    }
}

// MARK: - SwiftUI Environment Extension
private struct LocalizationManagerKey: EnvironmentKey {
    static let defaultValue = LocalizationManager.shared
}

extension EnvironmentValues {
    var localizationManager: LocalizationManager {
        get { self[LocalizationManagerKey.self] }
        set { self[LocalizationManagerKey.self] = newValue }
    }
}

// MARK: - View Modifier for Localization Updates
struct LocalizationUpdater: ViewModifier {
    @ObservedObject private var localizationManager = LocalizationManager.shared

    func body(content: Content) -> some View {
        content
            .environment(\.localizationManager, localizationManager)
            .onReceive(localizationManager.$currentLanguage) { _ in
                // Force view update when language changes
            }
    }
}

extension View {
    /// Applies localization updates to the view
    func withLocalization() -> some View {
        modifier(LocalizationUpdater())
    }
}

// MARK: - Language Selection View
struct LanguageSelectionView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        NavigationView {
            List(SupportedLanguage.allCases) { language in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(language.displayName)
                            .font(.headline)
                        Text(language.nativeName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    if language == localizationManager.currentLanguage {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    localizationManager.currentLanguage = language
                    dismiss()
                }
            }
            .navigationTitle(Text(.settings))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizationKey.done.localized) {
                        dismiss()
                    }
                }
            }
        }
    }
}
