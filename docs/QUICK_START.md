# Klinik Merah Putih - Quick Reference Guide

## 🚀 Quick Start

### Option 1: Automated Setup (Linux/Mac)

```bash
chmod +x setup.sh
./setup.sh
```

### Option 2: Automated Setup (Windows)

```cmd
setup.bat
```

### Option 3: Manual Setup

#### Backend

```bash
cd backend
npm install
cp .env.example .env
npm run migrate
npm run dev
```

#### Frontend

```bash
flutter pub get
flutter run
```

---

## 📋 Project Structure

```
klinik/
├── backend/                          # Node.js Express API
│   ├── src/
│   │   ├── modules/
│   │   │   ├── chatbot/             # NEW: AI Chatbot
│   │   │   │   ├── chatbot.routes.js
│   │   │   │   ├── chatbot.controller.js
│   │   │   │   └── chatbot.service.js
│   │   │   ├── auth/                # Authentication
│   │   │   ├── pasien/              # Patient management
│   │   │   ├── medical-record/      # Medical records
│   │   │   ├── pembayaran/          # Payments
│   │   │   └── ml/                  # ML services
│   │   ├── config/
│   │   │   └── database.js          # SQLite connection
│   │   ├── middleware/
│   │   ├── services/
│   │   ├── utils/
│   │   └── app.js                   # Main app file
│   ├── database/
│   │   ├── schema.sqlite.sql        # SQLite schema (UPDATED)
│   │   ├── migrate.js
│   │   └── seed.js
│   ├── postman/
│   │   ├── Klinik-Merah-Putih.postman_collection.json
│   │   └── Klinik-Chatbot-API.postman_collection.json (NEW)
│   ├── .env.example                 # Environment template (UPDATED)
│   └── package.json
│
├── lib/                             # Flutter App
│   ├── screens/
│   │   ├── chatbot_screen.dart      # NEW: AI Chatbot UI
│   │   ├── auth/
│   │   ├── onboarding/
│   │   │   └── terms_screen.dart    # UPDATED: Terms with links
│   │   ├── home_screen.dart
│   │   └── ...
│   ├── services/
│   │   ├── chatbot_service.dart     # NEW: Chatbot API client
│   │   └── auth_service.dart
│   ├── models/
│   │   ├── chat_message_model.dart  # NEW: Chat models
│   │   └── ...
│   ├── theme/
│   │   └── app_theme.dart           # UPDATED: Enhanced theme
│   ├── widgets/
│   │   └── modern_widgets.dart      # NEW: UI components
│   └── main.dart
│
├── android/                         # Android platform code
│   ├── app/
│   └── gradle/
│
├── docs/
│   ├── 06_ENHANCEMENT_GUIDE.md      # NEW: Complete guide
│   └── ...
│
├── ANDROID_SETUP_GUIDE.md           # UPDATED: With ADB instructions
├── pubspec.yaml                     # Flutter dependencies
├── setup.sh                         # NEW: Linux/Mac setup
├── setup.bat                        # NEW: Windows setup
└── README.md
```

---

## 🤖 AI Chatbot Setup

### 1. Choose Your LLM Provider

#### Option A: Local Ollama

```bash
# Install Ollama
brew install ollama  # macOS
# Or download from https://ollama.ai

# Pull a model
ollama pull mistral

# Start server
ollama serve
```

#### Option B: vLLM Cloud

1. Sign up at vLLM Cloud
2. Get API key
3. Set `USE_VLLM=true` in `.env`

### 2. Configure Backend

```env
# .env file
USE_VLLM=false
OLLAMA_BASE_URL=http://localhost:11434
LLM_MODEL=mistral
```

### 3. Test Chatbot

```bash
curl -X POST http://localhost:3000/api/chatbot/send \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "message": "Saya sakit kepala"
  }'
```

---

## 📱 Android Wireless Debugging

### 1. Enable on Device

- Settings → Developer Options → Wireless Debugging → Enable

### 2. Pair Device

```bash
# Get IP and pairing port from settings
adb pair 192.168.1.100:36911
# Enter 6-digit code
```

### 3. Connect

