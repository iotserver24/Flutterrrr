# Multi-Platform Build Instructions for Xibe Chat

Xibe Chat is a cross-platform Flutter application that can be built for Android, iOS, Windows, macOS, and Linux. This guide covers building for all platforms.

## Prerequisites

### Common Requirements

1. **Flutter SDK (Latest Stable)**
   - Download from: https://flutter.dev/docs/get-started/install
   - Or use FVM: `fvm install stable`
   - Minimum version: 3.0.0+

2. **Git**
   - Required to clone the repository

### Platform-Specific Requirements

#### For Android Builds
- **Android SDK**
  - Install via Android Studio or Android Command Line Tools
  - Ensure `ANDROID_HOME` environment variable is set
- **Java 17+** (JDK)
  - Required for Gradle builds

#### For iOS Builds
- **macOS** (required)
- **Xcode 14+**
  - Install from Mac App Store
- **CocoaPods**
  - Install: `sudo gem install cocoapods`

#### For Windows Builds
- **Windows 10/11**
- **Visual Studio 2022** (Community edition or higher)
  - Install "Desktop development with C++" workload
  - Ensure Windows 10 SDK is installed

#### For macOS Builds
- **macOS 10.14+**
- **Xcode 14+**
  - Required for building macOS apps
- **CocoaPods**

#### For Linux Builds
- **Linux** (Ubuntu 20.04+ recommended)
- **Development tools**:
  ```bash
  sudo apt-get update
  sudo apt-get install -y \
    clang cmake ninja-build pkg-config \
    libgtk-3-dev liblzma-dev libstdc++-12-dev
  ```

## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/iotserver24/Flutterrrr.git
cd Flutterrrr
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Verify Setup

```bash
flutter doctor -v
```

Ensure all required components for your target platform are installed.

## Building for Each Platform

### 📱 Android

#### Build APK (Universal)
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

#### Build App Bundle (for Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

#### Build Split APKs (per architecture)
```bash
flutter build apk --split-per-abi --release
```
Output: `build/app/outputs/flutter-apk/app-*-release.apk`

### 💻 Windows

#### Enable Windows Desktop
```bash
flutter config --enable-windows-desktop
```

#### Create Windows platform files (if not present)
```bash
flutter create --platforms=windows .
```

#### Build Windows Release
```bash
flutter build windows --release
```
Output: `build/windows/x64/runner/Release/`

#### Build MSIX Installer
```bash
flutter pub run msix:create
```
Output: `build/windows/x64/runner/Release/*.msix`

### 🍎 macOS

#### Enable macOS Desktop
```bash
flutter config --enable-macos-desktop
```

#### Create macOS platform files (if not present)
```bash
flutter create --platforms=macos .
```

#### Build macOS app (Universal Binary)
```bash
flutter build macos --release
```

**Note**: Flutter automatically creates universal binaries for macOS that support both Intel (x64) and Apple Silicon (arm64). The `--target-platform` flag is not supported for macOS builds.

Output: `build/macos/Build/Products/Release/xibe_chat.app`

#### Create DMG (requires create-dmg)
```bash
# Install create-dmg
brew install create-dmg

# Create DMG
create-dmg \
  --volname "Xibe Chat" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --app-drop-link 600 185 \
  "XibeChat.dmg" \
  "build/macos/Build/Products/Release/xibe_chat.app"
```

### 🐧 Linux

#### Enable Linux Desktop
```bash
flutter config --enable-linux-desktop
```

#### Create Linux platform files (if not present)
```bash
flutter create --platforms=linux .
```

#### Build Linux Release
```bash
flutter build linux --release
```
Output: `build/linux/x64/release/bundle/`

#### Create DEB Package
See the GitHub Actions workflow for detailed DEB creation steps, or use:
```bash
# Install dpkg-deb if not present
sudo apt-get install dpkg-deb

# Package structure should be:
# deb-package/
# ├── DEBIAN/
# │   └── control
# ├── opt/
# │   └── xibe-chat/
# │       └── (app files)
# └── usr/
#     └── share/
#         └── applications/
#             └── xibe-chat.desktop

dpkg-deb --build deb-package xibe-chat.deb
```

### 📱 iOS

#### Create iOS platform files (if not present)
```bash
flutter create --platforms=ios .
```

#### Build Unsigned IPA
```bash
flutter build ios --release --no-codesign
```

#### Create IPA Archive
```bash
mkdir Payload
cp -r build/ios/iphoneos/Runner.app Payload/
zip -r xibe-chat.ipa Payload
rm -rf Payload
```

**Note**: Unsigned IPAs require code signing before installation on devices.

#### Build with Xcode (Signed)
1. Open `ios/Runner.xcworkspace` in Xcode
2. Configure signing in "Signing & Capabilities"
3. Product → Archive
4. Export IPA with your distribution certificate

## Automated Build with GitHub Actions

The repository includes a comprehensive GitHub Actions workflow that builds for all platforms automatically.

### How to Use

1. Go to **Actions** tab in GitHub
2. Select **"Build and Release"** workflow
3. Click **"Run workflow"**
4. Enter version (e.g., `1.0.0`) and build number (e.g., `1`)
5. Wait for builds to complete (~25-30 minutes)
6. Download artifacts from the **Releases** page

See [WORKFLOW_USAGE.md](WORKFLOW_USAGE.md) for detailed workflow documentation.

## Local Development

### Run in Debug Mode

```bash
# Automatically detect and run on available device
flutter run

# Run on specific device
flutter devices  # List available devices
flutter run -d <device-id>

# Run on specific platform
flutter run -d windows
flutter run -d macos
flutter run -d linux
flutter run -d chrome  # Web
```

