# Tech Stack & Dependencies (v0.02)

## Overview
Complete technical stack documentation for Transfort v0.02, including existing dependencies and new requirements.

---

## Core Technology Stack

### Frontend Framework
- **Flutter:** 3.38.7
- **Dart SDK:** >=3.0.0 <4.0.0
- **Target Platforms:** Android, iOS
- **Minimum SDK:** Android 21 (Lollipop), iOS 12.0

### Backend (Supabase)
- **PostgreSQL:** 15.x
- **Supabase SDK:** Latest stable
- **Authentication:** Supabase Auth
- **Storage:** Supabase Storage
- **Realtime:** Supabase Realtime

---

## Flutter Dependencies (Existing)

### State Management
```yaml
flutter_riverpod: ^2.4.0
riverpod_annotation: ^2.3.0
```

### Navigation
```yaml
go_router: ^12.0.0
```

### Backend Integration
```yaml
supabase_flutter: ^2.0.0
```

### UI Components
```yaml
flutter_svg: ^2.0.9
url_launcher: ^6.2.1
image_picker: ^1.0.4
cached_network_image: ^3.3.0
```

### Utilities
```yaml
intl: ^0.18.1
shared_preferences: ^2.2.2
path_provider: ^2.1.1
equatable: ^2.0.5
freezed_annotation: ^2.4.1
json_annotation: ^4.8.1
```

### Development
```yaml
build_runner: ^2.4.6
riverpod_generator: ^2.3.0
freezed: ^2.4.5
json_serializable: ^6.7.1
flutter_launcher_icons: ^0.13.1
```

---

## v0.02 New Dependencies Required

### None Required
All existing dependencies support v0.02 features. No new packages needed.

---

## Android Configuration

### Flavors (Existing)
```gradle
flavorDimensions "app"
productFlavors {
    user {
        dimension "app"
        applicationIdSuffix ".user"
        manifestPlaceholders = [appName: "Transfort"]
    }
    admin {
        dimension "app"
        applicationIdSuffix ".admin"
        manifestPlaceholders = [appName: "Transfort Admin"]
    }
}
```

### Build Configuration
```gradle
android {
    compileSdkVersion 34
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "0.02.0"
    }
}
```

### Permissions (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

---

## iOS Configuration

### Info.plist Permissions
```xml
<key>NSCameraUsageDescription</key>
<string>Camera access required for document verification</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Photo library access required for uploading documents</string>
```

### Deployment Target
```
iOS 12.0+
```

---

## Project Structure (Existing)

```
lib/
├── core/
│   ├── router/
│   │   ├── app_router.dart (User app)
│   │   └── admin_app_router.dart (Admin app)
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_dimensions.dart
│   │   └── app_theme.dart
│   └── utils/
│       ├── formatters.dart
│       └── validators.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── loads/
│   ├── chat/
│   ├── profile/
│   ├── verification/
│   ├── fleet/
│   ├── admin/
│   └── notifications/
├── shared/
│   └── widgets/
├── main_user.dart (User app entry)
└── main_admin.dart (Admin app entry)
```

---

## Environment Setup

### Required Tools
1. **Flutter SDK:** 3.38.7
2. **Android Studio:** Latest stable
3. **Xcode:** 14.0+ (macOS only)
4. **VS Code:** (optional, recommended)
5. **Git:** Latest stable

### Environment Variables
```env
# .env.local
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=local-anon-key
USE_MOCK_AUTH=false

# .env.production
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=production-anon-key
USE_MOCK_AUTH=false
```

### Setup Commands
```bash
# Install dependencies
flutter pub get

# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Run user app (debug)
flutter run --flavor user --target lib/main_user.dart

# Run admin app (debug)
flutter run --flavor admin --target lib/main_admin.dart

# Build release APKs
flutter build apk --release --flavor user
flutter build apk --release --flavor admin
```

---

## Code Generation

### Freezed Models
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Riverpod Providers
```bash
flutter pub run build_runner watch
```

### Launcher Icons
```bash
flutter pub run flutter_launcher_icons
```

