# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Structure

This is an iOS SwiftUI application called **Apex** created with Xcode 16.4. The project uses a standard iOS app structure:

- **Main App**: `Apex/Apex/ApexApp.swift` - SwiftUI App entry point
- **UI**: `Apex/Apex/ContentView.swift` - Main view with basic SwiftUI "Hello, world!" interface
- **Tests**: 
  - `Apex/ApexTests/ApexTests.swift` - Unit tests using Swift Testing framework
  - `Apex/ApexUITests/ApexUITests.swift` - UI tests using XCTest framework
  - `Apex/ApexUITests/ApexUITestsLaunchTests.swift` - UI launch tests
- **Assets**: `Apex/Apex/Assets.xcassets/` - App icons and color assets
- **Entitlements**: `Apex/Apex/Apex.entitlements` - App capabilities and permissions
- **Configuration**: `.swiftlint.yml` - SwiftLint rules and configuration

## Build Commands

### Build the Project
```bash
# Build from project directory
cd Apex
xcodebuild -project Apex.xcodeproj -scheme Apex -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
```

### Run Tests
```bash
# Run unit tests
cd Apex
xcodebuild test -project Apex.xcodeproj -scheme Apex -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:ApexTests

# Run UI tests
xcodebuild test -project Apex.xcodeproj -scheme Apex -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:ApexUITests

# Run all tests
xcodebuild test -project Apex.xcodeproj -scheme Apex -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

### Linting Commands
```bash
# Run SwiftLint
swiftlint

# Auto-fix issues where possible
swiftlint --fix

# Run with strict mode (treats warnings as errors)
swiftlint --strict
```

### Platform Support
The project supports iOS only:
- iOS (iPhone/iPad) - deployment target: 18.0

## Development Environment

- **Xcode Version**: 16.4+
- **Swift Version**: 6.0
- **iOS Deployment Target**: 18.0
- **Bundle Identifier**: com.pointwelve.Apex

## Code Quality & Standards

### SwiftLint Configuration
The project uses comprehensive SwiftLint rules (`.swiftlint.yml`) with:
- 120 character line limit
- Opt-in rules for better code quality
- Custom rules preventing `print()`, force casting, and `@objcMembers`
- File header requirements
- Analyzer rules for unused imports/declarations

### Build Integration
- SwiftLint runs as a build phase before compilation
- Violations appear as Xcode warnings/errors
- CI/CD fails on SwiftLint warnings

## Testing Framework

- **Unit Tests**: Uses Swift Testing framework (`import Testing`) with `@Test` annotations
- **UI Tests**: Uses XCTest framework (`import XCTest`) with traditional test classes

## CI/CD & Automation

### GitHub Actions Workflows

1. **iOS CI** (`.github/workflows/ios.yml`)
   - Runs on macOS 15 with Xcode 16.4
   - Installs and runs SwiftLint with `--strict` mode
   - Builds and tests on iPhone 16 Pro simulator
   - Uploads test results as artifacts

2. **Claude Code Review** (`.github/workflows/claude-review.yml`)
   - Automated AI code reviews on pull requests
   - Analyzes Swift files, headers, and configuration
   - Posts comprehensive review comments
   - Focuses on iOS/SwiftUI best practices and security

### Required Secrets
- `ANTHROPIC_API_KEY` - For Claude Code reviews

## Architecture Notes

This is a SwiftUI application with:
- Single window group architecture
- Standard iOS app lifecycle management
- SwiftUI Previews enabled for development
- iOS-only platform support
- Swift 6.0 strict concurrency model

## Development Best Practices

### Swift 6.0 Features
- Use strict concurrency checking
- Leverage new language features and improvements
- Follow sendable protocol guidelines

### iOS Development
- Follow SwiftUI best practices
- Use proper view composition
- Implement accessibility features
- Handle different screen sizes and orientations

### Code Style
- Follow Swift API Design Guidelines
- Use meaningful variable and function names
- Include documentation for public APIs
- Maintain consistent formatting via SwiftLint

## Security Considerations

- No hardcoded secrets or API keys
- Proper input validation
- Avoid force unwrapping (enforced by SwiftLint)
- Follow iOS security best practices

## Important Development Rules

### ⚠️ Pre-Commit Checklist

**ALWAYS run SwiftLint and fix all issues before committing:**

```bash
# Check for lint issues
swiftlint

# Auto-fix issues where possible
swiftlint --fix

# Verify all issues are resolved
swiftlint --strict
```

**Requirements before any commit:**
- SwiftLint must pass with zero warnings
- All tests must pass
- Build must succeed without warnings
- File headers must be properly formatted

**Why this matters:**
- CI/CD will fail on SwiftLint warnings (`--strict` mode)
- Maintains consistent code quality across the project
- Prevents merge conflicts from formatting differences
- Ensures professional code standards

**Quick fix workflow:**
1. Run `swiftlint --fix` to auto-resolve formatting issues
2. Manually fix remaining warnings shown by `swiftlint`
3. Verify with `swiftlint --strict` (should show no output)
4. Only then commit your changes