### Hot Reload

While running in debug mode:
- Press `r` to hot reload
- Press `R` to hot restart
- Press `q` to quit

### Run Tests

```bash
flutter test
```

### Analyze Code

```bash
flutter analyze
```

### Format Code

```bash
flutter format lib/
```

## Configuration

### API Endpoint

The app connects to the Xibe API. To configure:

1. **Via Settings UI**: Open app → Settings → Enter API key
2. **Via Environment Variable**: Set `XIBE_API` environment variable
3. **Via Code**: Edit `lib/services/api_service.dart`:
   ```dart
   ApiService({this.baseUrl = 'https://api.xibe.app'});
   ```

### App Signing (Production)

#### Android Signing

1. **Create a keystore**:
   ```bash
   keytool -genkey -v -keystore ~/xibe-chat-key.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias xibechat
   ```

2. **Create `android/key.properties`**:
   ```properties
   storePassword=<your-password>
   keyPassword=<your-password>
   keyAlias=xibechat
   storeFile=<path-to-keystore>
   ```

3. **Update `android/app/build.gradle`**:
   ```gradle
   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }

   android {
       ...
       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
               storePassword keystoreProperties['storePassword']
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
           }
       }
   }
   ```

#### Windows Code Signing

Use a proper code signing certificate from a Certificate Authority:
```bash
signtool sign /f certificate.pfx /p password /t http://timestamp.digicert.com xibe_chat.exe
```

#### macOS Code Signing

```bash
# Sign the app
codesign --deep --force --verify --verbose \
  --sign "Developer ID Application: Your Name (TEAM_ID)" \
  xibe_chat.app

# Verify signing
codesign --verify --verbose xibe_chat.app
spctl --assess --verbose xibe_chat.app

# Notarize for Gatekeeper
xcrun notarytool submit xibe_chat.zip \
  --apple-id "your@email.com" \
  --team-id "TEAM_ID" \
  --password "app-specific-password"
```

#### iOS Code Signing

1. Configure in Xcode project settings
2. Or use fastlane:
   ```ruby
   lane :release do
     build_app(scheme: "Runner")
     upload_to_testflight
   end
   ```

## Platform-Specific Notes

### Windows Desktop Issues

✅ **Fixed**: The Windows app now works correctly with local database storage using `sqflite_common_ffi`.

If you encounter issues:
- Ensure Visual C++ Redistributables are installed
- Check Windows Defender isn't blocking the app
- Run as Administrator if needed for first launch

### macOS Gatekeeper

On first launch, macOS may block the app:
1. Right-click the app
2. Select "Open"
3. Click "Open" in the dialog

Or disable Gatekeeper temporarily:
```bash
sudo spctl --master-disable
```

### Linux Dependencies

If the app doesn't start:
```bash
# Install required libraries
sudo apt-get install libgtk-3-0 libblkid1 liblzma5
```

## Troubleshooting

### Flutter SDK Issues

**Problem**: Flutter SDK download fails

**Solution**:
```bash
# Use Flutter's mirror (for restricted networks)
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

# Or download Flutter archive directly
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz
tar xf flutter_linux_3.24.5-stable.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"
```

### Build Failures

**Problem**: Build fails with dependency errors

**Solution**:
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub upgrade

# For platform-specific issues
flutter doctor --verbose
```

**Problem**: Platform not enabled

**Solution**:
```bash
# Enable desired platforms
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop

# Verify
flutter config
```

### Database Issues (Desktop)

**Problem**: Database not working on Windows/macOS/Linux

**Solution**: Ensure `sqflite_common_ffi` is in `pubspec.yaml`:
```yaml
dependencies:
  sqflite_common_ffi: ^2.3.0
```

The app automatically detects the platform and uses the appropriate database implementation.

### Architecture Mismatches

**Problem**: Build fails for arm64 on macOS

**Solution**:
```bash
# Flutter automatically builds universal binaries for macOS
# No need to specify architecture - both Intel and Apple Silicon are supported
flutter build macos --release
```

### Memory Issues

**Problem**: Build runs out of memory

**Solution**:
```bash
# Increase Gradle memory (Android)
# Edit android/gradle.properties
org.gradle.jvmargs=-Xmx4096m

# Reduce parallel builds
flutter build apk --release --no-tree-shake-icons
```

## Performance Optimization

### Reduce APK Size
```bash
# Build with split APKs
flutter build apk --split-per-abi --release

# Analyze APK size
flutter build apk --analyze-size --target-platform android-arm64
```

### Optimize Build Time
```bash
# Use cached builds
flutter build <platform> --release --cache

# Skip unnecessary steps
flutter build windows --release --no-pub
```

## Additional Resources

- **Flutter Documentation**: https://docs.flutter.dev
- **Platform Integration**: https://docs.flutter.dev/platform-integration
- **GitHub Actions Workflow**: [WORKFLOW_USAGE.md](WORKFLOW_USAGE.md)
- **Contributing**: [CONTRIBUTING.md](CONTRIBUTING.md)
- **Release Process**: [RELEASE.md](RELEASE.md)

## Quick Reference

| Platform | Command | Output |
|----------|---------|--------|
| Android APK | `flutter build apk --release` | `build/app/outputs/flutter-apk/` |
| Android AAB | `flutter build appbundle --release` | `build/app/outputs/bundle/release/` |
| Windows | `flutter build windows --release` | `build/windows/x64/runner/Release/` |
| macOS | `flutter build macos --release` | `build/macos/Build/Products/Release/` |
| Linux | `flutter build linux --release` | `build/linux/x64/release/bundle/` |
| iOS | `flutter build ios --release --no-codesign` | `build/ios/iphoneos/Runner.app` |