---

## Testing Setup

### Test Structure
```
test/
├── unit/
│   ├── providers/
│   ├── repositories/
│   └── use_cases/
├── widget/
│   ├── auth/
│   ├── loads/
│   └── chat/
└── integration/
    ├── auth_flow_test.dart
    └── load_posting_flow_test.dart
```

### Test Commands
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test
flutter test test/unit/providers/auth_provider_test.dart
```

---

## Performance Optimization

### Build Optimization
```yaml
# pubspec.yaml
flutter:
  uses-material-design: true
  
  # Tree-shake unused icons
  fonts:
    - family: Roboto
      fonts:
        - asset: fonts/Roboto-Regular.ttf
```

### Code Splitting (Future)
- Lazy load heavy features
- Deferred loading for admin features

---

## Security Configuration

### ProGuard Rules (Android)
```proguard
# Keep Supabase classes
-keep class io.supabase.** { *; }

# Keep model classes
-keep class com.transfort.app.data.models.** { *; }
```

### App Signing
- **Debug:** Auto-generated debug keystore
- **Release:** Production keystore (secure storage)

---

## Asset Management

### Images
```
assets/
├── images/
│   ├── transfort-logo-trans.png (Splash logo)
│   ├── transfort-icon.png (App icon)
│   └── placeholders/
└── icons/
    └── (if custom icons needed)
```

### Fonts
```yaml
fonts:
  - family: Inter
    fonts:
      - asset: assets/fonts/Inter-Regular.ttf
      - asset: assets/fonts/Inter-Bold.ttf
        weight: 700
```

---

## Existing Codebase Usage

### What to Keep (90% of existing code)
✅ **Core architecture:** Clean architecture layers  
✅ **State management:** Riverpod providers  
✅ **Navigation:** GoRouter setup  
✅ **Authentication:** Supabase auth integration  
✅ **Database:** Supabase queries and RLS  
✅ **Chat:** Realtime messaging  
✅ **Verification:** Document upload flow  
✅ **Fleet:** Truck management  
✅ **Offers/Deals:** Negotiation flow  

### What to Update (10% modifications)
🔄 **Design system:** Replace gradients/glass with flat UI  
🔄 **Auth screens:** Remove logo, add email/phone toggle  
🔄 **Trucker home:** New find/results screens with tabs  
🔄 **Supplier loads:** Add Super Truckers tab  
🔄 **Admin:** Add support inbox and approval workflows  

### What to Add (New features)
➕ **Super Loads:** Admin-side management screens  
➕ **Super Truckers:** Supplier-side request flow  
➕ **Support chat:** Admin support inbox + ticket system  
➕ **Profile covers:** Ad placement areas  

---

## Migration from Existing Codebase

### Step 1: Branch Strategy
```bash
git checkout -b feature/v0.02-redesign
```

### Step 2: Update Design System
- Replace `app_colors.dart` with new flat colors
- Remove gradient/glass widgets
- Update `app_theme.dart` with system theme support

### Step 3: Update Auth Screens
- Modify `login_screen.dart` (remove logo, add toggle)
- Modify `signup_screen.dart` (remove logo, add toggle)
- Keep `splash_screen.dart` (logo only here)

### Step 4: Add New Features
- Create `super_loads/` feature folder
- Create `super_truckers/` feature folder
- Create `support/` feature folder

### Step 5: Database Migration
- Run Supabase migration scripts
- Test on staging first
- Deploy to production

---

## Deployment Artifacts

### User App APK
- **File:** `app-user-release.apk`
- **Size:** ~30 MB
- **Package:** `com.transfort.app.user`

### Admin App APK
- **File:** `app-admin-release.apk`
- **Size:** ~30 MB
- **Package:** `com.transfort.app.admin`

---

## Acceptance Criteria

### v0.02 Tech Stack Must Have:
- All existing dependencies compatible
- Flutter 3.38.7 confirmed working
- Both flavors building successfully
- Environment variables configured
- Code generation working
- Tests passing (>70% coverage)
- APKs signed and ready for distribution
