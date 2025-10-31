# Xibe Chat

A modern AI chat application for Android built with Flutter.

## Features

- 🤖 AI-powered chat interface
- 💬 Multiple conversation threads
- 🌙 Dark/Light theme support
- 📝 Markdown message rendering
- 💾 Local chat history with SQLite
- 🌐 Web search integration
- 📋 Copy message functionality
- ⚡ Real-time typing indicators

## Screenshots

Coming soon!

## Installation

Download the latest APK from the [Releases](https://github.com/iotserver24/Flutterrrr/releases) page.

## Configuration

The app connects to an AI backend at `http://my-vps:3000/api/chat`. You can modify the API endpoint in `lib/services/api_service.dart`.

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
