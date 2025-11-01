# 🔑 GitHub Secrets Setup Guide

## Quick Links

### Base64 Keystore URL
**Direct Download:** https://github.com/iotserver24/Flutterrrr/raw/copilot/decode-save-keystore/keystore_base64_clean.txt

**View on GitHub:** https://github.com/iotserver24/Flutterrrr/blob/copilot/decode-save-keystore/keystore_base64_clean.txt

## 📋 Step-by-Step Setup

### Step 1: Get the Base64 String

**Option A: Download directly**
```bash
curl -s https://github.com/iotserver24/Flutterrrr/raw/copilot/decode-save-keystore/keystore_base64_clean.txt
```

**Option B: From repository file**
1. Open: https://github.com/iotserver24/Flutterrrr/blob/copilot/decode-save-keystore/keystore_base64_clean.txt
2. Click "Raw" button
3. Copy the entire content (it's one long line)

**Option C: From local file**
```bash
cat keystore_base64_clean.txt
```

### Step 2: Get Your Passwords

Check your `android/key.properties` file:
```bash
cat android/key.properties
```

You'll see something like:
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=YOUR_KEY_ALIAS
storeFile=xibe-chat-app.jks
```

### Step 3: Add GitHub Secrets

Go to: **Your Repository** → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Add these 4 secrets:

#### 1. KEYSTORE_BASE64
- **Name:** `KEYSTORE_BASE64`
- **Value:** Paste the entire base64 string from Step 1
- **Source:** https://github.com/iotserver24/Flutterrrr/raw/copilot/decode-save-keystore/keystore_base64_clean.txt

#### 2. KEYSTORE_PASSWORD
- **Name:** `KEYSTORE_PASSWORD`
- **Value:** The `storePassword` value from your `android/key.properties`
- **Example:** If your file says `storePassword=myPassword123`, enter `myPassword123`

#### 3. KEY_PASSWORD
- **Name:** `KEY_PASSWORD`
- **Value:** The `keyPassword` value from your `android/key.properties`
- **Example:** If your file says `keyPassword=myPassword123`, enter `myPassword123`
- **Note:** Usually the same as KEYSTORE_PASSWORD

#### 4. KEY_ALIAS
- **Name:** `KEY_ALIAS`
- **Value:** The `keyAlias` value from your `android/key.properties`
- **Example:** If your file says `keyAlias=xibe_chat_key`, enter `xibe_chat_key`

## ✅ Verification

After adding all 4 secrets:

1. Go to **Actions** tab
2. Click **Multi-Platform Build and Release**
3. Click **Run workflow**
4. Enter:
   - Version: `1.0.0`
   - Build number: `1`
5. Click **Run workflow**

Look for in the logs:
- ✅ "Release signing configured"
- 📦 "Keystore size: 2790 bytes"

## 🔍 Quick Command to Get Everything

Run this on your local machine:
```bash
echo "=== KEYSTORE_BASE64 ==="
cat keystore_base64_clean.txt

echo ""
echo "=== YOUR PASSWORDS ==="
cat android/key.properties

echo ""
echo "=== Copy these values to GitHub Secrets ==="
echo "1. KEYSTORE_BASE64 = (the long string above)"
echo "2. KEYSTORE_PASSWORD = (from key.properties)"
echo "3. KEY_PASSWORD = (from key.properties)"
echo "4. KEY_ALIAS = (from key.properties)"
```

Or download the base64 directly:
```bash
curl -s https://github.com/iotserver24/Flutterrrr/raw/copilot/decode-save-keystore/keystore_base64_clean.txt
```

## 🎯 Summary

| Secret Name | Where to Get It |
|-------------|-----------------|
| `KEYSTORE_BASE64` | [Download URL](https://github.com/iotserver24/Flutterrrr/raw/copilot/decode-save-keystore/keystore_base64_clean.txt) |
| `KEYSTORE_PASSWORD` | From `android/key.properties` file |
| `KEY_PASSWORD` | From `android/key.properties` file |
| `KEY_ALIAS` | From `android/key.properties` file |

## 📝 Notes

- The base64 string is **3720 characters** long (one continuous line)
- Do NOT add spaces or newlines when pasting
- Make sure you copy the ENTIRE string
- The keystore file size should be **2790 bytes** when decoded

## 🆘 Troubleshooting

### "base64: invalid input"
- Make sure you copied the entire base64 string
- No extra spaces or newlines at the beginning or end
- Try downloading directly with curl instead of copy-paste

### "Wrong password"
- Double-check the passwords in `android/key.properties`
- Make sure there are no extra spaces
- Passwords are case-sensitive

### "Keystore not found"
- Verify `KEYSTORE_BASE64` secret is set
- The base64 should be exactly 3720 characters

## 🔗 Additional Resources

- [QUICK_START.md](QUICK_START.md) - Quick start guide
- [FIX_SUMMARY.md](FIX_SUMMARY.md) - What was fixed
- [KEYSTORE_BASE64_INSTRUCTIONS.md](KEYSTORE_BASE64_INSTRUCTIONS.md) - Detailed instructions

---

**Need the base64?** https://github.com/iotserver24/Flutterrrr/raw/copilot/decode-save-keystore/keystore_base64_clean.txt
