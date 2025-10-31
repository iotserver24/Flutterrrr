# Xibe Chat
//copilot made this lol
A modern AI chat application for Android built with Flutter.

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

### Option 1: Download Pre-built APK
Download the latest APK from the [Releases](https://github.com/iotserver24/Flutterrrr/releases) page.

### Option 2: Build from Source
See [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md) for detailed build instructions.

Quick build:
```bash
./MANUAL_BUILD.sh
```

Or manually:
```bash
flutter pub get
flutter build apk --release
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

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

- **Framework**: Flutter
- **State Management**: Provider
- **Local Storage**: SQLite (sqflite)
- **HTTP Client**: http package
- **Markdown Rendering**: flutter_markdown

## License

MIT License
