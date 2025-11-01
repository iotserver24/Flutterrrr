# Test Checklist for New Features

## Prerequisites
- [ ] Flutter SDK installed and configured
- [ ] Dependencies installed (`flutter pub get`)
- [ ] App builds successfully

## 1. Windows Build Architecture Tests

### Test ARM64 Build in Workflow
- [ ] Navigate to Actions tab in GitHub
- [ ] Trigger "Multi-Platform Build and Release" workflow
- [ ] Verify workflow includes both x64 and arm64 builds
- [ ] Check build logs show both architectures
- [ ] Verify artifacts are created for both:
  - [ ] `xibe-chat-windows-x64-v*.zip`
  - [ ] `xibe-chat-windows-x64-v*.msix`
  - [ ] `xibe-chat-windows-arm64-v*.zip`
  - [ ] `xibe-chat-windows-arm64-v*.msix`

### Manual Test (if possible on ARM64 device)
- [ ] Download ARM64 build artifact
- [ ] Extract and run on ARM64 Windows device
- [ ] Verify app launches and functions correctly

## 2. Typing Animation Tests

### Basic Animation Test
- [ ] Launch the app
- [ ] Create a new chat or select existing chat
- [ ] Select any AI model
- [ ] Send a message to the AI
- [ ] **VERIFY**: Blinking cursor (█) appears at end of AI response while streaming
- [ ] **VERIFY**: Cursor blinks with smooth fade effect
- [ ] **VERIFY**: Cursor disappears when response is complete

### Multiple Messages Test
- [ ] Send multiple messages in succession
- [ ] **VERIFY**: Cursor animation works consistently for each response
- [ ] **VERIFY**: No cursor appears for user messages (only AI)

### Long Response Test
- [ ] Ask for a long response (e.g., "Write a detailed essay about AI")
- [ ] **VERIFY**: Cursor stays at the end as text streams in
- [ ] **VERIFY**: Cursor position updates as new lines are added

## 3. Image Support Tests

### Vision Model Detection
- [ ] Open the app
- [ ] Select a **non-vision** model (e.g., "deepseek", "mistral")
- [ ] **VERIFY**: NO image picker button (📷) appears
- [ ] Select a **vision** model (e.g., "gemini", "openai")
- [ ] **VERIFY**: Image picker button (📷) appears in chat input

### Vision-Capable Models to Test
Test with at least 3 of these models:
- [ ] gemini (Gemini 2.5 Flash Lite)
- [ ] gemini-search
- [ ] openai (GPT-5 Nano)
- [ ] openai-fast (GPT-4.1 Nano)
- [ ] openai-large (GPT-4.1)
- [ ] openai-reasoning (o4 Mini)
- [ ] bidara (NASA BIDARA)
- [ ] evil
- [ ] unity

### Image Selection Flow
- [ ] Select a vision-capable model
- [ ] Click the image picker button (📷)
- [ ] **VERIFY**: Gallery/file picker opens
- [ ] Select an image
- [ ] **VERIFY**: Image preview appears below input
- [ ] **VERIFY**: Preview shows thumbnail of selected image
- [ ] **VERIFY**: "X" button appears to remove image
- [ ] Click "X" button
- [ ] **VERIFY**: Image preview is removed
- [ ] Select image again for next tests

### Sending Messages with Images

#### Image Only
- [ ] Select an image (no text)
- [ ] **VERIFY**: Send button is enabled
- [ ] Send the message
- [ ] **VERIFY**: Message appears in chat with image
- [ ] **VERIFY**: Image is displayed above message text area
- [ ] **VERIFY**: AI responds to the image

#### Text Only (with vision model)
- [ ] Type a text message (no image)
- [ ] Send the message
- [ ] **VERIFY**: Works normally as before

#### Image + Text
- [ ] Select an image
- [ ] Type a message (e.g., "What do you see in this image?")
- [ ] Send the message
- [ ] **VERIFY**: Message shows both image and text
- [ ] **VERIFY**: AI responds based on both image and text

### Image Display in Chat History
- [ ] Send a message with an image
- [ ] **VERIFY**: Image appears in user message bubble
- [ ] **VERIFY**: Image is displayed with rounded corners
- [ ] **VERIFY**: Image fits within message bubble width
- [ ] **VERIFY**: Text appears below the image if provided
- [ ] Close and reopen the app
- [ ] **VERIFY**: Image still appears in chat history

### Image Error Handling
- [ ] Select a very large image (> 5MB if possible)
- [ ] **VERIFY**: Image is compressed/resized automatically
- [ ] **VERIFY**: Message sends successfully
- [ ] Try selecting a corrupt/invalid image file
- [ ] **VERIFY**: App handles gracefully with error message

### Model Switching
- [ ] Select a vision model, add an image
- [ ] Switch to a non-vision model
- [ ] **VERIFY**: Image picker button disappears
- [ ] **VERIFY**: Any selected image is cleared
- [ ] Switch back to vision model
- [ ] **VERIFY**: Image picker button reappears

## 4. Database Migration Test

### First Time After Update
- [ ] If testing on existing installation with old data:
  - [ ] Open the app
  - [ ] **VERIFY**: App opens without errors
  - [ ] **VERIFY**: Existing chats are still accessible
  - [ ] **VERIFY**: Old messages display correctly
  - [ ] **VERIFY**: Can send new messages with images

### Fresh Install
- [ ] Uninstall app completely
- [ ] Install new version
- [ ] **VERIFY**: App launches successfully
- [ ] Create new chat with image
- [ ] **VERIFY**: Everything works as expected

## 5. Cross-Platform Tests

### Desktop (Windows/macOS/Linux)
- [ ] Test on desktop platform
- [ ] **VERIFY**: Image picker opens system file dialog
- [ ] **VERIFY**: All features work on desktop

### Mobile (Android/iOS)
- [ ] Test on mobile platform
- [ ] **VERIFY**: Image picker shows gallery/camera options
- [ ] **VERIFY**: All features work on mobile
- [ ] **VERIFY**: Image preview fits mobile screen

## 6. Integration Tests

### Complete User Flow
- [ ] Launch app
- [ ] Create new chat
- [ ] Select "gemini" model
- [ ] **VERIFY**: Image button appears
- [ ] Send text message → **VERIFY**: typing animation
- [ ] Select and send image → **VERIFY**: image displays
- [ ] Ask about the image → **VERIFY**: AI responds appropriately
- [ ] Switch to "deepseek" → **VERIFY**: image button disappears
- [ ] Send text message → **VERIFY**: works normally
- [ ] Close app
- [ ] Reopen app
- [ ] **VERIFY**: Chat history preserved with images

### Edge Cases
- [ ] Send empty message with only image (no text)
- [ ] Send very long text with image
- [ ] Send multiple messages quickly with images
- [ ] Switch models rapidly while image is selected
- [ ] Try to send while previous message is still streaming

## 7. Performance Tests

### Responsiveness
- [ ] App remains responsive during image selection
- [ ] No lag when displaying images in chat
- [ ] Smooth scrolling with images in chat history
- [ ] Typing animation doesn't affect performance

### Memory Usage
- [ ] Monitor memory usage with multiple images in chat
- [ ] **VERIFY**: No significant memory leaks
- [ ] Images are properly compressed

## Success Criteria

All tests should pass with:
- ✅ No crashes or errors
- ✅ Smooth user experience
- ✅ Features work as described
- ✅ Backward compatibility maintained
- ✅ No data loss
- ✅ Professional appearance

## Reporting Issues

If any test fails:
1. Note which test failed
2. Describe expected vs actual behavior
3. Include screenshots/logs if possible
4. Report platform/device information
