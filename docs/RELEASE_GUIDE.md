# 🚀 Release Guide for Apex iOS

This guide covers all aspects of releasing Apex iOS to TestFlight and the App Store using our automated CI/CD pipeline.

## 📋 Prerequisites

### Required Secrets
Ensure these secrets are configured in your GitHub repository:

```
APPLE_TEAM_ID                    # Apple Developer Team ID
APPLE_ID_EMAIL                   # Apple ID email address
APPLE_APPLICATION_PASSWORD       # App-specific password
APP_STORE_CONNECT_API_KEY        # Base64 encoded P8 key
APP_STORE_CONNECT_KEY_ID         # API Key ID
APP_STORE_CONNECT_ISSUER_ID      # API Issuer ID
```

### Development Setup
1. Xcode 16.4+ installed
2. iOS Simulator with iOS 18.0+
3. Valid Apple Developer account
4. App Store Connect access

## 🎯 Release Types

### Main/Develop Branch Strategy
**Build and Test Only - No Deployment**

Pushing to main or develop branches will:
```bash
git checkout main
git pull origin main
# Make your changes
git commit -m "feat: new feature implementation" 
git push origin main  # Only builds and tests - NO deployment
```

This triggers the "iOS Build & Test" workflow which:
- Runs smart test optimization
- Builds the project
- Validates code quality
- **Does not deploy anywhere**

### 1. TestFlight Release (Manual Only)
Best for beta testing and gradual rollouts.

**Manual (GitHub Actions):**
1. Go to GitHub Actions
2. Select "Release to TestFlight & App Store"
3. Click "Run workflow"
4. Select:
   - Release type: `testflight`
   - Version bump: `patch/minor/major` 
   - Skip tests: `false` (recommended)

### 2. App Store Release
For production releases to the App Store.

**Manual (GitHub Actions):**
1. Go to GitHub Actions
2. Select "Release to TestFlight & App Store"
3. Click "Run workflow"
4. Select:
   - Release type: `appstore`
   - Version bump: `minor/major`
   - Skip tests: `false`

### 3. Tag-based Release
For specific version releases.

```bash
git tag -a v1.2.0 -m "Release version 1.2.0"
git push origin v1.2.0
```

## 🔧 Version Management

### Automated Versioning
Release pipeline automatically increments versions based on:
- **Manual dispatch**: Your choice (patch/minor/major)
- **Git tags**: Uses tag version (v1.2.0 → 1.2.0)

**Note**: Push to main/develop no longer triggers automatic releases - only build and test.

### Manual Versioning
Use the provided script for local version management:

```bash
# Increment patch version
./scripts/version-bump.sh patch --auto-build --tag

# Increment minor version  
./scripts/version-bump.sh minor --auto-build --tag

# Set specific version
./scripts/version-bump.sh set 2.0.0 --auto-build --tag

# Show current version
./scripts/version-bump.sh current
```

### Build Numbers
Build numbers are automatically generated using timestamp format: `YYYYMMDDHHMM`
- Example: `202507211430` (July 21, 2025, 2:30 PM)

## 📝 Release Notes

Release notes are automatically generated from git commits since the last release tag. For better release notes, use conventional commit messages:

```bash
# Good commit messages
git commit -m "feat: add dark mode support"
git commit -m "fix: resolve crash on iOS 18.0"
git commit -m "perf: improve app startup time"

# These will appear in release notes automatically
```

### Manual Release Notes
Edit `fastlane/metadata/en-US/release_notes.txt` for custom release notes.

## 🏗️ Build Process

### What Happens During Release

1. **Version Check**: Determines if release is needed
2. **Build & Test**: 
   - SwiftLint validation
   - Unit and UI tests
   - Archive creation
3. **Code Signing**: Automatic certificate and profile setup
4. **Distribution**: Upload to TestFlight or App Store
5. **Tagging**: Git tag creation (if version changed)
6. **Notifications**: GitHub release creation

### Build Artifacts
After successful builds, these artifacts are available:
- `apex-archive-{version}`: Xcode archive
- `apex-ipa-{version}`: Signed IPA file
- `certificate-backup-{env}`: Certificate backups

## 📱 TestFlight Management

