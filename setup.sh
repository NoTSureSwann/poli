#!/bin/bash

# Klinik Merah Putih - Setup Script
# This script helps set up the project with all enhancements

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Klinik Merah Putih - Setup Script${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check Node.js
echo -e "${YELLOW}Checking Node.js installation...${NC}"
if ! command -v node &> /dev/null; then
    echo -e "${RED}Node.js is not installed. Please install it first.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Node.js found: $(node --version)${NC}"

# Check Flutter
echo -e "${YELLOW}Checking Flutter installation...${NC}"
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Flutter is not installed. Please install it first.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Flutter found: $(flutter --version | head -1)${NC}"

# Check Git
echo -e "${YELLOW}Checking Git installation...${NC}"
if ! command -v git &> /dev/null; then
    echo -e "${RED}Git is not installed. Please install it first.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Git found${NC}"
echo ""

# Setup Backend
echo -e "${YELLOW}Setting up Backend...${NC}"
cd backend

echo "Installing backend dependencies..."
npm install

echo "Creating .env file..."
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo -e "${GREEN}✓ .env file created. Please update it with your configuration.${NC}"
else
    echo -e "${GREEN}✓ .env file already exists${NC}"
fi

echo "Running database migrations..."
npm run migrate

echo -e "${GREEN}✓ Backend setup complete${NC}"
echo ""

# Setup Frontend
echo -e "${YELLOW}Setting up Frontend...${NC}"
cd ../

echo "Getting Flutter dependencies..."
flutter pub get

echo -e "${GREEN}✓ Frontend setup complete${NC}"
echo ""

# Summary
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Next steps:"
echo -e "${YELLOW}1. Backend:${NC}"
echo -e "   - Update 'backend/.env' with your configuration"
echo -e "   - Start Ollama server: ${YELLOW}ollama serve${NC}"
echo -e "   - Start backend: ${YELLOW}cd backend && npm run dev${NC}"
echo ""
echo -e "${YELLOW}2. Frontend:${NC}"
echo -e "   - Start Flutter: ${YELLOW}flutter run${NC}"
echo ""
echo -e "${YELLOW}3. Testing:${NC}"
echo -e "   - Import Postman collection: ${YELLOW}backend/postman/Klinik-Chatbot-API.postman_collection.json${NC}"
echo ""
echo -e "${YELLOW}4. Wireless Android Debugging:${NC}"
echo -e "   - See docs/06_ENHANCEMENT_GUIDE.md for setup instructions${NC}"
echo ""
