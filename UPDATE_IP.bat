@echo off
echo ========================================
echo Get Your IP Address for Config
echo ========================================
echo.
echo Please connect your laptop and phone to the SAME hotspot first!
echo.
pause

echo Getting your IP address...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4"') do (
    set IP=%%a
    set IP=!IP: =!
    echo.
    echo Your IP Address: !IP!
    echo.
    echo Update this in: farmer_mall_app\lib\config.dart
    echo Change line 16 to: static const String serverIP = '!IP!';
    echo.
    pause
    exit /b
)

echo Could not find IP address automatically.
echo Please run: ipconfig
echo Look for "IPv4 Address" under your WiFi adapter
echo.
pause

