# AI Chatbox Integration Guide

## 📋 Overview
This guide explains how to integrate and use the AI chatbox in your FutureIT Flutter application.

## 📦 What's Included

### 1. **ChatMessage Model** (`lib/models/chat_message.dart`)
- Represents individual chat messages
- Properties: `id`, `content`, `isUser`, `timestamp`

### 2. **AiChatService** (`lib/services/ai_chat_service.dart`)
- Handles communication with your backend API
- Sends user questions to `/api/aichatapi/ask-ai` endpoint
- Receives AI responses from Gemini API

### 3. **AiChatScreen** (`lib/screens/ai_chat_screen.dart`)
- Complete chat UI with message bubbles
- Real-time message updates
- Loading state indicators
- Auto-scroll to latest messages

### 4. **Dashboard Integration**
- Floating chat button added to `DashboardScreen`
- Users can access chat from anywhere in the app

## 🔧 Setup Instructions

### Step 1: Add Dependencies
Dependencies have been added to `pubspec.yaml`:
```yaml
uuid: ^4.0.0
```

Run: `flutter pub get`

### Step 2: Update Environment Variables
Make sure your `.env` file includes the correct API URL:
```env
API_URL=http://localhost:5000
# Or your production API URL
```

### Step 3: Backend Requirements
Your C# backend should have:
- `AiChatApiController` with `/api/aichatapi/ask-ai` endpoint
- `GeminiService` configured with API keys
- Database context properly set up

## 🎯 How to Use

### For Users:
1. Click the chat button (💬) in the bottom-right corner
2. Type your question
3. Press send or tap the send button
4. Wait for AI response
5. Continue conversation

### For Developers:

#### Navigate to Chat Screen:
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const AiChatScreen()),
);
```

#### Use AiChatService directly:
```dart
final aiService = AiChatService();
final response = await aiService.askAi('Your question here');
```

## 📱 Features

✅ **User-friendly UI**
- Clean message bubbles
- Different colors for user/AI messages
- Auto-scrolling conversation

✅ **Error Handling**
- Network error messages
- Timeout protection (30 seconds)
- User-friendly error responses

✅ **Performance**
- Efficient message rendering
- Loading indicators
- Prevents duplicate requests

## 🎨 Customization

### Change Colors:
In `ai_chat_screen.dart`, modify:
```dart
backgroundColor: Colors.blue[600]  // User message color
backgroundColor: Colors.grey[300]  // AI message color
```

### Change API Endpoint:
In `ai_chat_service.dart`:
```dart
final url = Uri.parse('$_baseUrl/api/aichatapi/ask-ai');
```

### Change Welcome Message:
In `_addWelcomeMessage()` method:
```dart
content: 'Your custom welcome message here'
```

## 🐛 Troubleshooting

### Issue: "Target of URI doesn't exist"
**Solution:** Run `flutter pub get` to install uuid package

### Issue: API returns 500 error
**Solution:** Check your C# backend logs and Gemini API configuration

### Issue: Messages not appearing
**Solution:** Check API_URL in .env file and network connectivity

### Issue: Timeout errors
**Solution:** Increase timeout in `ai_chat_service.dart` if needed:
```dart
.timeout(
  const Duration(seconds: 60),  // Increase from 30 to 60
  ...
)
```

## 📞 API Contract

### Request Format:
```json
POST /api/aichatapi/ask-ai
Content-Type: application/json

"Your question text here"
```

### Response Format:
```json
{
  "question": "Your question text",
  "reply": "AI response text"
}
```

## 🚀 Future Enhancements

Potential improvements:
- [ ] Chat history persistence
- [ ] Typing indicators
- [ ] Image/file sharing
- [ ] Voice input
- [ ] Conversation themes
- [ ] Chat export/download

## 📝 Notes

- Messages are not persisted (cleared on app restart)
- All chat goes through your backend to Gemini API
- Ensure proper CORS headers on backend for web deployment
