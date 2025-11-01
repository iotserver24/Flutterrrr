# Android Keystore Quick Start Guide

## 🎯 What You Need to Do

Your Android app is now configured for signed releases! Here's what you need to set up:

### 1️⃣ For Local Builds (Optional)

If you want to build signed APKs locally:

1. Create `android/key.properties` file:
   ```bash
   cp android/key.properties.example android/key.properties
   ```

2. Edit `android/key.properties` and add your passwords:
   ```properties
   storePassword=<YOUR_KEYSTORE_PASSWORD>
   keyPassword=<YOUR_KEY_PASSWORD>
   keyAlias=R3AP3Redit
   storeFile=xibe-chat-app.jks
   ```

3. Build your app:
   ```bash
   flutter build apk --release
   ```

**Note**: The `key.properties` file is gitignored and won't be committed to the repository.

### 2️⃣ For GitHub Actions Builds (Recommended)

To enable automatic signed builds in GitHub Actions:

1. **Navigate to your repository on GitHub**
2. **Go to Settings → Secrets and variables → Actions**
3. **Add these 4 secrets**:

   | Secret Name | Value | How to Get It |
   |-------------|-------|---------------|
   | `KEYSTORE_BASE64` | Base64 of keystore file | Run command below |
   | `KEYSTORE_PASSWORD` | Your keystore password | Password from when you created keystore |
   | `KEY_PASSWORD` | Your key password | Usually same as keystore password |
   | `KEY_ALIAS` | `R3AP3Redit` | The alias you used |

#### 🔐 Generate KEYSTORE_BASE64

**On Linux/macOS**:
```bash
base64 -i android/app/xibe-chat-app.jks | tr -d '\n'
```

**On Windows (PowerShell)**:
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("android\app\xibe-chat-app.jks")) | Set-Clipboard
```

Then paste the output as the `KEYSTORE_BASE64` secret value.

### 3️⃣ Verify It Works

After adding secrets, run your GitHub Actions workflow:
- Go to **Actions** tab
- Select **Multi-Platform Build and Release** workflow
- Click **Run workflow**
- Check the logs for "✅ Release signing configured"

## 📋 Your Keystore Information

Based on the keystore you created:

- **Keystore File**: `android/app/xibe-chat-app.jks`
- **Key Alias**: `R3AP3Redit`
- **Algorithm**: RSA 2048-bit
- **Validity**: 10,000 days (~27 years)
- **Organization**: R3AP3Redit
- **Location**: Karnataka, India

## ⚠️ Important Security Notes

✅ **DO**:
- Keep your keystore password secure
- Back up your keystore file (encrypted)
- Use GitHub Secrets for CI/CD
- Keep `key.properties` local (it's gitignored)

❌ **DON'T**:
- Commit keystore files to Git (they're gitignored)
- Commit `key.properties` to Git (it's gitignored)
- Share your passwords publicly
- Lose your keystore (you can't update the app without it!)

## 📚 More Information

- **Detailed GitHub Actions Setup**: See [GITHUB_ACTIONS_SECRETS.md](GITHUB_ACTIONS_SECRETS.md)
- **Full Signing Guide**: See [SIGNING.md](SIGNING.md)
- **Build Instructions**: See [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md)

## 🚀 Quick Test

Test that your keystore works:

```bash
# Verify keystore exists
ls -l android/app/xibe-chat-app.jks

# Check keystore details
keytool -list -v -keystore android/app/xibe-chat-app.jks -alias R3AP3Redit

# Build signed APK (after creating key.properties)
flutter build apk --release

# Verify APK is signed
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk
```

## 🔧 Troubleshooting

### "No such file: key.properties"
- This is expected if you haven't created it yet
- The app will use debug signing instead
- For production, create `key.properties` as shown above

### "Wrong password"
- Double-check your `KEYSTORE_PASSWORD` and `KEY_PASSWORD`
- They should match what you entered when creating the keystore

### GitHub Actions fails to sign
- Verify all 4 secrets are added correctly
- Check the base64 encoding has no line breaks
- See [GITHUB_ACTIONS_SECRETS.md](GITHUB_ACTIONS_SECRETS.md) for detailed troubleshooting

## ✨ Summary

Your keystore is **ready to use**! You just need to:

1. Add the 4 secrets to GitHub (for automated builds)
2. Or create `key.properties` locally (for local builds)

That's it! Your Android releases will be properly signed. 🎉
