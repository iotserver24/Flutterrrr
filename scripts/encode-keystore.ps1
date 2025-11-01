# PowerShell script to encode keystore file to base64 for GitHub Actions
# Usage: .\scripts\encode-keystore.ps1

$KeystorePath = "android\app\xibe-chat-app.jks"

Write-Host "🔐 Android Keystore Encoder for GitHub Actions" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check if keystore exists
if (-not (Test-Path $KeystorePath)) {
    Write-Host "❌ Error: Keystore file not found at $KeystorePath" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Found keystore: $KeystorePath" -ForegroundColor Green
Write-Host ""

# Encode to base64
Write-Host "📦 Encoding keystore to base64..." -ForegroundColor Yellow
$KeystoreBytes = [System.IO.File]::ReadAllBytes($KeystorePath)
$Base64String = [Convert]::ToBase64String($KeystoreBytes)

Write-Host "✅ Encoding complete!" -ForegroundColor Green
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "🎯 Add this as KEYSTORE_BASE64 secret in GitHub:" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host $Base64String -ForegroundColor White
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Yellow
Write-Host "1. Copy the base64 string above"
Write-Host "2. Go to GitHub → Settings → Secrets and variables → Actions"
Write-Host "3. Click 'New repository secret'"
Write-Host "4. Name: KEYSTORE_BASE64"
Write-Host "5. Value: Paste the base64 string"
Write-Host "6. Add the other 3 secrets: KEYSTORE_PASSWORD, KEY_PASSWORD, KEY_ALIAS"
Write-Host ""
Write-Host "For detailed instructions, see: GITHUB_ACTIONS_SECRETS.md" -ForegroundColor Cyan

# Copy to clipboard if possible
try {
    Set-Clipboard -Value $Base64String
    Write-Host ""
    Write-Host "✅ Base64 string has been copied to clipboard!" -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "⚠️  Could not copy to clipboard automatically. Please copy manually." -ForegroundColor Yellow
}