```bash
adb connect 192.168.1.100:5555
```

### 4. Verify

```bash
adb devices
# Should show your device as "device"
```

### 5. Run Flutter

```bash
flutter run
```

---

## 📊 Database Management

### Run Migrations

```bash
cd backend
npm run migrate
```

### Seed Sample Data

```bash
npm run seed
```

### Access Database

```bash
# Using sqlite3 CLI
sqlite3 database.sqlite

# Query examples
SELECT * FROM users;
SELECT * FROM chat_messages;
SELECT * FROM pasien;
```

---

## 🔌 API Endpoints

### Chatbot Endpoints

```
POST   /api/chatbot/send           - Send message
GET    /api/chatbot/history/:userId - Get chat history
DELETE /api/chatbot/clear/:userId   - Clear history
GET    /api/chatbot/models         - Get available models
```

### Other Endpoints

```
GET    /health                      - Health check
POST   /api/auth/login              - User login
POST   /api/auth/register           - User registration
GET    /api/patients/:id            - Get patient
POST   /api/medical-records         - Create medical record
```

---

## 🎨 UI Components

### Available Modern Widgets

```dart
ModernCard()          - Elevated card
ModernButton()        - Multi-variant button
ModernTextField()     - Enhanced text field
LoadingWidget()       - Loading indicator
ErrorWidget()         - Error state
InfoCard()           - Info card
```

### Example Usage

```dart
import 'package:klinik/widgets/modern_widgets.dart';

// Button
ModernButton(
  label: 'Send',
  onPressed: () {},
  variant: ButtonVariant.primary,
)

// Text Field
ModernTextField(
  label: 'Email',
  hint: 'Enter email',
  keyboardType: TextInputType.emailAddress,
)
```

---

## 🧪 Testing with Postman

### Import Collection

1. Open Postman
2. Click Import
3. Select: `backend/postman/Klinik-Chatbot-API.postman_collection.json`

### Available Requests

- Send Message
- Get Chat History
- Clear History
- Get Models
- Health Check

---

## 📝 Environment Variables

### Backend (.env)

```env
# Server
PORT=3000
NODE_ENV=development

# Database
DB_TYPE=sqlite

# AI/LLM
USE_VLLM=false
OLLAMA_BASE_URL=http://localhost:11434
LLM_MODEL=mistral

# Authentication
JWT_SECRET=your_secret_here
```

### Frontend (.env)

```env
API_BASE_URL=http://localhost:3000
APP_NAME=Klinik Merah Putih
```

---

## 🐛 Troubleshooting

### Backend Won't Start

```bash
# Check port is not in use
lsof -i :3000

# Kill process if needed
kill -9 <PID>

# Try again
npm run dev
```

### Flutter Build Issues

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Run
flutter run
```

### Chatbot Not Working

```bash
# Check Ollama is running
curl http://localhost:11434/api/tags

# Check backend is running
curl http://localhost:3000/health

# Check .env configuration
cat backend/.env
```

### ADB Connection Issues

```bash
# Disconnect all
adb disconnect

# Kill server
adb kill-server

# Start fresh
adb start-server

# Try pairing again
adb pair <IP>:<PORT>
```

---

## 📚 Documentation

- [Full Enhancement Guide](docs/06_ENHANCEMENT_GUIDE.md)
- [Android Setup Guide](ANDROID_SETUP_GUIDE.md)
- [API Documentation](backend/src/modules/chatbot/README.md)

---

## 🔐 Security Tips

- Keep `.env` files private
- Don't commit API keys
- Use HTTPS in production
- Validate all user inputs
- Enable CORS carefully
- Use strong JWT secrets

---

## 📞 Support

For issues or questions:

1. Check the documentation
2. Review the troubleshooting section
3. Check GitHub issues
4. Contact development team

---

## 📅 Version

- **Current Version:** 1.1.0
- **Last Updated:** April 27, 2026
- **Compatible with:**
  - Flutter 3.11.4+
  - Node.js 16+
  - Android 11+

---

## 📄 License

MIT License - See LICENSE file

---

**Happy Coding! 🎉**