### After Upload
1. **Processing**: 10-15 minutes for Apple processing
2. **Internal Testing**: Automatically available to team
3. **External Testing**: Manually add groups in App Store Connect

### TestFlight Best Practices
- Test with internal testers first
- Add external groups gradually
- Include clear test instructions
- Monitor crash reports and feedback

## 🏪 App Store Submission

### Review Process
1. **Upload**: Automatic via pipeline
2. **Processing**: 1-2 hours for processing
3. **Review**: 24-48 hours typical review time
4. **Release**: Manual or automatic after approval

### Submission Checklist
- [ ] App tested on multiple devices
- [ ] All required metadata completed
- [ ] Screenshots up to date
- [ ] Privacy policy accessible
- [ ] Support URL working
- [ ] No placeholder content

## 🔐 Code Signing & Certificates

### Certificate Setup
Use the provided workflow to set up certificates:

```bash
# GitHub Actions → Setup iOS Certificates
# Select environment: development/distribution/all
```

### Certificate Management
- **Development**: For testing and debugging
- **Distribution**: For App Store and TestFlight
- **Automatic renewal**: Handled by fastlane

### Troubleshooting Signing Issues
1. Run certificate setup workflow
2. Check Apple Developer Portal for expired certificates
3. Verify team ID and bundle identifier
4. Clean and rebuild if issues persist

## 🛠️ Fastlane Commands

### Local Development
```bash
# Install fastlane
gem install fastlane

# Setup development environment
bundle exec fastlane ios setup_dev

# Setup distribution environment
bundle exec fastlane ios setup_dist

# Build and test
bundle exec fastlane ios build_and_test

# Release to TestFlight
bundle exec fastlane ios upload_testflight version:1.2.0

# Deploy to App Store
bundle exec fastlane ios deploy_appstore version:1.2.0 submit:true
```

### Emergency Releases
For critical fixes that need immediate deployment:

```bash
# Skip tests (use cautiously)
bundle exec fastlane ios emergency_release type:testflight version:1.0.1
```

## 📊 Monitoring & Analytics

### Build Status
- GitHub Actions: Monitor pipeline status
- App Store Connect: Track processing status
- TestFlight: Monitor crash reports

### Release Metrics
Track these key metrics:
- Build success rate
- Time to release
- Crash-free sessions
- User adoption rate

## 🚨 Troubleshooting

### Common Issues

**Build Failures:**
```bash
# Clean build artifacts
rm -rf ~/Library/Developer/Xcode/DerivedData
cd Apex && xcodebuild clean

# Fix SwiftLint issues
swiftlint --fix
```

**Certificate Issues:**
```bash
# Re-run certificate setup
# GitHub Actions → Setup iOS Certificates → Force refresh: true
```

**Upload Failures:**
- Check App Store Connect API key validity
- Verify team ID and bundle identifier
- Ensure unique version/build numbers

**Version Conflicts:**
- Check existing versions in App Store Connect
- Increment build number manually if needed
- Use semantic versioning properly

### Getting Help
1. Check GitHub Actions logs
2. Review fastlane output
3. Consult App Store Connect dashboard
4. Apple Developer documentation
5. Fastlane documentation

## 📚 Additional Resources

### Documentation
- [Apple App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [TestFlight Documentation](https://developer.apple.com/testflight/)
- [Fastlane Documentation](https://docs.fastlane.tools/)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect/)

### Best Practices
- Always test releases on physical devices
- Use semantic versioning (major.minor.patch)
- Include meaningful release notes
- Monitor crash reports and user feedback
- Keep certificates and profiles updated
- Regular security audits of dependencies

## 🎉 Release Checklist

### Before Release
- [ ] All tests passing
- [ ] SwiftLint issues resolved
- [ ] Version number appropriate
- [ ] Release notes prepared
- [ ] Certificates valid
- [ ] Team notified of pending release

### During Release
- [ ] Monitor build progress
- [ ] Verify upload success
- [ ] Check processing status
- [ ] Test downloaded build

### After Release
- [ ] Verify availability in TestFlight/App Store
- [ ] Monitor crash reports
- [ ] Collect user feedback
- [ ] Plan next release
- [ ] Update documentation if needed

---

**Need help?** Check the troubleshooting section or reach out to the development team.