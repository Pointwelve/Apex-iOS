# 🧪 Testing Strategy

This document describes the testing approach for the Apex iOS project, focusing on comprehensive quality assurance through GitHub Actions.

## 📋 Overview

The project uses standard iOS testing practices with GitHub Actions CI/CD for automated validation of all changes.

### Key Benefits
- **🔒 Quality Assurance**: All tests run for every change
- **📱 iOS Testing**: Unit and UI tests on iOS simulator
- **⚡ Efficient Execution**: Parallel test execution when possible
- **📊 Clear Results**: Comprehensive test reporting

## 🏗 Architecture

### Test Structure

1. **Unit Tests** (`ApexTests`)
   - Business logic validation
   - Model and service testing
   - Localization functionality

2. **UI Tests** (`ApexUITests`)
   - User interface validation
   - Navigation flow testing
   - Accessibility compliance

3. **CI Integration** (`.github/workflows/ios.yml`)
   - Automated test execution on all PRs
   - iPhone 16 Pro simulator target
   - SwiftLint validation

## 📝 Configuration

### Test Targets

```yaml
# Test execution in GitHub Actions
test_targets:
  - name: ApexTests
    type: unit
    coverage: Business logic, models, services
  
  - name: ApexUITests  
    type: ui
    coverage: User interface, navigation
```

### Build Configuration

```bash
# Standard iOS testing command
xcodebuild test \
  -project Apex.xcodeproj \
  -scheme Apex \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -parallel-testing-enabled YES
```

### Quality Gates

- **SwiftLint**: Zero warnings policy
- **Test Coverage**: All tests must pass
- **Build Success**: Clean compilation required

## 🚀 Usage

### Local Testing

Run tests locally before pushing:

```bash
# Build and test from Apex directory
cd Apex
xcodebuild test \
  -project Apex.xcodeproj \
  -scheme Apex \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Run SwiftLint
swiftlint
swiftlint --fix  # Auto-fix issues
```

### CI/CD Integration

Tests run automatically on:
- **Pull Requests**: All tests execute for code validation
- **Main Branch**: Full test suite on every merge
- **Release**: Comprehensive testing before deployment

## 🎯 Testing Approach

### Test Execution Strategy

| Change Type | Test Strategy | Rationale |
|------------|---------------|----------|
| Swift Code | Full test suite | Ensure comprehensive validation |
| Documentation | Tests still run | Maintain consistency |
| Configuration | Full test suite | Changes may affect functionality |
| Dependencies | Full test suite | Verify compatibility |

### Testing Philosophy

- **Safety First**: Always run complete test suite
- **Quality Assurance**: Zero tolerance for test failures
- **Comprehensive Coverage**: Both unit and UI tests
- **Fast Feedback**: Parallel execution for efficiency

## 📊 Performance

### Typical Test Times

| Test Type | Duration | Optimization |
|-----------|----------|-------------|
| Unit Tests | 1-2 minutes | Parallel execution |
| UI Tests | 2-4 minutes | Simulator caching |
| SwiftLint | 10-20 seconds | Homebrew caching |
| Total Workflow | 3-6 minutes | Build caching |

### Optimization Features

- **Build Caching**: Faster subsequent runs
- **Parallel Testing**: Utilize multiple cores
- **Simulator Optimization**: Consistent iPhone 16 Pro target

## 🔧 Customization

### Adding New Tests

To add new test targets:

1. Create test target in Xcode
2. Update `.github/workflows/ios.yml` if needed
3. Add to CLAUDE.md build commands
4. Test locally first

Example workflow modification:
```yaml
- name: Run Tests
  run: |
    xcodebuild test \
      -project Apex.xcodeproj \
      -scheme Apex \
      -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
      -only-testing:ApexTests \
      -only-testing:ApexUITests \
      -only-testing:YourNewTests
```

### Adjusting Test Configuration

- **Simulator Target**: Change in workflow if needed
- **Parallel Testing**: Already enabled for performance
- **Test Timeout**: Adjust in Xcode scheme settings

## 🔍 Troubleshooting

### Common Issues

**Issue**: Tests failing locally but not in CI
```bash
# Ensure clean environment
cd Apex
rm -rf ~/Library/Developer/Xcode/DerivedData
xcodebuild clean

# Run with same settings as CI
xcodebuild test \
  -project Apex.xcodeproj \
  -scheme Apex \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

**Issue**: SwiftLint violations
```bash
# Check for issues
swiftlint

# Auto-fix what's possible
swiftlint --fix

# Run in strict mode (like CI)
swiftlint --strict
```

**Issue**: Test timeouts
- Check for infinite loops or blocking code
- Verify simulator state
- Review test logic for performance issues

## 🔒 Quality Assurance

### Quality Gates

Every change must pass:

1. **SwiftLint**: Zero warnings in strict mode
2. **Unit Tests**: All ApexTests must pass
3. **UI Tests**: All ApexUITests must pass
4. **Build**: Clean compilation required

### CI/CD Safety

- **Consistent Environment**: Same simulator/Xcode version
- **Clean Builds**: Fresh environment for each run
- **Comprehensive Testing**: No test skipping
- **Branch Protection**: Prevent merging with failing tests

## 📈 Monitoring

### Key Metrics

Track test performance:

- **Test execution time**
- **Test success/failure rates**  
- **Build performance**
- **SwiftLint compliance**

### GitHub Actions Insights

View test results in:
- **Workflow runs**: See detailed execution logs
- **Pull request checks**: Test status on PRs
- **Actions insights**: Historical performance data

## 🚧 Current Scope

### Project Coverage

1. **iOS Testing**: Comprehensive unit and UI tests
2. **SwiftUI Focus**: Optimized for SwiftUI applications
3. **Standard Testing**: Using Swift Testing and XCTest frameworks
4. **CI/CD Integration**: GitHub Actions automation

### Future Enhancements

- **Test Coverage Reports**: Detailed coverage analysis
- **Performance Testing**: Load and performance validation
- **Accessibility Testing**: Enhanced accessibility validation
- **Cross-Platform**: If expanding beyond iOS

## 📚 Examples

### Common Test Scenarios

**Scenario 1**: Documentation Update
```
Changed files: README.md, docs/setup.md
Result: RUN_ALL_TESTS (ensuring no config changes)
Time: 3-6 minutes
```

**Scenario 2**: UI Component Change
```
Changed files: ContentView.swift
Result: RUN_ALL_TESTS (unit + UI tests)
Time: 3-6 minutes
```

**Scenario 3**: Localization Update
```
Changed files: LocalizationManager.swift, Localizable.strings
Result: RUN_ALL_TESTS (comprehensive validation)
Time: 3-6 minutes
```

**Scenario 4**: Major Refactoring
```
Changed files: Multiple Swift files
Result: RUN_ALL_TESTS (full validation required)
Time: 3-6 minutes
```

## 🤝 Contributing

### Adding New Tests

1. Create tests in appropriate target (ApexTests/ApexUITests)
2. Follow existing patterns and conventions
3. Run locally before committing
4. Ensure all quality gates pass

### Best Practices

- **Comprehensive Testing**: Test all code paths
- **Clear Test Names**: Descriptive test function names
- **Fast Execution**: Keep tests efficient
- **Regular Maintenance**: Update tests as code evolves
- **Quality First**: Never commit failing tests

---

This testing strategy ensures high code quality through comprehensive validation while maintaining efficient CI/CD workflows.