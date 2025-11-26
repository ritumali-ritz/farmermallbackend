@echo off
echo ========================================
echo Farmer Mall - APK Builder
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

echo Step 1: Getting Flutter dependencies...
flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to get dependencies
    pause
    exit /b 1
)

echo.
echo Step 2: Checking for connected devices...
flutter devices
echo.

echo Step 3: Building APK...
echo Choose build type:
echo 1. Debug APK (for testing)
echo 2. Release APK (for distribution - recommended)
set /p choice="Enter choice (1 or 2): "

if "%choice%"=="1" (
    echo Building Debug APK...
    flutter build apk --debug
) else if "%choice%"=="2" (
    echo Building Release APK...
    flutter build apk --release
) else (
    echo Invalid choice. Building Release APK by default...
    flutter build apk --release
)

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Build failed!
    echo Check the error messages above.
    pause
    exit /b 1
)

echo.
echo ========================================
echo Build Complete!
echo ========================================
echo.
echo APK Location:
if "%choice%"=="1" (
    echo build\app\outputs\flutter-apk\app-debug.apk
) else (
    echo build\app\outputs\flutter-apk\app-release.apk
)
echo.
echo To install on connected device:
echo   flutter install
echo.
echo Or copy APK to your phone and install manually.
echo.
pause

