@echo off
setlocal enabledelayedexpansion

echo.
echo ========================================
echo ADB Wireless Pair + Connect Helper
echo ========================================
echo.

where adb >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: adb tidak ditemukan di PATH.
    echo Install Android Platform Tools lalu tambahkan ke PATH.
    exit /b 1
)

echo 1. Aktifkan Wireless Debugging di HP Android (Android 11+)
echo 2. Buka "Pair device with pairing code"
echo.

set /p PHONE_IP=Masukkan PHONE_IP (contoh 192.168.1.23): 
set /p PAIRING_PORT=Masukkan PAIRING_PORT: 
set /p DEBUG_PORT=Masukkan DEBUG_PORT: 

if "%PHONE_IP%"=="" (
    echo ERROR: PHONE_IP wajib diisi.
    exit /b 1
)
if "%PAIRING_PORT%"=="" (
    echo ERROR: PAIRING_PORT wajib diisi.
    exit /b 1
)
if "%DEBUG_PORT%"=="" (
    echo ERROR: DEBUG_PORT wajib diisi.
    exit /b 1
)

echo.
echo Restarting adb server...
adb kill-server >nul 2>nul
adb start-server

echo.
echo Pairing device...
adb pair %PHONE_IP%:%PAIRING_PORT%
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Pairing gagal. Pastikan kode pairing dan port benar.
    exit /b 1
)

echo.
echo Connecting device...
adb connect %PHONE_IP%:%DEBUG_PORT%
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Connect gagal. Coba ulang pairing lalu connect lagi.
    exit /b 1
)

echo.
echo Active devices:
adb devices

echo.
echo Setup adb reverse untuk API lokal backend (port 3000)...
adb -s %PHONE_IP%:%DEBUG_PORT% reverse tcp:3000 tcp:3000

echo.
echo Selesai.
echo Jalankan Flutter: flutter run
echo.

pause
