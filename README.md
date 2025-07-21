# Apex iOS

[![iOS CI](https://github.com/Pointwelve/Apex-iOS/actions/workflows/ios.yml/badge.svg)](https://github.com/Pointwelve/Apex-iOS/actions/workflows/ios.yml)
[![Claude Code Review](https://github.com/Pointwelve/Apex-iOS/actions/workflows/claude-review.yml/badge.svg)](https://github.com/Pointwelve/Apex-iOS/actions/workflows/claude-review.yml)

A modern iOS application built with SwiftUI and Swift 6.0, featuring automated CI/CD and AI-powered code reviews.

## 🚀 Features

- **SwiftUI Interface**: Modern declarative UI framework
- **Swift 6.0**: Latest Swift language features and improvements
- **Automated CI/CD**: GitHub Actions for building and testing
- **AI Code Reviews**: Claude Code integration for automated code analysis
- **Code Quality**: SwiftLint integration for consistent code style
- **iOS 18.0+**: Targeting the latest iOS features

## 🛠 Tech Stack

- **Language**: Swift 6.0
- **UI Framework**: SwiftUI
- **Minimum iOS**: 18.0
- **Xcode**: 16.4+
- **Testing**: Swift Testing framework + XCTest UI tests
- **Linting**: SwiftLint
- **CI/CD**: GitHub Actions
- **Code Review**: Claude Code AI

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
└── Apex.xcodeproj/               # Xcode project
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
```

## 🤖 CI/CD & Code Quality

### GitHub Actions Workflows

1. **iOS CI** (`.github/workflows/ios.yml`)
   - Builds project on macOS 15 with Xcode 16.4
   - Runs SwiftLint for code quality
   - Executes unit and UI tests
   - Uses iPhone 16 Pro simulator

2. **Claude Code Review** (`.github/workflows/claude-review.yml`)
   - Automated AI code reviews on pull requests
   - Analyzes Swift code for best practices
   - Checks for security issues and performance
   - Posts detailed review comments

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
- **Secure secrets**: GitHub Actions secrets for API keys
- **Input validation**: Encouraged through linting rules

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

- Check [CLAUDE_REVIEW_SETUP.md](.github/CLAUDE_REVIEW_SETUP.md) for AI review setup
- Review [CLAUDE.md](CLAUDE.md) for Claude Code development guidance
- Create an issue for bugs or feature requests

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [SwiftUI](https://developer.apple.com/xcode/swiftui/)
- Code quality enforced by [SwiftLint](https://github.com/realm/SwiftLint)
- AI reviews powered by [Claude Code](https://claude.ai/code)
- CI/CD with [GitHub Actions](https://github.com/features/actions)

---

**Made with ❤️ by Pointwelve**