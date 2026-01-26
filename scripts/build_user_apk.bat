@echo off
echo Building USER APK...
echo.
flutter build apk --release --flavor user -t lib/main_user.dart --dart-define=ENV_FILE=assets/env/production.env
echo.
echo Build complete! APK location:
echo build\app\outputs\flutter-apk\app-user-release.apk
pause
