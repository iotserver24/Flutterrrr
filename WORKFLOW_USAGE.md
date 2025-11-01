# Multi-Platform GitHub Actions Workflow Usage Guide

## Overview

The comprehensive GitHub Actions workflow builds and releases Xibe Chat for **all major platforms** including Android, iOS, Windows, macOS, and Linux with support for multiple architectures.

## How to Run the Workflow

### 1. Navigate to GitHub Actions

1. Go to your repository: https://github.com/iotserver24/Flutterrrr
2. Click on the "Actions" tab
3. Select "Build and Release" workflow from the left sidebar
4. Click "Run workflow" button (top right)

### 2. Provide Required Inputs

When you click "Run workflow", you'll be prompted to enter:

- **Version number**: Semantic version (e.g., `1.0.0`, `2.1.3`)
- **Build number**: Integer build number (e.g., `1`, `2`, `100`)

Example:
- Version: `1.0.0`
- Build number: `1`
- This will create a release tagged as `v1.0.0-1`

### 3. Workflow Execution

The workflow builds all platforms in parallel using matrix strategies for optimal speed:

1. **Android Builds** (Ubuntu runner)
   - Universal APK for all architectures
   - App Bundle (AAB) for Play Store

2. **Windows Builds** (Windows runner, x64)
   - Portable ZIP with EXE
   - MSIX installer package

3. **macOS Builds** (macOS runner, x64 + arm64)
   - DMG installers for Intel and Apple Silicon
   - ZIP archives for both architectures

4. **Linux Builds** (Ubuntu runner, x64)
   - DEB package for Debian/Ubuntu
   - AppImage for universal compatibility
   - TAR.GZ portable archive

5. **iOS Builds** (macOS runner)
   - Unsigned IPA (requires signing)

6. **Create GitHub Release**
   - Creates git tag: `v{version}-{build_number}`
   - Uploads all artifacts to release
   - Cleans up temporary build artifacts

## What Gets Built

### 📱 Android
- **APK**: Universal APK for all architectures (ARM, ARM64, x86, x64)
  - `xibe-chat-v{version}-{build_number}.apk`
- **AAB**: App Bundle for Google Play Store distribution
  - `xibe-chat-v{version}-{build_number}.aab`

### 💻 Windows (x64)
- **MSIX**: Modern Windows Store-style installer
  - `xibe-chat-windows-x64-v{version}-{build_number}.msix`
  - Self-signed certificate (may need user trust)
- **ZIP**: Portable version with EXE
  - `xibe-chat-windows-x64-v{version}-{build_number}.zip`
  - No installation required

### 🍎 macOS (Intel x64 + Apple Silicon arm64)
- **DMG**: Disk images for easy installation
  - `xibe-chat-macos-x64-v{version}-{build_number}.dmg` (Intel)
  - `xibe-chat-macos-arm64-v{version}-{build_number}.dmg` (Apple Silicon)
- **ZIP**: Portable app bundles
  - `xibe-chat-macos-x64-v{version}-{build_number}.zip`
  - `xibe-chat-macos-arm64-v{version}-{build_number}.zip`

### 🐧 Linux (x64)
- **DEB**: Debian/Ubuntu package
  - `xibe-chat-linux-x64-v{version}-{build_number}.deb`
  - Easy installation with `dpkg`
- **AppImage**: Universal Linux application
  - `xibe-chat-linux-x64-v{version}-{build_number}.AppImage`
  - Run anywhere without installation
- **TAR.GZ**: Portable archive
  - `xibe-chat-linux-x64-v{version}-{build_number}.tar.gz`

### 📱 iOS
- **IPA**: iOS application package (unsigned)
  - `xibe-chat-ios-unsigned-v{version}-{build_number}.ipa`
  - Requires code signing for installation

## Release Tag Format

Releases are tagged as: `v{version}-{build_number}`

Examples:
- `v1.0.0-1` (Version 1.0.0, Build 1)
- `v1.0.1-2` (Version 1.0.1, Build 2)
- `v2.0.0-15` (Version 2.0.0, Build 15)

## Artifact Cleanup

After the release is created and all files are uploaded, the workflow automatically:
1. Deletes the intermediate build artifacts from GitHub Actions
2. Keeps only the release files publicly available

This saves storage space and keeps your Actions clean.

## Download Links

Once the workflow completes, users can download the builds from:

```
https://github.com/iotserver24/Flutterrrr/releases/tag/v{version}-{build_number}
```

Example: `https://github.com/iotserver24/Flutterrrr/releases/tag/v1.0.0-1`

