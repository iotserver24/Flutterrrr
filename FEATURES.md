# Xibe Chat - New Features Guide

## 🎨 Multiple Themes

Xibe Chat now offers 5 beautiful themes to customize your experience:

### Available Themes
1. **Dark Theme** (Default) - Classic dark mode with blue accents
2. **Light Theme** - Clean and bright interface
3. **Blue Ocean Theme** - Deep blue color scheme inspired by the ocean
4. **Purple Galaxy Theme** - Rich purple tones for a cosmic feel
5. **Forest Green Theme** - Soothing green colors inspired by nature

### How to Change Theme
1. Open the app
2. Navigate to Settings (☰ menu → Settings icon)
3. Under "Appearance" section, tap on "Theme"
4. Select your preferred theme from the dialog
5. The theme changes instantly!

---

## 🌐 Web Search Toggle

Enable web search to allow the AI to access real-time information from the internet.

### Using Web Search
1. Look for the search icon (🔍) next to the message input
2. Tap the icon to toggle web search on/off
3. When enabled, the icon turns blue
4. Messages sent with web search enabled will show a "🌐 Web Search" badge

**Note:** Web search availability depends on the selected AI model.

---

## ⚙️ Advanced AI Settings

Fine-tune AI responses with advanced parameters:

### Temperature (0.0 - 2.0)
- **Lower values** (0.0 - 0.7): More focused and deterministic responses
- **Higher values** (0.8 - 2.0): More creative and diverse responses
- **Default:** 0.7

### Max Tokens (256 - 8192)
- Controls the maximum length of AI responses
- Higher values allow longer responses but use more resources
- **Default:** 2048

### Top P (0.0 - 1.0)
- Nucleus sampling parameter
- Lower values make output more focused
- **Default:** 1.0

### Frequency Penalty (0.0 - 2.0)
- Reduces repetition in responses
- Higher values discourage repeating the same phrases
- **Default:** 0.0

### Presence Penalty (0.0 - 2.0)
- Encourages the model to talk about new topics
- Higher values make the AI more likely to introduce new subjects
- **Default:** 0.0

### How to Adjust Settings
1. Go to Settings
2. Scroll to "Advanced AI Settings"
3. Use the sliders to adjust each parameter
4. Changes apply immediately to new conversations

---

## 🧠 Thinking Indicator

See what the AI is thinking before it responds!

### Features
- Visual "thinking" animation while AI processes your message
- Shows reasoning steps for complex queries (when available)
- Thinking content appears in a blue highlighted box within the message

This feature helps you understand the AI's reasoning process and provides transparency in how responses are generated.

---

## 💻 E2B Code Execution (Sandbox)

Execute Python code securely in isolated sandboxes powered by E2B.

### Setup
1. Get your E2B API key from [https://e2b.dev](https://e2b.dev)
2. Open Settings
3. Find "E2B API Key" under "API Configuration"
4. Enter your API key and save
5. The status will show "Configured" under Integrations

### What You Can Do
- Run Python code snippets safely
- Execute data analysis tasks
- Generate visualizations
- Test code without local setup
- All executions run in isolated sandboxes (~150ms startup)

### Features
- **File Operations**: Upload, read, write, and delete files
- **Package Installation**: Install pip packages on-demand
- **Code Execution**: Run Python scripts with full output
- **Streaming Support**: Real-time stdout/stderr
- **Security**: Sandboxed VMs isolated from your infrastructure

**Note:** E2B integration provides secure code execution similar to ChatGPT's code interpreter.

---

## 🔌 MCP Servers (Model Context Protocol)

Connect to MCP servers to extend AI capabilities with custom tools and context.

### What are MCP Servers?
MCP (Model Context Protocol) servers provide:
- Additional context for AI models
- Custom tools and functions
- Integration with external services
- Extended capabilities beyond base models

### Managing MCP Servers
1. Go to Settings
2. Tap "MCP Servers" under "Integrations"
3. Tap the "+" button to add a new server

### Adding a Server
1. **Server Name**: Give it a descriptive name
2. **Server URL**: Enter the MCP server endpoint
3. **API Key**: Add authentication key (if required)
4. **Description**: Note what the server provides

### Server Controls
- **Enable/Disable**: Toggle server on/off without deleting
- **Edit**: Update server details
- **Delete**: Remove server from configuration

**Status Indicator:**
- 🟢 Green circle: Server is enabled and active
- ⚫ Gray circle: Server is disabled

---

## 📸 Enhanced Image Upload

Improved image handling with multiple input methods.

### Upload Methods
1. **From Gallery**: Choose existing photos from your device
2. **Camera**: Take a new photo directly

### How to Use
1. Tap the image icon (📷) next to the message input
2. Choose your upload method:
   - "Choose from gallery" - Select from existing photos
   - "Take a photo" - Use device camera
3. Image appears as a preview below the input
4. Add your message and send

### Supported Features
- Image preview before sending
- Remove uploaded image before sending
- Works with vision-enabled AI models
- Automatic base64 encoding for API compatibility

### Vision-Enabled Models
Look for models that support image input:
- GPT-4 Vision
- Gemini Pro Vision
- Claude 3 models
- And more!

---

## 🎯 Additional Features

### Smart Greetings
- Time-based greetings (Good morning/afternoon/evening)
- Personalized welcome messages

### Message Management
- Copy any message with one tap
- Timestamps on all messages
- Smooth animations and transitions

### Chat History
- All conversations saved locally
- Quick chat switching
- Delete individual chats or all history

### Model Selection
- Easy switching between AI models
- Model descriptions and capabilities
- Visual indicator for active model

---

## 🔒 Privacy & Security

### Local Storage
- All chat history stored locally on your device
- No cloud synchronization unless explicitly configured
- Full control over your data

### API Keys
- Stored securely on device
- Never shared or transmitted to third parties
- Optional - use default configuration if preferred

### E2B Sandboxes
- Code executes in isolated VMs
- Sandboxes are temporary and destroyed after use
- No access to your local files or data

---

## 💡 Tips & Best Practices

### Getting the Best Results
1. **Use Clear Prompts**: Be specific about what you want
2. **Adjust Temperature**: Lower for factual, higher for creative tasks
3. **Enable Web Search**: For current information and facts
4. **Try Different Models**: Each has unique strengths
5. **Use Vision Models**: For image analysis and visual questions

### Performance Tips
- Reduce max tokens for faster responses
- Disable web search when not needed
- Close unused MCP server connections
- Clear old chats to free up storage

### Troubleshooting
- **API Errors**: Check your API key in settings
- **E2B Errors**: Verify E2B API key is configured
- **Image Upload Issues**: Ensure vision model is selected
- **Slow Responses**: Try a different model or reduce max tokens

---

## 📱 Platform Support

Xibe Chat runs on:
- ✅ Android (5.0+)
- ✅ iOS (11.0+)
- ✅ Windows (10/11)
- ✅ macOS (10.14+)
- ✅ Linux (Ubuntu 20.04+)

All features are available across all platforms!

---

## 🆘 Support

For issues, questions, or feature requests:
- GitHub Issues: [Report a bug](https://github.com/iotserver24/Xibe-chat-app/issues)
- Documentation: Check README.md for setup instructions

---

## 🚀 Coming Soon

Features planned for future releases:
- Document upload support (PDF, DOCX, TXT)
- Voice input and output
- Chat export functionality
- Custom MCP server creation tools
- More AI model integrations
- Conversation templates
- Collaborative chat features

Stay tuned for updates!
