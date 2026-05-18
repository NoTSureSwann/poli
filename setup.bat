@echo off
setlocal enabledelayedexpansion

echo.
echo ========================================
echo Klinik Merah Putih - Setup Script
echo ========================================
echo.

where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Node.js tidak ditemukan.
    exit /b 1
)

where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Flutter tidak ditemukan.
    exit /b 1
)

echo [1/4] Setup backend dependencies...
cd backend
call npm install
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: npm install backend gagal.
    exit /b 1
)

if not exist ".env" (
    copy .env.example .env >nul
    echo Backend .env dibuat dari .env.example
)

echo [2/4] Menjalankan migrasi SQLite...
call npm run migrate
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: migrasi database gagal.
    exit /b 1
)

echo [3/4] Setup frontend dependencies...
cd ..
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: flutter pub get gagal.
    exit /b 1
)

echo [4/4] Ringkasan cepat...
echo.
echo Backend:
echo   cd backend ^&^& npm run dev
echo.
echo Frontend:
echo   flutter run
echo.
echo ADB Wireless helper:
echo   adb-wireless-connect.bat
echo   (akan bantu adb pair PHONE_IP:PAIRING_PORT + adb connect PHONE_IP:DEBUG_PORT)
echo.
echo Postman collection:
echo   backend\postman\Klinik-Chatbot-API.postman_collection.json
echo.

pause
