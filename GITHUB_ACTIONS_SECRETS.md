# GitHub Actions Secrets Configuration

This document explains how to configure GitHub Actions secrets for Android app signing.

## Required GitHub Secrets

To enable signed Android builds in GitHub Actions, you need to add the following secrets to your repository:

### 1. Navigate to Repository Settings

1. Go to your GitHub repository
2. Click on **Settings**
3. In the left sidebar, click **Secrets and variables** → **Actions**
4. Click **New repository secret**

### 2. Add These Secrets

#### KEYSTORE_BASE64
- **Name**: `KEYSTORE_BASE64`
- **Value**: Base64-encoded content of your keystore file
- **How to generate**:
  ```bash
  # On Linux/macOS
  base64 -i android/app/xibe-chat-app.jks | tr -d '\n' > keystore.txt
  # Copy the content of keystore.txt
  
  # Alternative: Direct to clipboard (macOS)
  base64 -i android/app/xibe-chat-app.jks | tr -d '\n' | pbcopy
  
  # Alternative: Direct to clipboard (Linux with xclip)
  base64 -i android/app/xibe-chat-app.jks | tr -d '\n' | xclip -selection clipboard
  
  # On Windows (PowerShell)
  [Convert]::ToBase64String([IO.File]::ReadAllBytes("android\app\xibe-chat-app.jks")) | Set-Clipboard
  ```

#### KEYSTORE_PASSWORD
- **Name**: `KEYSTORE_PASSWORD`
- **Value**: The password you used when creating the keystore (the first password you entered)
- **Example**: `your_keystore_password`

#### KEY_PASSWORD
- **Name**: `KEY_PASSWORD`
- **Value**: The key password you used when creating the keystore (the second password you entered, usually the same as keystore password)
- **Example**: `your_key_password`

#### KEY_ALIAS
- **Name**: `KEY_ALIAS`
- **Value**: `R3AP3Redit`
- **Note**: This is the alias you specified when creating the keystore

## Summary of Your Keystore Details

Based on the keystore creation in the problem statement:

- **Keystore File**: `xibe-chat-app.jks` (now located at `android/app/xibe-chat-app.jks`)
- **Key Alias**: `R3AP3Redit`
- **Distinguished Name**:
  - CN (Common Name): xibe-chat-app
  - OU (Organizational Unit): R3AP3Redit
  - O (Organization): R3AP3Redit
  - L (Locality): Karnataka
  - ST (State): Karnataka
  - C (Country): IN
- **Key Algorithm**: RSA
- **Key Size**: 2048 bits
- **Validity**: 10,000 days

## Verifying Secrets Are Set Correctly

After adding all four secrets, your GitHub Actions workflow will:
1. Decode the base64 keystore
2. Create the `key.properties` file
3. Build signed APK and AAB files

You can verify this worked by:
1. Running the workflow
2. Checking the build logs for "✅ Release signing configured"
3. Downloading the APK and verifying it's signed:
   ```bash
   jarsigner -verify -verbose -certs app-release.apk
   ```

## Security Notes

⚠️ **Important Security Considerations**:

1. **Never commit keystore files to Git** - They are now excluded via `.gitignore`
2. **Never commit `key.properties` to Git** - It's excluded via `.gitignore`
3. **Keep your passwords secure** - Use GitHub Secrets, never hardcode them
4. **Backup your keystore** - Store it securely (encrypted backup recommended)
5. **Limit access** - Only give repository access to trusted developers
6. **Rotate secrets if compromised** - If secrets leak, immediately generate a new keystore

## Local Development

For local development, create `android/key.properties`:

```properties
storePassword=<YOUR_KEYSTORE_PASSWORD>
keyPassword=<YOUR_KEY_PASSWORD>
keyAlias=R3AP3Redit
storeFile=xibe-chat-app.jks
```

You can use `android/key.properties.example` as a template.

**Note**: `key.properties` is gitignored and will not be committed.

## Testing Local Build

To test that signing works locally:

```bash
# Build APK
flutter build apk --release

# Verify signing
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk

# Build App Bundle
flutter build appbundle --release

# Verify bundle signing
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

## Troubleshooting

### "keystore file not found"
- Verify the keystore file exists at `android/app/xibe-chat-app.jks`
- Check that `storeFile` in `key.properties` is set to `xibe-chat-app.jks` (relative path)

### "wrong password"
- Double-check `KEYSTORE_PASSWORD` and `KEY_PASSWORD` secrets
- Ensure you're using the correct passwords from keystore creation

### "key alias not found"
- Verify `KEY_ALIAS` secret is set to `R3AP3Redit`
- Check alias in keystore:
  ```bash
  keytool -list -v -keystore android/app/xibe-chat-app.jks
  ```

### GitHub Actions fails with base64 decode error
- Ensure `KEYSTORE_BASE64` has no line breaks (use `tr -d '\n'`)
- Verify the entire base64 string was copied

## References

- [Flutter Android Deployment Guide](https://docs.flutter.dev/deployment/android)
- [Android App Signing Documentation](https://developer.android.com/studio/publish/app-signing)
- [GitHub Actions Encrypted Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
