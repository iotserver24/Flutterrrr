# App Signing Guide for Production

## Overview

✅ **The app is now configured with release signing!**

A keystore has been created and the build configuration has been updated to support signed releases. The keystore file is located at `android/app/xibe-chat-app.jks` and is automatically excluded from Git.

## Keystore Details

The existing keystore was created with these specifications:

- **File**: `android/app/xibe-chat-app.jks`
- **Key Alias**: `R3AP3Redit`
- **Algorithm**: RSA 2048-bit
- **Validity**: 10,000 days
- **Distinguished Name**:
  - CN: xibe-chat-app
  - OU: R3AP3Redit
  - O: R3AP3Redit
  - L: Karnataka
  - ST: Karnataka
  - C: IN

## Local Development Setup

### 1. Create key.properties File

Create `android/key.properties` (this file is gitignored):

```properties
storePassword=<YOUR_KEYSTORE_PASSWORD>
keyPassword=<YOUR_KEY_PASSWORD>
keyAlias=R3AP3Redit
storeFile=xibe-chat-app.jks
```

You can use `android/key.properties.example` as a template.

### 2. Build Configuration (Already Done ✅)

The `android/app/build.gradle` has been updated to:
- Load signing configuration from `key.properties`
- Use release signing when `key.properties` exists
- Fall back to debug signing if `key.properties` is not present

### 3. Gitignore (Already Done ✅)

The following are now excluded from Git:
- `android/key.properties`
- `android/app/*.jks`
- `android/app/*.keystore`
- `*.jks`
- `*.keystore`

## Building Signed APK

### Command Line

```bash
flutter build apk --release
```

The signed APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Verify Signing

Check the signing certificate:

```bash
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk
```

## Building for Google Play Store

For Google Play Store distribution, build an App Bundle instead:

```bash
flutter build appbundle --release
```

The bundle will be at:
```
build/app/outputs/bundle/release/app-release.aab
```

## GitHub Actions Integration (Already Done ✅)

The GitHub Actions workflow has been updated to support signed builds!

### Required GitHub Secrets

Add these secrets to your repository (Settings → Secrets and variables → Actions):

1. **KEYSTORE_BASE64** - Base64-encoded keystore file
2. **KEYSTORE_PASSWORD** - Your keystore password  
3. **KEY_PASSWORD** - Your key password
4. **KEY_ALIAS** - `R3AP3Redit`

### Detailed Instructions

See [GITHUB_ACTIONS_SECRETS.md](GITHUB_ACTIONS_SECRETS.md) for complete step-by-step instructions on:
- How to encode your keystore to base64
- How to add secrets to GitHub
- How to verify signing works
- Troubleshooting common issues

### How It Works

The workflow automatically:
1. Decodes the base64 keystore from secrets
2. Creates the `key.properties` file with your credentials
3. Builds signed APK and AAB files
4. Falls back to debug signing if secrets are not configured

## Security Best Practices

### Do's ✅

- Keep keystore file backed up securely (but not in git)
- Use strong passwords
- Store passwords in a password manager
- Use different keys for different apps
- Keep key.properties out of version control
- Use GitHub Secrets for CI/CD

### Don'ts ❌

- Never commit keystore files to git
- Never commit key.properties to git
- Never share your keystore or passwords
- Never use debug signing for production releases
- Never lose your keystore (you can't update your app!)

## Keystore Backup

### Create Encrypted Backup

```bash
# Create encrypted backup
tar czf keystore-backup.tar.gz ~/keystores/xibe-chat-release.jks
gpg --symmetric --cipher-algo AES256 keystore-backup.tar.gz

# Store keystore-backup.tar.gz.gpg securely
# Delete unencrypted files
shred -u keystore-backup.tar.gz
```

### Restore from Backup

```bash
# Decrypt
gpg --decrypt keystore-backup.tar.gz.gpg > keystore-backup.tar.gz

# Extract
tar xzf keystore-backup.tar.gz

# Secure permissions
chmod 600 ~/keystores/xibe-chat-release.jks
```

## Troubleshooting

### "keystore file not found"

Check that the path in `key.properties` is correct and absolute.

### "wrong password"

Verify you're using the correct keystore and key passwords.

### "certificate expired"

Generate a new keystore with longer validity period.

### "signing config not found"

Ensure `key.properties` exists and `signingConfigs.release` is properly configured.

## For Development/Testing Only

The current configuration uses debug signing, which is fine for:
- Development builds
- Internal testing
- CI/CD testing
- APKs shared with testers

For production releases or app store uploads, follow the steps above to set up proper release signing.

## References

- [Android App Signing Documentation](https://developer.android.com/studio/publish/app-signing)
- [Flutter Deployment Documentation](https://docs.flutter.dev/deployment/android)
- [Gradle Signing Configuration](https://developer.android.com/studio/publish/app-signing#gradle-sign)
