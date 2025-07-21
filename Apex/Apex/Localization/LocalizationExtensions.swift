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
    @MainActor var localized: String {
        guard let key = LocalizationKey(rawValue: self) else {
            // swiftlint:disable:next nslocalizedstring_key
            return NSLocalizedString(self, comment: self)
        }
        return LocalizationManager.shared.localizedString(for: key)
    }

    /// Returns localized string with format arguments
    @MainActor
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
    @MainActor var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }

    /// Returns localized string with format arguments
    @MainActor
    func localized(with arguments: CVarArg...) -> String {
        return LocalizationManager.shared.localizedString(for: self, arguments: arguments)
    }
}

// MARK: - SwiftUI Text Extension
extension Text {
    /// Creates Text view with localized string from key
    @MainActor
    init(_ key: LocalizationKey) {
        self.init(key.localized)
    }

    /// Creates Text view with localized string and format arguments
    @MainActor
    init(_ key: LocalizationKey, arguments: CVarArg...) {
        self.init(key.localized(with: arguments))
    }
}

// MARK: - SwiftUI Environment Extension
private struct LocalizationManagerKey: EnvironmentKey {
    typealias Value = LocalizationManager

    static var defaultValue: LocalizationManager {
        MainActor.assumeIsolated {
            LocalizationManager.shared
        }
    }
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
    @StateObject private var localizationManager = LocalizationManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                ForEach(SupportedLanguage.allCases) { language in
                    LanguageRow(
                        language: language,
                        isSelected: language == localizationManager.currentLanguage
                    ) {
                        selectLanguage(language)
                    }
                }
            }
            .listStyle(.insetGrouped)
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
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func selectLanguage(_ language: SupportedLanguage) {
        guard language != localizationManager.currentLanguage else { return }

        localizationManager.currentLanguage = language

        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()

        // Dismiss after a slight delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            dismiss()
        }
    }
}

// MARK: - Language Row Component
private struct LanguageRow: View {
    let language: SupportedLanguage
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(language.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(language.nativeName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                        .imageScale(.large)
                        .accessibilityLabel("Selected")
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(language.displayName) language option")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
