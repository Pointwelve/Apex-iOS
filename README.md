# Apex iOS

[![iOS CI](https://github.com/Pointwelve/Apex-iOS/actions/workflows/ios.yml/badge.svg)](https://github.com/Pointwelve/Apex-iOS/actions/workflows/ios.yml)
[![Claude Code Review](https://github.com/Pointwelve/Apex-iOS/actions/workflows/claude-review.yml/badge.svg)](https://github.com/Pointwelve/Apex-iOS/actions/workflows/claude-review.yml)
[![Release](https://github.com/Pointwelve/Apex-iOS/actions/workflows/release.yml/badge.svg)](https://github.com/Pointwelve/Apex-iOS/actions/workflows/release.yml)

A modern iOS application built with SwiftUI and Swift 6.0, featuring automated CI/CD, AI-powered code reviews, and enterprise-grade release automation.

## 🚀 Features

- **SwiftUI Interface**: Modern declarative UI framework
- **Swift 6.0**: Latest Swift language features and improvements
- **Automated CI/CD**: GitHub Actions for building, testing, and deployment
- **AI Code Reviews**: Claude Code integration for automated code analysis
- **Code Quality**: SwiftLint integration for consistent code style
- **iOS 18.0+**: Targeting the latest iOS features
- **Release Automation**: TestFlight and App Store deployment pipelines
- **Enterprise Security**: Certificate management and code signing automation
- **Version Management**: Semantic versioning with automated build numbering

## 🛠 Tech Stack

- **Language**: Swift 6.0
- **UI Framework**: SwiftUI
- **Minimum iOS**: 18.0
- **Xcode**: 16.4+
- **Testing**: Swift Testing framework + XCTest UI tests
- **Linting**: SwiftLint
- **CI/CD**: GitHub Actions
- **Code Review**: Claude Code AI
- **Deployment**: Fastlane + App Store Connect API
- **Release**: TestFlight & App Store automation

## 📱 Requirements

- **iOS**: 18.0+
- **Xcode**: 16.4 or later
- **macOS**: 15.5+ (for development)

## 🏗 Project Structure

```
Apex/
├── Apex/                          # Main application
│   ├── ApexApp.swift             # App entry point
│   ├── ContentView.swift         # Main view
│   ├── Assets.xcassets/          # App assets
│   └── Apex.entitlements         # App capabilities
├── ApexTests/                     # Unit tests
│   └── ApexTests.swift           # Test suite
├── ApexUITests/                   # UI tests
│   ├── ApexUITests.swift         # UI test suite
│   └── ApexUITestsLaunchTests.swift
├── Apex.xcodeproj/               # Xcode project
├── .github/workflows/            # CI/CD automation
│   ├── ios.yml                  # Build and test pipeline
│   ├── claude-review.yml        # AI code reviews
│   ├── release.yml              # Release automation
│   └── setup-certificates.yml   # Certificate management
├── fastlane/                     # Release automation
│   ├── Fastfile                 # Build and deploy scripts
│   ├── Appfile                  # App Store configuration
│   └── metadata/                # App Store metadata
├── scripts/                      # Utility scripts
│   └── version-bump.sh          # Version management
├── docs/                         # Documentation
│   └── RELEASE_GUIDE.md         # Release process guide
└── .swiftlint.yml               # Code quality rules
```

## 🚀 Getting Started

### Prerequisites

1. **Xcode 16.4+** installed on macOS 15.5+
2. **SwiftLint** (optional, for development):
   ```bash
   brew install swiftlint
   ```

### Installation

1. **Clone the repository:**
   ```bash
   git clone git@github.com:Pointwelve/Apex-iOS.git
   cd Apex-iOS
   ```

2. **Open in Xcode:**
   ```bash
   open Apex/Apex.xcodeproj
   ```

3. **Build and run:**
   - Select iPhone 16 Pro simulator
   - Press `Cmd + R` to build and run

## 🔧 Development

### Building

```bash
cd Apex
xcodebuild -project Apex.xcodeproj \
  -scheme Apex \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  build
```

### Testing

```bash
# Run all tests
xcodebuild test -project Apex.xcodeproj \
  -scheme Apex \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Run unit tests only
xcodebuild test -project Apex.xcodeproj \
  -scheme Apex \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:ApexTests

# Run UI tests only
xcodebuild test -project Apex.xcodeproj \
  -scheme Apex \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:ApexUITests
```

### Linting

```bash
# Run SwiftLint
swiftlint

# Auto-fix issues where possible
swiftlint --fix

# Run with strict mode (as used in CI)
swiftlint --strict
```

### Version Management

```bash
# Bump version with automated build number and git tag
./scripts/version-bump.sh patch --auto-build --tag

# Set specific version
./scripts/version-bump.sh set 2.0.0 --auto-build --tag

# Show current version
./scripts/version-bump.sh current
```

## 🤖 CI/CD & Release Automation

### GitHub Actions Workflows

1. **iOS CI** (`.github/workflows/ios.yml`)
   - Builds project on macOS 15 with Xcode 16.4
   - Runs SwiftLint for code quality
   - Executes unit and UI tests with parallel execution
   - Advanced caching for 40% faster builds
   - Uses iPhone 16 Pro simulator

2. **Claude Code Review** (`.github/workflows/claude-review.yml`)
   - Automated AI code reviews on pull requests
   - Analyzes Swift code for best practices
   - Cost-optimized with file size limits
   - Focuses on critical security and performance issues
   - Posts detailed review comments

3. **Release Automation** (`.github/workflows/release.yml`)
   - Automated TestFlight and App Store deployment
   - Semantic versioning with automated build numbers
   - Release notes generation from git commits
   - Code signing and certificate management
   - Multiple trigger methods (push, tags, manual)

4. **Certificate Management** (`.github/workflows/setup-certificates.yml`)
   - Automated iOS certificate and provisioning profile setup
   - Development and distribution environment configuration
   - Secure keychain management with temporary credentials

### SwiftLint Configuration

The project uses comprehensive SwiftLint rules (`.swiftlint.yml`) including:
- 120 character line limit
- Opt-in rules for better code quality
- Custom rules for iOS best practices
- File header requirements

## 🔒 Security & Best Practices

- **No force unwrapping**: Custom SwiftLint rules prevent `!` usage
- **Memory safety**: Swift 6.0 strict concurrency
- **Code reviews**: AI-powered analysis of all changes
- **Secure secrets**: GitHub Actions secrets for API keys and certificates
- **Input validation**: Encouraged through linting rules
- **Certificate security**: Temporary keychains with secure cleanup
- **API key protection**: Base64 encoded keys with proper permissions
- **Release signing**: Automated code signing with enterprise practices

## 🔄 Contributing

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Commit changes**: `git commit -m 'Add amazing feature'`
4. **Push to branch**: `git push origin feature/amazing-feature`
5. **Open a Pull Request**

### Pull Request Process

- PRs automatically trigger CI builds and tests
- Claude Code will provide AI-powered code review
- SwiftLint must pass (no warnings in CI)
- All tests must pass
- Review and approval required for merge

## 📋 Code Style

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use SwiftUI best practices
- Maintain 120 character line limit
- Include documentation for public APIs
- Write meaningful commit messages

## 🐛 Troubleshooting

### Common Issues

1. **Build failures**: Ensure Xcode 16.4+ is installed
2. **SwiftLint warnings**: Run `swiftlint --fix` to auto-resolve
3. **Test failures**: Check simulator selection (iPhone 16 Pro)
4. **Claude review not working**: Verify `ANTHROPIC_API_KEY` secret

### Getting Help

- Check [docs/RELEASE_GUIDE.md](docs/RELEASE_GUIDE.md) for complete release process
- Review [CLAUDE.md](CLAUDE.md) for Claude Code development guidance
- See `.github/workflows/` for CI/CD pipeline details
- Create an issue for bugs or feature requests

### Release Process

1. **TestFlight Release**: Push to main or use GitHub Actions manual dispatch
2. **App Store Release**: Use manual workflow dispatch with `appstore` option
3. **Version Management**: Use `scripts/version-bump.sh` for local version control
4. **Emergency Releases**: Skip tests option available for critical fixes

See [docs/RELEASE_GUIDE.md](docs/RELEASE_GUIDE.md) for detailed instructions.

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [SwiftUI](https://developer.apple.com/xcode/swiftui/)
- Code quality enforced by [SwiftLint](https://github.com/realm/SwiftLint)
- AI reviews powered by [Claude Code](https://claude.ai/code)
- CI/CD with [GitHub Actions](https://github.com/features/actions)
- Release automation with [Fastlane](https://fastlane.tools/)
- App Store deployment via [App Store Connect API](https://developer.apple.com/app-store-connect/api/)

---

**Made with ❤️ by Pointwelve**