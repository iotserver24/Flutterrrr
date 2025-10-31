# GitHub Actions Workflow Usage Guide

## Overview

The updated GitHub Actions workflow allows you to build and release the Xibe Chat application for multiple platforms with custom version and build numbers.

## How to Run the Workflow

### 1. Navigate to GitHub Actions

1. Go to your repository: https://github.com/iotserver24/Flutterrrr
2. Click on the "Actions" tab
3. Select "Build and Release" workflow from the left sidebar
4. Click "Run workflow" button (top right)

### 2. Provide Required Inputs

When you click "Run workflow", you'll be prompted to enter:

- **Version number**: Semantic version (e.g., `1.0.0`, `2.1.3`)
- **Build number**: Integer build number (e.g., `1`, `2`, `100`)

Example:
- Version: `1.0.0`
- Build number: `1`
- This will create a release tagged as `v1.0.0-1`

### 3. Workflow Execution

The workflow will:

1. **Build Android APK** (on Ubuntu)
   - Universal APK compatible with all Android devices
   - File: `xibe-chat-v{version}-{build_number}.apk`

2. **Build Windows Applications** (on Windows)
   - Windows EXE executable with dependencies
   - Windows MSIX installer package with self-signed certificate
   - Files: 
     - `xibe-chat-windows-v{version}-{build_number}.zip` (contains EXE and dependencies)
     - `xibe-chat-v{version}-{build_number}.msix`

3. **Create GitHub Release**
   - Creates a git tag: `v{version}-{build_number}`
   - Creates a GitHub release with all built artifacts
   - Automatically deletes workflow artifacts after upload

## What Gets Built

### Android
- **Universal APK**: Single APK that works on all Android devices (ARM, ARM64, x86, x86_64)
- File format: Not zipped, uploaded directly

### Windows
- **EXE**: Standalone executable with all dependencies
  - Zipped for convenient download
  - Users extract and run `xibe_chat.exe`
- **MSIX**: Modern Windows installer package
  - Signed with self-signed certificate
  - Provides cleaner installation experience
  - Users may need to trust the certificate first

## Release Tag Format

Releases are tagged as: `v{version}-{build_number}`

Examples:
- `v1.0.0-1` (Version 1.0.0, Build 1)
- `v1.0.1-2` (Version 1.0.1, Build 2)
- `v2.0.0-15` (Version 2.0.0, Build 15)

## Artifact Cleanup

After the release is created and all files are uploaded, the workflow automatically:
1. Deletes the intermediate build artifacts from GitHub Actions
2. Keeps only the release files publicly available

This saves storage space and keeps your Actions clean.

## Download Links

Once the workflow completes, users can download the builds from:

```
https://github.com/iotserver24/Flutterrrr/releases/tag/v{version}-{build_number}
```

Example: `https://github.com/iotserver24/Flutterrrr/releases/tag/v1.0.0-1`

## Installation Instructions

### Android APK
1. Download the APK file from the release
2. Enable "Install from Unknown Sources" in Android settings
3. Open the APK file to install

### Windows EXE (Portable)
1. Download the ZIP file
2. Extract to any folder
3. Run `xibe_chat.exe`

### Windows MSIX (Installer)
1. Download the MSIX file
2. Double-click to install
3. First-time: Trust the self-signed certificate when prompted
4. The app will be installed like a store app

## Troubleshooting

### Workflow Fails to Start
- Check that you're on the correct branch
- Ensure you have necessary permissions

### Build Failures
- Check the workflow logs in the Actions tab
- Common issues:
  - Flutter version compatibility
  - Missing dependencies
  - Platform-specific build errors

### Certificate Issues (Windows MSIX)
- The MSIX is signed with a self-signed certificate
- Users may need to manually trust the certificate
- For production, consider using a proper code signing certificate

## Version Management

### Semantic Versioning
- **Major** (X.0.0): Breaking changes
- **Minor** (1.X.0): New features, backward compatible
- **Patch** (1.0.X): Bug fixes

### Build Numbers
- Increment for each build of the same version
- Useful for testing and beta releases
- Example: v1.0.0-1, v1.0.0-2, v1.0.0-3

## Best Practices

1. **Test locally first**: Build and test on your machine before running the workflow
2. **Use meaningful versions**: Follow semantic versioning
3. **Increment build numbers**: For each new build attempt
4. **Document changes**: Update release notes in the workflow or manually
5. **Keep workflow updated**: Update Flutter version as needed

## Customization

To modify the workflow:

1. Edit `.github/workflows/build-release.yml`
2. Update version numbers, build configurations, or release notes
3. Test changes with workflow dispatch

To change app configuration:

1. Edit `pubspec.yaml` for package settings
2. Edit `msix_config` section for Windows MSIX settings
3. Commit and push changes before running workflow

## Notes

- The workflow requires GitHub Actions to be enabled
- Builds run in parallel for faster completion
- Each platform (Android, Windows) builds independently
- Self-signed certificates are generated fresh for each build
- The workflow is triggered manually via workflow_dispatch (not on tags or pushes)
