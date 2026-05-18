# Klinik Merah Putih - Project Enhancement Documentation

## Overview

This document outlines the comprehensive improvements made to the Klinik Merah Putih project, including database fixes, AI chatbot integration, UI/UX enhancements, and wireless Android debugging setup.

---

## 1. Database Enhancements

### SQLite Database Setup

The project now uses SQLite3 as the primary database with the following improvements:

#### New Table: `chat_messages`

```sql
CREATE TABLE chat_messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id),
    session_id TEXT,
    sender TEXT NOT NULL,
    message TEXT NOT NULL,
    model_used TEXT DEFAULT 'mistral',
    response_time_ms INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

#### Indexes Added

- `idx_chat_user` - Query messages by user
- `idx_chat_session` - Query messages by session
- `idx_chat_created` - Query messages by creation date

### Database Migration

Run the migration to set up the database:

```bash
cd backend
npm run migrate
```

### Database Seeding (Optional)

```bash
npm run seed
```

---

## 2. AI Chatbot Integration

### Backend Implementation

#### Chatbot Routes

- `POST /api/chatbot/send` - Send message to AI
- `GET /api/chatbot/history/:userId` - Get chat history
- `DELETE /api/chatbot/clear/:userId` - Clear chat history
- `GET /api/chatbot/models` - Get available LLM models

#### Files Created

- `/backend/src/modules/chatbot/chatbot.routes.js` - Route definitions
- `/backend/src/modules/chatbot/chatbot.controller.js` - Request handlers
- `/backend/src/modules/chatbot/chatbot.service.js` - Business logic

### Configuration

Create or update `.env` file in backend directory:

```env
# Use Ollama locally
USE_VLLM=false
OLLAMA_BASE_URL=http://localhost:11434
LLM_MODEL=mistral

# Or use vLLM Cloud
USE_VLLM=true
VLLM_BASE_URL=https://api.vllm.cloud/v1
VLLM_API_KEY=your_api_key_here
```

### Supported LLM Models

#### Ollama (Local)

- `mistral` - 7B, fast and efficient
- `llama2` - 7B-70B variants
- `neural-chat` - Specialized for conversations
- `medical-llama` - For healthcare context

#### vLLM Cloud

- Open AI compatible API
- Supports various quantized models
- Token-based rate limiting

### Integration Steps

1. **Install Ollama** (for local usage)

   ```bash
   # macOS
   brew install ollama

   # Or download from https://ollama.ai
   ```

2. **Pull a Model**

   ```bash
   ollama pull mistral
   ```

3. **Run Ollama Server**

   ```bash
   ollama serve
   # Server runs on http://localhost:11434
   ```

4. **Test Chatbot Endpoint**
   ```bash
   curl -X POST http://localhost:3000/api/chatbot/send \
     -H "Content-Type: application/json" \
     -d '{"userId":1,"message":"Saya sakit kepala"}'
   ```

---

## 3. Frontend Chatbot Integration

### Flutter Implementation

#### Files Created

- `lib/screens/chatbot_screen.dart` - Chatbot UI
- `lib/services/chatbot_service.dart` - API client
- `lib/models/chat_message_model.dart` - Data models

#### Usage in Main App

```dart
// Add to home screen navigation
NavigationDestination(
  icon: Icon(Icons.chat),
  label: 'Konsultasi AI',
  child: ChatbotScreen(userId: currentUserId),
)
```

#### Features

- Real-time messaging
- Chat history persistence
- Multiple model selection
- Session management
- Message clearing

---

## 4. Terms of Agreement Links

### Changes Made

Updated `lib/screens/onboarding/terms_screen.dart` to include clickable links:

```dart
// Terms & Conditions Link
GestureDetector(
  onTap: () => _launchUrl('https://klinik-merah-putih.com/terms'),
  child: const Text('Syarat & Ketentuan'),
)

// Privacy Policy Link
GestureDetector(
  onTap: () => _launchUrl('https://klinik-merah-putih.com/privacy'),
  child: const Text('Kebijakan Privasi'),
)
```

### Configuration

Update the URLs in `terms_screen.dart` with your actual policy pages:

```dart
_launchUrl('https://your-domain.com/terms')
_launchUrl('https://your-domain.com/privacy')
```

---

## 5. UI/UX Improvements

### Modern Widgets Library

New file: `lib/widgets/modern_widgets.dart`

#### Available Components

1. **ModernCard** - Elevated card with custom styling
2. **ModernButton** - Multi-variant button component
3. **ModernTextField** - Enhanced text input field
4. **LoadingWidget** - Consistent loading indicator
5. **ErrorWidget** - Error state display
6. **InfoCard** - Information card component

#### Usage Examples

```dart
// Modern Card
ModernCard(
  child: Column(
    children: [
      Text('Card Title'),
      Text('Card Content'),
    ],
  ),
)

// Modern Button
ModernButton(
  label: 'Submit',
  onPressed: () {},
  variant: ButtonVariant.primary,
)

// Modern Text Field
ModernTextField(
  label: 'Email',
  hint: 'Masukkan email Anda',
  keyboardType: TextInputType.emailAddress,
  prefixIcon: Icons.email,
)
```

### Theme Enhancements

- Improved color palette
- Better typography hierarchy
- Consistent spacing system
- Enhanced shadow effects
- Dark mode support

---

## 6. Android Wireless Debugging

### Setup Instructions

#### Prerequisites

- Android 11 or higher
- USB Debugging enabled
- WiFi connected devices on same network

#### Step 1: Enable Wireless Debugging

On Android device:

1. Settings → System → Developer Options
2. Enable "Developer Mode"
3. Enable "USB Debugging"
4. Enable "Wireless Debugging"

#### Step 2: ADB Pairing

```bash
# Get IP and pairing port from Wireless Debugging settings
adb pair <PHONE_IP>:<PAIRING_PORT>

