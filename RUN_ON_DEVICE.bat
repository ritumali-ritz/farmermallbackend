@echo off
echo ========================================
echo Farmer Mall - Run on Device
echo ========================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Flutter is not installed or not in PATH
    echo Please install Flutter first: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

REM Navigate to Flutter app directory
cd farmer_mall_app
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: farmer_mall_app directory not found
    pause
    exit /b 1
)

echo Checking for connected devices...
flutter devices
echo.

echo Starting app on connected device...
echo Make sure:
echo   1. Your device is connected via USB
echo   2. USB debugging is enabled
echo   3. Server is running (node server.js)
echo.

flutter run

pause

