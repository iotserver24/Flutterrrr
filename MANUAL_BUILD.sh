#!/bin/bash
# Manual build script for Xibe Chat
# Run this script when Flutter SDK is available

set -e

echo "=== Xibe Chat Build Script ==="
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed!"
    echo ""
    echo "Please install Flutter SDK from:"
    echo "  https://flutter.dev/docs/get-started/install"
    echo ""
    echo "Or install via FVM:"
    echo "  fvm install stable"
    echo "  fvm use stable"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n1)"
echo ""

# Navigate to project directory
cd "$(dirname "$0")"

echo "📦 Installing dependencies..."
flutter pub get

echo ""
echo "🔍 Running Flutter doctor..."
flutter doctor

echo ""
echo "🔨 Building release APK..."
flutter build apk --release

echo ""
echo "✅ Build complete!"
echo ""
echo "APK location:"
echo "  $(pwd)/build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "Install on device:"
echo "  adb install build/app/outputs/flutter-apk/app-release.apk"
echo ""
