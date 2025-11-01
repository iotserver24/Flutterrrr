# 🚀 Setup GitHub Secrets NOW

## 📍 You Need These URLs

### Base64 Keystore (for KEYSTORE_BASE64 secret)
```
https://github.com/iotserver24/Flutterrrr/raw/copilot/decode-save-keystore/keystore_base64_clean.txt
```

**Quick copy command:**
```bash
curl -s https://github.com/iotserver24/Flutterrrr/raw/copilot/decode-save-keystore/keystore_base64_clean.txt
```

---

## 🎯 3 Simple Steps

### 1️⃣ Go to GitHub Secrets
Open in your browser:
```
https://github.com/iotserver24/Flutterrrr/settings/secrets/actions
```

### 2️⃣ Click "New repository secret" and add 4 secrets:

#### Secret #1: KEYSTORE_BASE64
- **Name:** `KEYSTORE_BASE64`
- **Value:** Copy from: https://github.com/iotserver24/Flutterrrr/raw/copilot/decode-save-keystore/keystore_base64_clean.txt
- Click the URL, copy ALL the text (one long line, 3720 characters)

#### Secret #2: KEYSTORE_PASSWORD
- **Name:** `KEYSTORE_PASSWORD`
- **Value:** Get from your `android/key.properties` file (the `storePassword` line)

#### Secret #3: KEY_PASSWORD
- **Name:** `KEY_PASSWORD`
- **Value:** Get from your `android/key.properties` file (the `keyPassword` line)

#### Secret #4: KEY_ALIAS
- **Name:** `KEY_ALIAS`
- **Value:** Get from your `android/key.properties` file (the `keyAlias` line)

### 3️⃣ Run the Workflow
```
https://github.com/iotserver24/Flutterrrr/actions/workflows/build-release.yml
```
1. Click "Run workflow"
2. Enter version (e.g., `1.0.0`) and build number (e.g., `1`)
3. Click "Run workflow"

---

## 📋 Quick Checklist

- [ ] Open GitHub Secrets page
- [ ] Add `KEYSTORE_BASE64` (from the URL above)
- [ ] Add `KEYSTORE_PASSWORD` (from your key.properties)
- [ ] Add `KEY_PASSWORD` (from your key.properties)
- [ ] Add `KEY_ALIAS` (from your key.properties)
- [ ] Run the workflow
- [ ] Check for "✅ Release signing configured" in logs

---

## 🔗 All Important Links

| Link | Purpose |
|------|---------|
| [Base64 Download](https://github.com/iotserver24/Flutterrrr/raw/copilot/decode-save-keystore/keystore_base64_clean.txt) | Get KEYSTORE_BASE64 value |
| [GitHub Secrets](https://github.com/iotserver24/Flutterrrr/settings/secrets/actions) | Add secrets here |
| [Run Workflow](https://github.com/iotserver24/Flutterrrr/actions/workflows/build-release.yml) | Start the build |
| [Setup Guide](GITHUB_SECRET_SETUP.md) | Detailed instructions |

---

## 💡 Pro Tip

Get all your values at once:
```bash
# Get base64
echo "=== KEYSTORE_BASE64 ==="
curl -s https://github.com/iotserver24/Flutterrrr/raw/copilot/decode-save-keystore/keystore_base64_clean.txt

# Get passwords
echo ""
echo "=== YOUR PASSWORDS ==="
cat android/key.properties
```

Then copy-paste each value into GitHub Secrets!

---

## ✅ How to Know It Worked

After running the workflow, look for these in the logs:
- ✅ "Release signing configured"
- 📦 "Keystore size: 2790 bytes"

If you see these, congratulations! Your Android builds are now signed! 🎉

---

## 🆘 Quick Help

**Problem:** "base64: invalid input"
**Solution:** Make sure you copied the ENTIRE base64 string (3720 chars)

**Problem:** "Wrong password"
**Solution:** Check your `android/key.properties` file for the correct passwords

**Problem:** Can't find key.properties
**Solution:** Run: `cat android/key.properties` in your project directory

---

**Ready?** Start here: https://github.com/iotserver24/Flutterrrr/settings/secrets/actions
