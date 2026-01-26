@echo off
echo Building Admin APK with all fixes...
echo.
flutter build apk --release --flavor admin -t lib/main_admin.dart --dart-define=ENV_FILE=assets/env/production.env
echo.
echo Build complete! APK location:
echo build\app\outputs\flutter-apk\app-admin-release.apk
pause
