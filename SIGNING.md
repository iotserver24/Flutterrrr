# App Signing Guide for Production

## Overview

By default, the app uses debug signing for ease of development. For production releases distributed outside of Google Play, you should create a proper release signing configuration.

## Creating a Keystore

### 1. Generate a Keystore File

```bash
keytool -genkey -v -keystore ~/xibe-chat-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias xibechat
```

You'll be prompted for:
- Keystore password (remember this!)
- Key password (remember this!)
- Your name
- Organization details
- Country code

**Important**: Keep your keystore file and passwords secure. If you lose them, you cannot update your app!

### 2. Store Keystore Securely

Move the keystore to a secure location:
```bash
mkdir -p ~/keystores
mv ~/xibe-chat-release.jks ~/keystores/
chmod 600 ~/keystores/xibe-chat-release.jks
```

## Configure App Signing

### 1. Create key.properties File

Create `android/key.properties`:

```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=xibechat
storeFile=/path/to/your/keystores/xibe-chat-release.jks
```

**Important**: Add `android/key.properties` to `.gitignore` to avoid committing secrets!

### 2. Update app/build.gradle

Replace the release signing configuration in `android/app/build.gradle`:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... other configurations ...
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 3. Update .gitignore

Ensure these lines are in your `.gitignore`:

```gitignore
# Signing
android/key.properties
*.jks
*.keystore
```

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

## GitHub Actions Integration

### 1. Add Secrets to GitHub

Go to your repository settings → Secrets and variables → Actions, and add:

- `KEYSTORE_BASE64`: Base64-encoded keystore file
- `KEYSTORE_PASSWORD`: Your keystore password
- `KEY_PASSWORD`: Your key password
- `KEY_ALIAS`: Your key alias (e.g., "xibechat")

To encode your keystore:
```bash
base64 -i ~/keystores/xibe-chat-release.jks | pbcopy  # macOS
base64 -i ~/keystores/xibe-chat-release.jks           # Linux
```

### 2. Update Workflow

Modify `.github/workflows/build-release.yml`:

```yaml
- name: Setup signing
  run: |
    echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 --decode > android/app/keystore.jks
    echo "storePassword=${{ secrets.KEYSTORE_PASSWORD }}" >> android/key.properties
    echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties
    echo "keyAlias=${{ secrets.KEY_ALIAS }}" >> android/key.properties
    echo "storeFile=../app/keystore.jks" >> android/key.properties

- name: Build APK
  run: flutter build apk --release
```

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