# Example
adb pair 192.168.1.100:36911

# Enter 6-digit code shown on device
```

#### Step 3: ADB Connect

```bash
# Connect using debug port (usually 5555)
adb connect <PHONE_IP>:<DEBUG_PORT>

# Example
adb connect 192.168.1.100:5555
```

#### Step 4: Verify Connection

```bash
adb devices
# Should show your device as "device"
```

#### Step 5: Run Flutter

```bash
flutter run
```

### Troubleshooting

#### Issue: Connection Refused

```bash
# Disconnect and retry
adb disconnect
adb pair <PHONE_IP>:<PAIRING_PORT>
adb connect <PHONE_IP>:<DEBUG_PORT>
```

#### Issue: Cannot Find Pair Code

- Open Wireless Debugging settings on device
- Select "Pair with code"
- Note down the code and port

#### Issue: ADB Not Found

```bash
# Add Android tools to PATH
export PATH=$PATH:~/Library/Android/sdk/platform-tools

# Or configure in Flutter
flutter config --android-sdk ~/Library/Android/sdk
```

---

## 7. Postman API Testing

### Collection Location

`backend/postman/Klinik-Chatbot-API.postman_collection.json`

### Import Steps

1. Open Postman
2. Click "Import"
3. Select the JSON file
4. All endpoints will be imported

### Available Endpoints

- **Chatbot** - Send/receive messages
- **Health Check** - API status
- **DNS Configuration** - DNS setup

### Example Requests

```bash
# Send Message
POST http://localhost:3000/api/chatbot/send
{
  "userId": 1,
  "message": "Saya ingin konsultasi",
  "sessionId": "session-id"
}

# Get History
GET http://localhost:3000/api/chatbot/history/1

# Get Models
GET http://localhost:3000/api/chatbot/models
```

---

## 8. Environment Configuration

### Backend .env Template

See `backend/.env.example` for all available configuration options.

Key variables:

```env
# Server
PORT=3000
NODE_ENV=development

# Database
DB_TYPE=sqlite
DATABASE_URL=./database.sqlite

# JWT
JWT_SECRET=your_secret_key

# AI/LLM
USE_VLLM=false
OLLAMA_BASE_URL=http://localhost:11434
LLM_MODEL=mistral
```

### Frontend .env

```env
API_BASE_URL=http://localhost:3000
APP_NAME=Klinik Merah Putih
```

---

## 9. Development Workflow

### Running the Backend

```bash
cd backend

# Install dependencies
npm install

# Run migrations
npm run migrate

# Start development server
npm run dev

# The API will be available at http://localhost:3000
```

### Running the Frontend

```bash
# Get dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Run on web
flutter run -d chrome

# Run on Windows
flutter run -d windows
```

### Running with Chatbot

1. Start Ollama server (if using local)
2. Start backend server
3. Start Flutter app
4. Navigate to Chatbot screen
5. Send messages

---

## 10. Best Practices

### Chatbot Integration

- Cache LLM responses when appropriate
- Implement rate limiting for API calls
- Validate user input before sending
- Store chat history securely
- Use session IDs for conversation management

### UI/UX

- Use ModernCard for consistent styling
- Apply ModernButton for all interactions
- Maintain color consistency
- Test dark mode compatibility
- Ensure responsive design

### Database

- Always run migrations before deployment
- Backup database regularly
- Use indexes for frequently queried fields
- Implement data validation at database level

### Security

- Keep `.env` files out of version control
- Validate all API inputs
- Use HTTPS in production
- Store sensitive data encrypted
- Implement proper authentication

---

## 11. Common Commands

```bash
# Backend
npm install              # Install dependencies
npm run migrate         # Run database migrations
npm run seed            # Seed sample data
npm run dev             # Start development server
npm start               # Start production server

# Frontend
flutter pub get         # Get dependencies
flutter run             # Run on default device
flutter run -d chrome   # Run on web
flutter run -d windows  # Run on Windows
flutter clean           # Clean build artifacts
flutter build apk       # Build Android APK

# Android Debugging
adb devices            # List connected devices
adb pair <IP>:<PORT>   # Pair wireless device
adb connect <IP>:<PORT> # Connect wireless device
adb disconnect         # Disconnect device
```

---

## 12. Deployment Checklist

- [ ] Environment variables configured
- [ ] Database migrations completed
- [ ] Ollama/vLLM service running
- [ ] Terms of Agreement links updated
- [ ] UI/UX tested on all devices
- [ ] Chatbot endpoints tested
- [ ] Android wireless debugging configured
- [ ] Postman collection updated
- [ ] Documentation completed
- [ ] Code review completed
- [ ] Security audit passed
- [ ] Performance testing done

---

## Support & Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Express.js Documentation](https://expressjs.com/)
- [Ollama Documentation](https://github.com/ollama/ollama)
- [vLLM Documentation](https://docs.vllm.ai/)
- [SQLite Documentation](https://www.sqlite.org/docs.html)

---

## Version History

- **v1.1.0** - Added chatbot, improved UI/UX, wireless debugging
- **v1.0.0** - Initial release

---

Generated: April 27, 2026
