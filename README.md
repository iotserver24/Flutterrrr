# Xibe Chat
//copilot made this lol
A modern AI chat application built with Flutter - available on Android, iOS, Windows, macOS, and Linux.

## 🎯 NEW: Android Build Fixed!

The GitHub Actions Android build issue has been fixed! 

**Quick Setup (5 minutes):** See [QUICK_START.md](QUICK_START.md) for immediate instructions.

## 🔐 Android Release Signing

The app is now configured for signed Android releases! To build signed APKs/AABs:

- **Quick Start**: [QUICK_START.md](QUICK_START.md) - Fix the build in 3 steps!
- **For GitHub Actions**: See [KEYSTORE_BASE64_INSTRUCTIONS.md](KEYSTORE_BASE64_INSTRUCTIONS.md) - detailed setup
- **For local builds**: Create `android/key.properties` with your keystore passwords
- **What Changed**: [FIX_SUMMARY.md](FIX_SUMMARY.md) - complete fix documentation

Quick setup script: `./scripts/encode-keystore.sh` (Linux/macOS) or `.\scripts\encode-keystore.ps1` (Windows)

## Features

- 🤖 AI-powered chat interface with Xibe API integration
- 🔄 Real-time streaming responses for live chat
- 🎯 Multiple AI model selection (Gemini, OpenAI, DeepSeek, Mistral, and more)
- 💬 Multiple conversation threads
- 👋 Smart greetings based on time of day
- 🎨 Beautiful animations and smooth transitions
- 🌙 Dark/Light theme support
- 📝 Markdown message rendering
- 💾 Local chat history with SQLite
- 📋 Copy message functionality
- ⚡ Real-time typing indicators
- 🔑 Configurable API key support

## Screenshots

Coming soon!

## Installation

### Option 1: Download Pre-built Releases
Download the latest build for your platform from the [Releases](https://github.com/iotserver24/Flutterrrr/releases) page.

**Available Platforms:**
- 📱 **Android**: APK (universal) and AAB (Play Store)
- 💻 **Windows**: MSIX installer and portable ZIP (x64)
- 🍎 **macOS**: DMG and ZIP for Intel and Apple Silicon
- 🐧 **Linux**: DEB, AppImage, and TAR.GZ (x64)
- 📱 **iOS**: IPA (requires signing)

See [WORKFLOW_USAGE.md](WORKFLOW_USAGE.md) for detailed installation instructions for each platform.

### Option 2: Build from Source
See [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md) for detailed build instructions.

Quick build for Android:
```bash
./MANUAL_BUILD.sh
```

Or build for any platform:
```bash
flutter pub get

# Android
flutter build apk --release

# Windows (on Windows)
flutter build windows --release

# macOS (on macOS)
flutter build macos --release

# Linux (on Linux)
flutter build linux --release

# iOS (on macOS)
flutter build ios --release --no-codesign
```

## Configuration

### API Key Setup

The app uses the Xibe API (https://api.xibe.app) for AI responses. You can configure the API key in two ways:

1. **Through the app settings**:
   - Open the app
   - Navigate to Settings (☰ menu → Settings icon)
   - Enter your Xibe API key in the "API Configuration" section
   - Click the save button

2. **Using environment variable**:
   - Set the `XIBE_API` environment variable with your API key
   - The app will automatically use this key if no key is set in settings

If no API key is configured, the app will attempt to use the default configuration.

### Available AI Models

The app automatically fetches available models from the Xibe API. You can switch between models using the robot icon (🤖) in the top right corner of the chat screen. Available models include:
- Gemini 2.5 Flash Lite
- OpenAI GPT-5 Nano
- DeepSeek V3.1
- Mistral Small 3.2
- Qwen 2.5 Coder
- And many more!

## Building from Source

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Android SDK
- Android Studio or VS Code with Flutter extensions

### Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/iotserver24/Flutterrrr.git
   cd Flutterrrr
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

4. Build release APK:
   ```bash
   flutter build apk --release
   ```

The APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`.

## Tech Stack

- **Framework**: Flutter (cross-platform)
- **State Management**: Provider
- **Local Storage**: SQLite (sqflite + sqflite_common_ffi for desktop)
- **HTTP Client**: http package
- **Markdown Rendering**: flutter_markdown
- **Platforms**: Android, iOS, Windows, macOS, Linux

## License

MIT License
