# Localization Guide

Complete reference for the Apex iOS app localization system featuring type-safe string management and multi-language support.

## Quick Reference

**Supported Languages**: English (base), Spanish, French, German, Japanese

**Usage**:
```swift
Text(.helloWorld)                    // Type-safe
"custom_key".localized               // String extension  
Text(.welcome).withLocalization()    // Reactive updates
```

**Files**:
- `LocalizationManager.swift` - Central coordinator
- `LocalizationExtensions.swift` - SwiftUI helpers
- `Localizable.strings` - Base translations

## Architecture

**LocalizationManager**: Singleton coordinator with ObservableObject pattern, UserDefaults persistence, and dynamic bundle switching.

**LocalizationKey Enum**: Type-safe string keys with compile-time validation:
```swift
enum LocalizationKey: String, CaseIterable {
    case helloWorld = "hello_world"
    case appName = "app_name"
}
```

**SwiftUI Extensions**: Direct Text initialization, string extensions, and reactive environment integration.

**Language Selection**: Pre-built view with native names and immediate switching.

## Usage Examples

**Basic Text**:
```swift
VStack {
    Text(.welcome)                    // Type-safe enum
    Text("hello_world".localized)     // String extension
}.withLocalization()                  // Reactive updates
```

**Formatted Strings**:
```swift
// Localizable.strings: "welcome_user" = "Welcome, %@!";
Text(LocalizationKey.welcomeUser.localized(with: userName))
```

**Language Selection**:
```swift
.sheet(isPresented: $showLanguages) {
    LanguageSelectionView()  // Pre-built UI
}
```

## Adding Languages

**1. Update Enum** in `LocalizationManager.swift`:
```swift
enum SupportedLanguage: String, CaseIterable {
    case portuguese = "pt"  // Add new language
    
    var displayName: String {
        case .portuguese: return "Portuguese"
    }
    
    var nativeName: String {
        case .portuguese: return "Português"  
    }
}
```

**2. Update Array**:
```swift
let supportedLanguages: [SupportedLanguage] = [.english, .spanish, .portuguese]
```

**3. Create Directory**: In Xcode → Project → Info → Localizations → "+" → Select language

**4. Translate**: Copy base `Localizable.strings` to `pt.lproj/Localizable.strings` and translate:
```strings
"hello_world" = "Olá, mundo!";
"welcome" = "Bem-vindo";
```

**5. Test**: Build, switch language, verify display.

## Common Patterns

**Views**:
```swift
VStack {
    Text(.productName).font(.headline)
    Button(.addToCart) { /* action */ }
}.withLocalization()  // Enable reactive updates
```

**Alerts**:
```swift
.alert(LocalizationKey.errorTitle.localized, isPresented: $showAlert) {
    Button(.ok) { }
} message: { Text(.errorGeneric) }
```

**Navigation**:
```swift
TabView {
    HomeView().tabItem { Text(.home) }
}.withLocalization()
```

**Dynamic Content**:
```swift
Text(LocalizationKey.welcomeUser.localized(with: userName))
```

## Testing

**Simulator**:
```bash
# Test Spanish
xcrun simctl spawn "iPhone 16 Pro" defaults write com.apple.Simulator AppleLanguages -array es
```

**In-App**: Use `LanguageSelectionView`, test UI overflow, verify text alignment.

**Validation**:
```bash
# Check syntax
plutil -lint Apex/Apex/*/Localizable.strings

# Find missing keys
diff <(grep -o '^"[^"]*"' Apex/Apex/en.lproj/Localizable.strings | sort) \
     <(grep -o '^"[^"]*"' Apex/Apex/es.lproj/Localizable.strings | sort)
```

**Automated Tests**:
```swift
func testAllKeysHaveTranslations() {
    for language in SupportedLanguage.allCases {
        LocalizationManager.shared.currentLanguage = language
        for key in LocalizationKey.allCases {
            XCTAssertFalse(LocalizationManager.shared.localizedString(for: key).isEmpty)
        }
    }
}
```

## Best Practices

**Key Naming**: Use snake_case, group by feature (`login_title`, `login_button`), be descriptive.

**Organization**: Use MARK comments to group related strings:
```strings
// MARK: - Authentication
"login_title" = "Sign In";
"login_email_placeholder" = "Email address";
```

**Context Comments**:
```strings
/* Navigation title for user settings screen */
"settings_title" = "Settings";
```

**Text Expansion**: Design UI for 30% longer text (German), test with longest translations.

**Pluralization**: Use `.stringsdict` for complex plural rules:
```xml
<key>items_count</key>
<dict>
    <key>NSStringLocalizedFormatKey</key>
    <string>%#@count@</string>
    <key>count</key>
    <dict>
        <key>zero</key><string>No items</string>
        <key>one</key><string>One item</string>
        <key>other</key><string>%d items</string>
    </dict>
</dict>
```

## Troubleshooting

**UI Not Updating**: Add `.withLocalization()` modifier to views.

**Showing Key Names**: Verify strings file in target, check syntax, ensure LocalizationKey enum has key.

**Language Not Persisting**: Verify LocalizationManager saves to UserDefaults in `didSet`.

**Xcode Not Recognizing Languages**: Clean build (Cmd+Shift+K), re-add in Project → Info → Localizations.

**Debug Commands**:
```bash
# Check simulator language
xcrun simctl spawn "iPhone 16 Pro" defaults read -g AppleLanguages

# List localizations
ls Apex/Apex/*.lproj/

# Check for duplicates
sort Apex/Apex/en.lproj/Localizable.strings | uniq -d
```

## Advanced Features

**RTL Support**: Extend `SupportedLanguage` with `isRTL` property, use `.environment(\.layoutDirection)`.

**Number/Date Formatting**: Add `locale` and `currencyCode` properties to `SupportedLanguage`:
```swift
extension SupportedLanguage {
    var locale: Locale { Locale(identifier: rawValue) }
    var currencyCode: String {
        switch self {
        case .english: return "USD"
        case .spanish: return "EUR"
        default: return "USD"
        }
    }
}
```

**Context-Sensitive**: Create `LocalizationContext` enum for button/title/message variations.

**Dynamic Loading**: Use separate manager for server-fetched translations:
```swift
@MainActor class DynamicLocalizationManager: ObservableObject {
    @Published var dynamicStrings: [String: String] = [:]
    func loadRemoteStrings() async { /* fetch from API */ }
}
```

---

**Key Files**: `LocalizationManager.swift`, `LocalizationExtensions.swift`, `Localizable.strings`