#!/bin/bash
# Generate app icons for all platforms

set -e

echo "🎨 Generating app icons for all platforms..."

# Run flutter_launcher_icons to generate iOS and macOS icons
if command -v flutter &> /dev/null; then
    echo "📱 Generating iOS and macOS icons with flutter_launcher_icons..."
    flutter pub get
    flutter pub run flutter_launcher_icons
    echo "✅ iOS and macOS icons generated"
else
    echo "⚠️  Flutter not found, skipping iOS/macOS icon generation"
fi

echo "✅ Icon generation complete!"