## Platform-Specific Installation Instructions

### 📱 Android

#### APK Installation
1. Download the APK file from the release
2. Enable "Install from Unknown Sources" in Settings → Security
3. Tap the downloaded APK to install
4. Grant necessary permissions

#### AAB (For Developers)
1. Upload to Google Play Console
2. Google Play will generate optimized APKs for each device

### 💻 Windows

#### MSIX Installer (Recommended)
1. Download the MSIX file
2. Double-click to install
3. First-time: Trust the self-signed certificate when prompted
4. App installs like a Microsoft Store app
5. Can be uninstalled via Settings → Apps

#### Portable ZIP
1. Download the ZIP file
2. Extract to any folder (e.g., `C:\Program Files\XibeChat`)
3. Run `xibe_chat.exe`
4. No installation or admin rights required

### 🍎 macOS

#### DMG Installer (Recommended)
1. Download the appropriate DMG:
   - Intel Macs: `*-x64-*.dmg`
   - Apple Silicon: `*-arm64-*.dmg`
2. Open the DMG file
3. Drag Xibe Chat to Applications folder
4. First launch: Right-click → Open (to bypass Gatekeeper)
5. Allow permissions in System Preferences → Security

#### ZIP Archive
1. Download the appropriate ZIP file
2. Extract the .app bundle
3. Move to Applications folder
4. Right-click → Open on first launch

### 🐧 Linux

#### DEB Package (Debian/Ubuntu)
```bash
# Download the DEB file
wget https://github.com/iotserver24/Flutterrrr/releases/download/v{version}-{build}/xibe-chat-linux-x64-*.deb

# Install
sudo dpkg -i xibe-chat-linux-x64-*.deb

# Fix dependencies if needed
sudo apt-get install -f

# Run from applications menu or terminal
xibe-chat
```

#### AppImage (Universal)
```bash
# Download the AppImage
wget https://github.com/iotserver24/Flutterrrr/releases/download/v{version}-{build}/xibe-chat-linux-x64-*.AppImage

# Make executable
chmod +x xibe-chat-linux-x64-*.AppImage

# Run
./xibe-chat-linux-x64-*.AppImage
```

#### TAR.GZ Archive
```bash
# Download and extract
wget https://github.com/iotserver24/Flutterrrr/releases/download/v{version}-{build}/xibe-chat-linux-x64-*.tar.gz
tar -xzf xibe-chat-linux-x64-*.tar.gz
cd xibe-chat-linux-x64-*

# Run
./xibe_chat
```

### 📱 iOS

#### IPA Installation (Requires Signing)
1. Download the unsigned IPA
2. Sign with your Apple Developer certificate using:
   - Xcode
   - iOS App Signer
   - AltStore
   - Sideloadly
3. Install via:
   - Xcode Devices window
   - iTunes File Sharing
   - TestFlight (if signed with enterprise cert)

**Note**: Unsigned IPAs cannot be installed directly. Code signing is required.

## Troubleshooting

### Workflow Fails to Start
- Check that you're on the correct branch
- Ensure you have necessary permissions (write access)
- Verify GitHub Actions is enabled for the repository

### Build Failures

#### Android
- Java version mismatch: Workflow uses Java 17
- Gradle issues: Check android/build.gradle configuration
- SDK version problems: Update targetSdk in android/app/build.gradle

#### Windows
- Platform files missing: Workflow auto-creates them
- MSIX signing: Certificate generation is automatic
- Path issues: Use PowerShell commands as in workflow

#### macOS
- Xcode version: Ensure macOS runner has compatible Xcode
- Code signing: DMG creation may fail without proper setup
- Architecture: Specify correct target platform (x64 vs arm64)

#### Linux
- Dependencies: Install required packages (see workflow)
- AppImage creation: May fail on some systems, continues with other formats
- GTK version: Ensure libgtk-3-dev is available

#### iOS
- Provisioning profiles: IPA is unsigned by default
- Xcode version: Use compatible Xcode on macOS runner
- Simulator vs Device: Workflow builds for device

### Platform-Specific Issues

#### Windows Desktop App
- **Database not working**: Fixed with sqflite_common_ffi
- **Window size**: App should be responsive across platforms
- **File paths**: Now uses proper Documents folder on Windows

#### Certificate Issues (Windows MSIX)
- The MSIX is signed with a self-signed certificate
- Users may need to manually trust the certificate
- For production, use a proper code signing certificate from a CA

#### macOS Gatekeeper
- Unsigned apps require right-click → Open
- Consider notarizing for production releases
- Use `codesign` for proper signing

