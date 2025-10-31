# Release Process for Xibe Chat

## Automated Release via GitHub Actions

The repository is configured with GitHub Actions to automatically build and release the APK when a version tag is pushed.

### Steps to Create a Release

1. **Ensure all changes are committed and pushed**
   ```bash
   git status
   git add .
   git commit -m "Prepare for release v1.0.0"
   git push origin main
   ```

2. **Create and push a version tag**
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0 - Initial release"
   git push origin v1.0.0
   ```

3. **Monitor GitHub Actions**
   - Go to https://github.com/iotserver24/Flutterrrr/actions
   - Watch the "Build and Release APK" workflow
   - It will automatically:
     - Set up Flutter SDK
     - Install dependencies
     - Build the release APK
     - Create a GitHub release with the APK attached

4. **Release will be available at**
   - https://github.com/iotserver24/Flutterrrr/releases/tag/v1.0.0

## Manual Release Process

If GitHub Actions is not available or you prefer to build manually:

### Prerequisites

- Flutter SDK 3.0.0+ installed
- Android SDK installed
- Java 17+ installed

### Build Steps

1. **Navigate to project directory**
   ```bash
   cd /path/to/Flutterrrr
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Build release APK**
   ```bash
   flutter build apk --release
   ```

4. **APK location**
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

5. **Create GitHub Release**
   - Go to https://github.com/iotserver24/Flutterrrr/releases/new
   - Tag version: `v1.0.0`
   - Release title: `Xibe Chat v1.0.0`
   - Description: See template below
   - Upload the APK file
   - Publish release

### Release Description Template

```markdown
## Xibe Chat v1.0.0 - Initial Release

### Features

✨ **AI-Powered Chat Interface**
- Natural conversation with AI assistant
- Real-time responses
- Typing indicators

💬 **Multiple Conversation Threads**
- Create unlimited chat sessions
- Easy navigation between chats
- Auto-save all conversations

🌙 **Theme Support**
- Beautiful dark theme (default)
- Light theme option
- Smooth theme transitions

📝 **Rich Message Display**
- Markdown rendering for formatted text
- Code blocks with syntax highlighting
- Copy messages with one tap
- Timestamps for all messages

💾 **Local Storage**
- SQLite database for chat history
- No data sent to third parties
- Works offline (for viewing history)

🌐 **Web Search Integration**
- AI can search the web for current information
- Visual indicator when web search is used
- More accurate and up-to-date responses

### Installation

1. Download `app-release.apk` from the assets below
2. Enable "Install from Unknown Sources" in your Android settings
3. Open the downloaded APK file
4. Follow the installation prompts

### Configuration

The app connects to `http://my-vps:3000/api/chat` by default. To change this:
1. Edit `lib/services/api_service.dart`
2. Rebuild the app

### System Requirements

- Android 5.0 (API 21) or higher
- 50MB free space
- Internet connection for AI chat

### Known Issues

None at this time.

### Support

For issues or questions:
- GitHub Issues: https://github.com/iotserver24/Flutterrrr/issues
- Documentation: https://github.com/iotserver24/Flutterrrr/blob/main/README.md

### License

MIT License
```

## Version Numbering

Follow semantic versioning:
- **Major version** (1.x.x): Breaking changes
- **Minor version** (x.1.x): New features, backwards compatible
- **Patch version** (x.x.1): Bug fixes

Examples:
- `v1.0.0` - Initial release
- `v1.1.0` - Add new feature
- `v1.0.1` - Fix bug
- `v2.0.0` - Major redesign

## Testing Before Release

1. **Functionality testing**
   - Create new chat
   - Send messages
   - Receive responses
   - Switch between chats
   - Delete chats
   - Toggle theme
   - Copy messages

2. **Edge cases**
   - Network errors
   - Long messages
   - Special characters
   - Empty inputs

3. **Performance**
   - Smooth scrolling
   - Fast database operations
   - Responsive UI

## Post-Release

1. **Announce the release**
   - Update README with download link
   - Create announcement if needed

2. **Monitor for issues**
   - Check GitHub Issues
   - Monitor crash reports

3. **Plan next release**
   - Collect feedback
   - Prioritize features
   - Fix bugs
