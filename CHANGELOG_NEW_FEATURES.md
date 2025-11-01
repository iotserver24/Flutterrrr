# Changelog - New Features Release

## Version 1.1.0 - UI/UX Enhancement Update

### 🎨 New Themes
Added 5 beautiful themes to customize your experience:
- **Dark Theme** - Classic dark mode (default)
- **Light Theme** - Clean bright interface
- **Blue Ocean Theme** - Deep blue color scheme
- **Purple Galaxy Theme** - Rich purple cosmic theme
- **Forest Green Theme** - Soothing nature-inspired green

**How to use:** Settings → Appearance → Theme

---

### 🌐 Web Search Integration
- Added web search toggle button in chat input
- Visual indicator when web search is enabled
- Messages show "🌐 Web Search" badge when search was used
- Seamless integration with AI responses

**How to use:** Tap the search icon (🔍) next to the message input

---

### ⚙️ Advanced AI Controls
Fine-tune AI behavior with professional-grade parameters:
- **Temperature** (0.0-2.0): Control response creativity
- **Max Tokens** (256-8192): Set response length limits
- **Top P** (0.0-1.0): Nucleus sampling for diversity
- **Frequency Penalty** (0.0-2.0): Reduce repetition
- **Presence Penalty** (0.0-2.0): Encourage new topics

**How to use:** Settings → Advanced AI Settings

---

### 🧠 Thinking Indicator
See the AI's thought process:
- Animated thinking indicator while processing
- Visual display of reasoning steps
- Highlighted thinking content in messages
- Better transparency in AI responses

---

### 💻 E2B Code Execution
Integrated E2B sandbox for secure code execution:
- Run Python code in isolated sandboxes
- File upload and management
- Package installation support
- Streaming output support
- ~150ms sandbox startup time

**Setup:** Get API key from [e2b.dev](https://e2b.dev) and add in Settings → API Configuration

**Features:**
- Execute Python scripts safely
- Data analysis and visualization
- Package installation (pip)
- File operations (read/write)
- Secure isolated environment

---

### 🔌 MCP Server Management
Model Context Protocol (MCP) integration:
- Add custom MCP servers
- Enable/disable servers on-the-fly
- API key authentication support
- Server status indicators
- Full CRUD operations

**How to use:** Settings → Integrations → MCP Servers

**Benefits:**
- Extend AI capabilities
- Custom tools and functions
- External service integration
- Enhanced context provision

---

### 📸 Enhanced Image Upload
Improved image handling:
- Multiple upload methods (gallery/camera)
- Image preview before sending
- Option to remove uploaded images
- Better error handling
- Supports all vision-enabled models

**How to use:** Tap the photo icon and choose upload method

---

### 🎯 UI/UX Improvements
General interface enhancements:
- Smoother animations and transitions
- Better message bubble styling
- Improved gradient effects
- Enhanced visual feedback
- Cleaner settings organization
- Better theme consistency

---

### 📱 Cross-Platform Support
All features work seamlessly across:
- Android (5.0+)
- iOS (11.0+)
- Windows (10/11)
- macOS (10.14+)
- Linux (Ubuntu 20.04+)

---

## Technical Changes

### New Files Added
- `lib/services/e2b_service.dart` - E2B API integration
- `lib/models/mcp_server.dart` - MCP server model
- `lib/screens/mcp_servers_screen.dart` - MCP management UI
- `lib/widgets/thinking_indicator.dart` - Thinking animation widget
- `FEATURES.md` - Comprehensive features documentation

### Updated Files
- `lib/providers/theme_provider.dart` - Multi-theme support
- `lib/providers/settings_provider.dart` - Advanced settings storage
- `lib/providers/chat_provider.dart` - Web search support
- `lib/models/message.dart` - Thinking content support
- `lib/screens/settings_screen.dart` - New settings sections
- `lib/screens/chat_screen.dart` - Web search parameter
- `lib/widgets/chat_input.dart` - Web search toggle, camera support
- `lib/widgets/message_bubble.dart` - Thinking content display

---

## API Compatibility

### E2B Integration
- Base URL: `https://api.e2b.dev`
- Authentication: X-API-Key header
- Sandboxes: Create, execute, close operations
- File system: Read, write, list operations
- Package management: pip, npm support

### MCP Protocol Support
- Model Context Protocol compliant
- RESTful API integration
- Optional authentication
- Server enable/disable states

---

## Configuration

### New Settings
```yaml
# Theme
appTheme: dark|light|blue|purple|green (default: dark)

# AI Parameters
temperature: 0.7 (0.0-2.0)
max_tokens: 2048 (256-8192)
top_p: 1.0 (0.0-1.0)
frequency_penalty: 0.0 (0.0-2.0)
presence_penalty: 0.0 (0.0-2.0)

# API Keys
e2b_api_key: (optional)
```

### Storage
- Themes: SharedPreferences
- AI Settings: SharedPreferences
- MCP Servers: SQLite (planned)
- Chat History: SQLite (existing)

---

## Migration Notes

### From v1.0.x to v1.1.0
- All existing chats preserved
- Settings automatically migrated
- Default theme: Dark (matches previous behavior)
- Default AI parameters: Standard values
- No breaking changes

### Database Changes
- Added `thinkingContent` column to messages table
- Added `isThinking` column to messages table
- Backward compatible schema

---

## Known Issues & Limitations

### E2B Service
- Requires active internet connection
- API key must be obtained from e2b.dev
- Sandbox execution time limited by E2B plan
- File size limits apply

### MCP Servers
- Server management UI is basic (v1.0)
- Database persistence pending
- No server health monitoring yet

### Web Search
- Availability depends on selected model
- May increase response time
- Subject to API rate limits

---

## Future Enhancements

### Planned for v1.2.0
- Document upload (PDF, DOCX, TXT)
- Voice input/output
- Chat export functionality
- Enhanced MCP server features
- Custom server templates
- Performance optimizations

### Under Consideration
- Collaborative chat
- Conversation templates
- Plugin system
- Advanced analytics
- Cloud sync (optional)

---

## Breaking Changes
None - This release is fully backward compatible with v1.0.x

---

## Credits
- E2B Integration: Based on E2B API documentation
- MCP Protocol: Following Model Context Protocol specification
- UI Design: Inspired by modern chat applications
- Icons: Flutter Material Icons

---

## Support & Documentation
- Full Documentation: `FEATURES.md`
- Build Instructions: `BUILD_INSTRUCTIONS.md`
- Setup Guide: `README.md`
- Issue Tracker: GitHub Issues

---

## Feedback
We'd love to hear your thoughts on these new features! Please:
- Report bugs via GitHub Issues
- Suggest improvements via Pull Requests
- Share your experience in Discussions

---

**Release Date:** 2025-11-01
**Version:** 1.1.0
**Build:** TBD