## Performance Optimization

### Caching Strategy
The workflow uses caching for:
- Flutter SDK (`cache: true` in flutter-action)
- Gradle dependencies (Android)
- Build artifacts between steps

### Build Time Estimates
- **Android**: 5-10 minutes
- **Windows**: 8-15 minutes
- **macOS** (both arch): 15-25 minutes
- **Linux**: 10-15 minutes
- **iOS**: 10-15 minutes
- **Total parallel time**: ~25-30 minutes

## Version Management

### Semantic Versioning
- **Major** (X.0.0): Breaking changes, incompatible API changes
- **Minor** (1.X.0): New features, backward compatible
- **Patch** (1.0.X): Bug fixes, no new features

### Build Numbers
- Increment for each build of the same version
- Useful for testing and beta releases
- Example: v1.0.0-1, v1.0.0-2, v1.0.0-3

### Version in Code
Update `pubspec.yaml` before running workflow:
```yaml
version: 1.0.0+1  # version+build_number
```

## Best Practices

1. **Test locally first**: Build and test on your machine before running the workflow
2. **Use meaningful versions**: Follow semantic versioning
3. **Increment build numbers**: For each new build attempt
4. **Document changes**: Update release notes in the workflow or manually
5. **Keep workflow updated**: Update Flutter version as needed
6. **Test on target platforms**: Download and test each platform's build
7. **Monitor build times**: Optimize if builds take too long
8. **Check artifact sizes**: Ensure builds aren't unnecessarily large

## Customization

### Modify the Workflow

Edit `.github/workflows/build-release.yml`:

```yaml
# Change Flutter version
env:
  FLUTTER_VERSION: '3.24.5'  # or 'stable' for latest

# Add/remove architectures
strategy:
  matrix:
    arch: [x64, arm64]  # Add or remove as needed

# Modify build commands
- run: flutter build <platform> --release --custom-flag
```

### App Configuration

1. **pubspec.yaml**: Package settings, dependencies, versions
2. **msix_config**: Windows MSIX-specific settings
3. **android/**: Android-specific configuration
4. **ios/**: iOS-specific configuration
5. **macos/**: macOS-specific configuration
6. **linux/**: Linux-specific configuration
7. **windows/**: Windows-specific configuration

### Platform Support Notes

- **Windows**: Currently builds x64 only (arm64 support limited)
- **macOS**: Builds both x64 (Intel) and arm64 (Apple Silicon)
- **Linux**: Builds x64 only (arm64/x86 require cross-compilation)
- **Android**: Universal APK includes all architectures
- **iOS**: Unsigned IPA, requires developer signing

## Advanced Features

### Code Signing (Production)

#### Windows
Replace self-signed certificate with proper code signing certificate:
```powershell
# Use existing certificate
$cert = Get-ChildItem Cert:\CurrentUser\My | Where-Object {$_.Subject -like "*YourCompany*"}
```

#### macOS
Add signing configuration:
```bash
codesign --force --sign "Developer ID Application: Your Name" xibe_chat.app
```

#### iOS
Configure in Xcode project settings or use fastlane for automation.

### CI/CD Integration

The workflow can be triggered automatically:
```yaml
on:
  push:
    tags:
      - 'v*'
  workflow_dispatch:
    # Manual trigger
```

### Matrix Strategy Expansion

To add more architectures:
```yaml
strategy:
  matrix:
    platform: [windows, macos, linux]
    arch: [x64, arm64]
  exclude:
    - platform: windows
      arch: arm64  # If not supported yet
```

## Notes

- **Parallel builds**: All platforms build simultaneously for speed
- **Artifact retention**: Temporary artifacts kept for 1 day
- **Release artifacts**: Permanent in GitHub Releases
- **Self-signed certificates**: Generated fresh for each Windows build
- **Manual trigger**: Use workflow_dispatch (not automatic on push)
- **Cross-platform database**: Now works on desktop with sqflite_common_ffi
- **Flutter stable**: Uses latest stable Flutter SDK
- **Caching enabled**: Speeds up subsequent builds significantly

## Support

For issues or questions:
1. Check workflow logs in GitHub Actions
2. Review this documentation
3. Check Flutter documentation for platform-specific issues
4. Open an issue in the repository

## Legacy Workflow

The previous workflow is preserved as `build-release-legacy.yml` for historical reference only. It builds Android APK and Windows MSIX/EXE only. **This legacy workflow is not maintained and may be removed in future versions.** Use the new multi-platform `build-release.yml` workflow for all builds.
