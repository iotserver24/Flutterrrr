# Build Xibe Chat - Flutter AI Chat App

Create a complete ChatGPT-style AI chat application called "Xibe Chat" using Flutter.

---

## App Specification

**Name:** Xibe Chat  
**Platform:** Android  
**Framework:** Flutter  
**Style:** Modern dark-themed chat app (like ChatGPT mobile)

---

## Core Features

### Chat Interface
- Clean chat bubbles (user messages right, AI left)
- Auto-scroll to latest message
- Markdown rendering (code blocks, bold, lists, links)
- Copy message on long-press
- Typing indicator animation while AI responds
- Timestamp on each message
- "🌐 Web Search" badge when AI used web search

### Chat Management
- Multiple conversation threads
- Chat history drawer/sidebar
- Create new chat button
- Delete chats
- Auto-save all chats locally

### Input Area
- Multi-line text input (expands as user types)
- Send button (disabled when empty)
- Microphone button for voice input (optional)

### Settings
- Dark/Light theme toggle (default dark)
- AI model selection
- Clear all chats
- About section with version

### Backend Integration
- API endpoint: `http://my-vps-ip:3000/api/chat`
- Request format:
  ```json
  {
    "message": "user message",
    "history": [{"role": "user", "content": "..."}, {"role": "assistant", "content": "..."}],
    "enable_web_search": true
  }
  ```
- Response format:
  ```json
  {
    "response": "AI message",
    "web_search_used": false
  }
  ```
- Show error messages for network/API failures with retry button

---

## UI Design

**Color Scheme (Dark Mode):**
- Background: `#0D0D0D`
- User bubble: `#2563EB` (blue)
- AI bubble: `#1F1F1F`
- Text: `#FFFFFF`
- Input area: `#1A1A1A`
- Accent: `#3B82F6`

**Layout:**
```
┌──────────────────────────────┐
│ ☰  Xibe Chat          ⋮     │ ← App bar
├──────────────────────────────┤
│                              │
│ 🤖 Hi! How can I help?      │ ← AI message
│    [📋]                      │
│                              │
│        What's 2+2?  👤       │ ← User message
│                              │
│ 🤖 2+2 equals 4.             │
│    [📋]                      │
│                              │
├──────────────────────────────┤
│ Type a message...      [🎤]  │ ← Input
│                         [➤]  │
└──────────────────────────────┘
```

---

## Technical Stack

**Dependencies (pubspec.yaml):**
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  provider: ^6.1.0
  sqflite: ^2.3.0
  path_provider: ^2.1.0
  shared_preferences: ^2.2.0
  flutter_markdown: ^0.6.0
  intl: ^0.18.0
```

**State Management:** Provider

**Local Storage:** 
- sqflite for chat history
- shared_preferences for settings

---

## File Structure

```
lib/
├── main.dart
├── screens/
│   ├── chat_screen.dart
│   ├── settings_screen.dart
├── widgets/
│   ├── message_bubble.dart
│   ├── chat_input.dart
│   ├── typing_indicator.dart
│   ├── chat_drawer.dart
├── models/
│   ├── message.dart
│   ├── chat.dart
├── services/
│   ├── api_service.dart
│   ├── database_service.dart
├── providers/
│   ├── chat_provider.dart
│   ├── theme_provider.dart
```

---

## Implementation Requirements

### 1. Main App (main.dart)
- Setup Provider
- Initialize database
- Load theme preference
- Setup MaterialApp with theme

### 2. Chat Screen
- ListView for messages
- Scroll to bottom on new message
- Show typing indicator while loading
- Handle message sending
- Error handling with retry

### 3. Message Bubble Widget
- Different styles for user/AI
- Markdown rendering
- Copy button
- Web search badge if applicable
- Timestamp

### 4. API Service
- POST request to backend
- Error handling
- Timeout handling
- Return parsed response


build the app and then push to releases




