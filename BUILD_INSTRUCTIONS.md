# Build Instructions for Xibe Chat

This Flutter app requires Flutter SDK to build. Due to network restrictions in the build environment, you may need to build locally or in a different environment with internet access.

## Prerequisites

1. **Flutter SDK 3.0.0+**
   - Download from: https://flutter.dev/docs/get-started/install
   - Or use FVM: `fvm install stable`

2. **Android SDK**
   - Install Android Studio or Android Command Line Tools
   - Ensure ANDROID_HOME is set

3. **Java 17+**
   - Required for Android builds

## Build Steps

### 1. Install Flutter Dependencies

```bash
cd /home/runner/work/Flutterrrr/Flutterrrr
flutter pub get
```

### 2. Check Flutter Doctor

```bash
flutter doctor
```

Ensure Android toolchain and required components are installed.

### 3. Build Release APK

```bash
flutter build apk --release
```

The APK will be generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### 4. Build App Bundle (Optional)

```bash
flutter build appbundle --release
```

## Alternative: Build with GitHub Actions

Create `.github/workflows/build.yml`:

```yaml
name: Build APK

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.5'
          channel: 'stable'
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: app-release
          path: build/app/outputs/flutter-apk/app-release.apk
      - name: Create Release
        uses: softprops/action-gh-release@v1
        if: startsWith(github.ref, 'refs/tags/')
        with:
          files: build/app/outputs/flutter-apk/app-release.apk
```

## Local Development

### Run in Debug Mode

```bash
flutter run
```

### Run Tests

```bash
flutter test
```

### Analyze Code

```bash
flutter analyze
```

## Configuration

### API Endpoint

The app connects to `http://my-vps:3000/api/chat` by default.

To change this, edit `lib/services/api_service.dart`:

```dart
ApiService({this.baseUrl = 'http://your-api-endpoint:port'});
```

### App Signing (For Production)

1. Create a keystore:
   ```bash
   keytool -genkey -v -keystore ~/xibe-chat-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias xibechat
   ```

2. Create `android/key.properties`:
   ```
   storePassword=<password>
   keyPassword=<password>
   keyAlias=xibechat
   storeFile=<path-to-keystore>
   ```

3. Update `android/app/build.gradle` to use the keystore for release builds.

## Troubleshooting

### Flutter SDK Download Issues

If you encounter issues downloading Flutter SDK components:

1. Use a VPN or proxy
2. Use Flutter's China mirror:
   ```bash
   export PUB_HOSTED_URL=https://pub.flutter-io.cn
   export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
   ```
3. Download Flutter archive directly and extract manually

### Build Failures

1. Clean build:
   ```bash
   flutter clean
   flutter pub get
   ```

2. Check dependencies:
   ```bash
   flutter pub outdated
   ```

3. Update dependencies:
   ```bash
   flutter pub upgrade
   ```
