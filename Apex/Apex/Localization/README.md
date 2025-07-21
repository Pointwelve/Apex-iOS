# Localization Implementation

Quick reference for the Apex iOS localization system with type-safe string management.

## Core Files

- **LocalizationManager.swift** - Central coordinator with ObservableObject, UserDefaults persistence
- **LocalizationExtensions.swift** - SwiftUI helpers, Text extensions, environment integration  
- **Localizable.strings** - Base English translations with organized categories

## Usage

**Basic**:
```swift
Text(.helloWorld)                 // Type-safe enum
Text("custom_key".localized)      // String extension
```

**Reactive Updates**:
```swift
VStack {
    Text(.welcome)
}.withLocalization()              // Auto-updates on language change
```

**Language Selection**:
```swift
.sheet(isPresented: $showLanguages) {
    LanguageSelectionView()       // Pre-built UI
}
```

## Adding Languages

1. **Update enum** in `LocalizationManager.swift`
2. **Create directory**: `xx.lproj/Localizable.strings`
3. **Configure Xcode**: Project → Info → Localizations
4. **Update array**: Add to `supportedLanguages`

## Best Practices

- **Naming**: Use snake_case, group by feature
- **Organization**: MARK comments for categories
- **Context**: Meaningful comments for translators
- **Testing**: All languages in simulator/device
- **Performance**: System caching, minimal overhead

See `docs/LOCALIZATION_GUIDE.md` for complete implementation guide.