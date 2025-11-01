# Memory Save Feature Documentation

## Overview
The AI chat application now supports visible memory saving using XML-style tags. When the AI learns important information about the user, it can save it to long-term memory with user feedback.

## How It Works

### For AI Responses
The AI is instructed through the system prompt to use the following format when it wants to save important information:

```
<save memory>brief important fact about user</save memory>
```

### Example Usage

**User says:** "I'm a Python developer working on ML projects"

**AI can respond:** "That's great! I'd love to help with your ML projects. <save memory>Python developer specializing in ML projects</save memory>"

**What the user sees:** "That's great! I'd love to help with your ML projects. ✅ *Memory saved: "Python developer specializing in ML projects"*"

### Technical Implementation

1. **System Prompt Update**: The AI receives instructions to use `<save memory>` tags when it learns significant information
2. **Tag Detection**: After streaming completes, the response is scanned for `<save memory>...</save memory>` tags using regex
3. **Memory Extraction**: Content within the tags is extracted and saved to the database
4. **Visual Confirmation**: The tag is replaced with a confirmation message: `✅ *Memory saved: "extracted content"*`
5. **Database Storage**: The memory is stored in the SQLite database through the `SettingsProvider` callback

### Memory Constraints
- **Single memory limit**: 200 characters maximum
- **Total memory limit**: 1000 characters across all memories
- Memories persist across sessions and are included in the system prompt for all future conversations

### Key Changes Made

1. **chat_provider.dart**:
   - Updated `memoryInstruction` to use XML-style tags instead of JSON format
   - Modified memory extraction regex pattern from JSON to XML tags
   - Added visible confirmation message that replaces the tag in the response
   - Updated first message instruction to clarify memory tag usage

### Benefits
- **Transparency**: Users can see when the AI saves information about them
- **Confirmation**: Users receive immediate feedback that memory was saved
- **Flexibility**: AI can save memory at any point in the conversation, not just at the end
- **Readability**: XML-style tags are more intuitive than JSON for this use case
