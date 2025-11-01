# Keystore Base64 Setup Instructions

## 📦 Using the Base64 Keystore File

This repository includes a pre-generated base64-encoded keystore file to make it easier to set up GitHub Actions for Android builds.

### File: `keystore_base64_clean.txt`

This file contains the base64-encoded version of the keystore (`xibe-chat-app.jks`), ready to be used as a GitHub Secret.

## 🚀 Quick Setup

### Step 1: Get the Base64 String

```bash
cat keystore_base64_clean.txt
```

Or simply copy the entire contents of the `keystore_base64_clean.txt` file.

### Step 2: Add to GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add the following secrets:

#### Required Secrets:

| Secret Name | Value | Notes |
|-------------|-------|-------|
| `KEYSTORE_BASE64` | Contents of `keystore_base64_clean.txt` | The entire base64 string |
| `KEYSTORE_PASSWORD` | `<your_keystore_password>` | Your keystore password from `android/key.properties` |
| `KEY_PASSWORD` | `<your_key_password>` | Your key password (usually same as keystore password) |
| `KEY_ALIAS` | `xibe_chat_key` | The alias used in the keystore |

### Step 3: Run the Workflow

1. Go to the **Actions** tab in your repository
2. Select **Multi-Platform Build and Release** workflow
3. Click **Run workflow**
4. Enter version and build number
5. Click **Run workflow**

The workflow will automatically:
- Decode the base64 keystore
- Create the `key.properties` file
- Build signed Android APK and AAB files

## 🔧 Technical Details

### How the Workflow Works

The GitHub Actions workflow uses this script to decode the keystore:

```bash
printf '%s' "$KEYSTORE_BASE64" | tr -d '\n\r\t ' | base64 -d > android/app/xibe-chat-app.jks
```

This approach:
- Uses `printf` instead of `echo` to avoid adding extra newlines
- Removes all whitespace and newlines with `tr -d '\n\r\t '`
- Decodes the base64 string with `base64 -d`
- Saves it to the correct location for the Android build

### Regenerating the Base64 File

If you need to regenerate the base64 file (e.g., if you create a new keystore):

**On Linux/macOS:**
```bash
base64 -w 0 xibe-chat-app.jks > keystore_base64_clean.txt
```

**On macOS (alternative):**
```bash
base64 -i xibe-chat-app.jks | tr -d '\n' > keystore_base64_clean.txt
```

**On Windows (PowerShell):**
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("xibe-chat-app.jks")) | Out-File -Encoding ASCII -NoNewline keystore_base64_clean.txt
```

## ✅ Verification

After adding the secrets and running the workflow:

1. Check the workflow logs for "✅ Release signing configured"
2. Look for the line showing keystore size: "📦 Keystore size: 2790 bytes"
3. Download the built APK and verify it's signed:
   ```bash
   jarsigner -verify -verbose -certs xibe-chat-v1.0.0-1.apk
   ```

## ⚠️ Security Notes

- **Never commit** the keystore file (`xibe-chat-app.jks`) to Git
- **Never commit** `key.properties` file to Git
- **Always use GitHub Secrets** for sensitive data in workflows
- **Keep backups** of your keystore in a secure location
- The passwords shown here are examples - use your actual passwords in GitHub Secrets

## 🔒 Keystore Details

The keystore in this repository:
- **File**: `xibe-chat-app.jks`
- **Alias**: `xibe_chat_key`
- **Type**: JKS (Java KeyStore)
- **Size**: 2790 bytes
- **Algorithm**: RSA 2048-bit
- **Validity**: 10,000 days

## 📚 Additional Resources

- [GITHUB_ACTIONS_SECRETS.md](GITHUB_ACTIONS_SECRETS.md) - Detailed GitHub Actions setup
- [KEYSTORE_QUICK_START.md](KEYSTORE_QUICK_START.md) - Quick start guide
- [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md) - Full build instructions
- [Flutter Android Deployment](https://docs.flutter.dev/deployment/android)

## 🐛 Troubleshooting

### "base64: invalid input" Error

This error occurs when:
- The base64 string has invalid characters
- Extra newlines or spaces in the secret value
- The secret wasn't copied completely

**Solution:**
1. Copy the **entire** contents of `keystore_base64_clean.txt`
2. Make sure no extra characters are added when pasting
3. The base64 string should be one continuous line with no breaks

### Workflow Fails with "Failed to create keystore file"

This means the base64 decoding failed. Check:
1. The `KEYSTORE_BASE64` secret is set correctly
2. The entire base64 string was copied (check the length)
3. No whitespace was added at the beginning or end

### Wrong Password Error

If the build fails with password errors:
1. Verify `KEYSTORE_PASSWORD` matches your actual keystore password
2. Verify `KEY_PASSWORD` matches your key password
3. Test locally first with `key.properties` to confirm passwords work

## 💡 Pro Tips

1. **Test Locally First**: Before using GitHub Actions, test the keystore locally by creating `android/key.properties` and running `flutter build apk --release`

2. **Verify the Base64**: You can test the base64 decoding locally:
   ```bash
   cat keystore_base64_clean.txt | base64 -d > /tmp/test.jks
   keytool -list -keystore /tmp/test.jks
   ```

3. **Keep Documentation Updated**: If you regenerate the keystore or change passwords, update this documentation accordingly.
