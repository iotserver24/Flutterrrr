#!/bin/bash

# Script to encode keystore file to base64 for GitHub Actions
# Usage: ./scripts/encode-keystore.sh

set -e

KEYSTORE_PATH="android/app/xibe-chat-app.jks"

echo "🔐 Android Keystore Encoder for GitHub Actions"
echo "================================================"
echo ""

# Check if keystore exists
if [ ! -f "$KEYSTORE_PATH" ]; then
    echo "❌ Error: Keystore file not found at $KEYSTORE_PATH"
    exit 1
fi

echo "✅ Found keystore: $KEYSTORE_PATH"
echo ""

# Encode to base64 (remove line breaks)
echo "📦 Encoding keystore to base64..."
BASE64_OUTPUT=$(base64 -i "$KEYSTORE_PATH" | tr -d '\n')

echo "✅ Encoding complete!"
echo ""
echo "================================================"
echo "🎯 Add this as KEYSTORE_BASE64 secret in GitHub:"
echo "================================================"
echo ""
echo "$BASE64_OUTPUT"
echo ""
echo "================================================"
echo ""
echo "📋 Next steps:"
echo "1. Copy the base64 string above"
echo "2. Go to GitHub → Settings → Secrets and variables → Actions"
echo "3. Click 'New repository secret'"
echo "4. Name: KEYSTORE_BASE64"
echo "5. Value: Paste the base64 string"
echo "6. Add the other 3 secrets: KEYSTORE_PASSWORD, KEY_PASSWORD, KEY_ALIAS"
echo ""
echo "For detailed instructions, see: GITHUB_ACTIONS_SECRETS.md"
