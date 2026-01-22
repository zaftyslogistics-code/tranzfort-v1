# Naming Conventions Guide

## Overview
This document defines the naming conventions used throughout the Transfort codebase to ensure consistency and readability.

## General Principles
- Use meaningful, descriptive names
- Avoid abbreviations unless widely understood
- Be consistent across the codebase
- Follow Dart/Flutter style guide

## File Naming

### Dart Files
- **Format:** `snake_case.dart`
- **Examples:**
  - `login_screen.dart`
  - `user_profile_provider.dart`
  - `supabase_auth_datasource.dart`

### Test Files
- **Format:** `<name>_test.dart`
- **Examples:**
  - `login_screen_test.dart`
  - `input_validator_test.dart`

### Documentation Files
- **Format:** `SCREAMING_SNAKE_CASE.md` or `kebab-case.md`
- **Examples:**
  - `README.md`
  - `CHANGELOG.md`
  - `naming-conventions.md`

## Class Naming

### Classes
- **Format:** `PascalCase`
- **Examples:**
  - `LoginScreen`
  - `UserProfileProvider`
  - `SupabaseAuthDataSource`

### Abstract Classes
- **Format:** `PascalCase` (no prefix)
- **Examples:**
  - `AuthRepository`
  - `LoadsDataSource`

### Mixins
- **Format:** `PascalCase` (no suffix)
- **Examples:**
  - `ValidationMixin`
  - `LoggerMixin`

## Variable Naming

### Local Variables
- **Format:** `camelCase`
- **Examples:**
  - `userName`
  - `isLoading`
  - `loadCount`

### Private Variables
- **Format:** `_camelCase` (leading underscore)
- **Examples:**
  - `_emailController`
  - `_isInitialized`
  - `_userId`

### Constants
- **Format:** `camelCase` or `SCREAMING_SNAKE_CASE`
- **Examples:**
  - `const maxAttempts = 5;`
  - `static const String API_KEY = 'key';`

### Boolean Variables
- **Prefix:** `is`, `has`, `should`, `can`
- **Examples:**
  - `isLoading`
  - `hasError`
  - `shouldRefresh`
  - `canEdit`

## Function Naming

### Public Functions
- **Format:** `camelCase`
- **Examples:**
  - `getUserProfile()`
  - `validateEmail()`
  - `fetchLoads()`

### Private Functions
- **Format:** `_camelCase` (leading underscore)
- **Examples:**
  - `_initializeService()`
  - `_handleError()`
  - `_buildWidget()`

### Async Functions
- **No special prefix/suffix**
- **Examples:**
  - `Future<User> fetchUser()`
  - `Future<void> saveData()`

### Event Handlers
- **Prefix:** `on` or `handle`
- **Examples:**
  - `onLoginPressed()`
  - `handleSubmit()`
  - `onTextChanged()`

## Widget Naming

### StatelessWidget
- **Format:** `PascalCase` + `Widget` suffix (optional)
- **Examples:**
  - `LoginScreen`
  - `LoadCard`
  - `CustomButton`

### StatefulWidget
- **Format:** `PascalCase` + `Widget` suffix (optional)
- **State class:** `_<WidgetName>State`
- **Examples:**
  - `class ChatScreen extends StatefulWidget`
  - `class _ChatScreenState extends State<ChatScreen>`

### Custom Widgets
- **Descriptive names indicating purpose**
- **Examples:**
  - `GlassmorphicCard`
  - `LoadingOverlay`
  - `EmptyStateWidget`

## Provider Naming

### StateNotifier Providers
- **Format:** `<Feature>NotifierProvider`
- **Examples:**
  - `authNotifierProvider`
  - `loadsNotifierProvider`
  - `fleetNotifierProvider`

### FutureProvider
- **Format:** `<Feature>Provider`
- **Examples:**
  - `userProfileProvider`
  - `loadDetailsProvider`

### StreamProvider
- **Format:** `<Feature>StreamProvider`
- **Examples:**
  - `chatMessagesStreamProvider`
  - `notificationsStreamProvider`

## Repository & DataSource Naming

### Repositories
- **Format:** `<Feature>Repository`
- **Interface:** `<Feature>Repository`
- **Implementation:** `<Feature>RepositoryImpl`
- **Examples:**
  - `abstract class AuthRepository`
  - `class AuthRepositoryImpl implements AuthRepository`

### DataSources
- **Format:** `<Source><Feature>DataSource`
- **Examples:**
  - `SupabaseAuthDataSource`
  - `MockLoadsDataSource`
  - `LocalStorageDataSource`

## Model & Entity Naming

### Models (Data Layer)
- **Format:** `<Name>Model`
- **Examples:**
  - `UserModel`
  - `LoadModel`
  - `TruckModel`

### Entities (Domain Layer)
- **Format:** `<Name>` (no suffix)
- **Examples:**
  - `User`
  - `Load`
  - `Truck`

### DTOs (Data Transfer Objects)
- **Format:** `<Name>Dto`
- **Examples:**
  - `LoginRequestDto`
  - `UserResponseDto`

## Service Naming

### Services
- **Format:** `<Purpose>Service`
- **Examples:**
  - `AnalyticsService`
  - `OfflineService`
  - `BiometricAuthService`

### Utilities
- **Format:** `<Purpose>` (no suffix)
- **Examples:**
  - `InputValidator`
  - `DateFormatter`
  - `Logger`

## Enum Naming

### Enums
- **Format:** `PascalCase`
- **Values:** `camelCase`
- **Examples:**
```dart
enum LoadStatus {
  active,
  expired,
  completed,
  cancelled,
}

enum UserRole {
  supplier,
  trucker,
  admin,
}
```

## Extension Naming

### Extensions
- **Format:** `<Type><Purpose>Extension`
- **Examples:**
```dart
extension StringExtension on String {
  String capitalize() => ...
}

extension DateTimeFormatting on DateTime {
  String toRelativeTime() => ...
}
```

## Directory Naming

### Directories
- **Format:** `snake_case`
- **Examples:**
  - `lib/features/auth/`
  - `lib/core/utils/`
  - `lib/shared/widgets/`

## Asset Naming

### Images
- **Format:** `snake_case.ext`
- **Examples:**
  - `app_logo.png`
  - `truck_icon.svg`
  - `empty_state_illustration.png`

### Icons
- **Format:** `ic_<name>.ext`
- **Examples:**
  - `ic_home.svg`
  - `ic_profile.png`

## Test Naming

### Test Groups
- **Format:** Descriptive string
- **Examples:**
  - `group('InputValidator - Email Validation', () {})`
  - `group('AuthRepository - Login', () {})`

### Test Cases
- **Format:** Descriptive string starting with verb
- **Examples:**
  - `test('validates correct email addresses', () {})`
  - `test('throws error when user not found', () {})`

## Database Naming

### Tables
- **Format:** `snake_case` (plural)
- **Examples:**
  - `users`
  - `loads`
  - `chat_messages`

### Columns
- **Format:** `snake_case`
- **Examples:**
  - `user_id`
  - `created_at`
  - `is_active`

### Foreign Keys
- **Format:** `<table>_id`
- **Examples:**
  - `user_id`
  - `supplier_id`
  - `truck_id`

## API Naming

### Endpoints
- **Format:** `kebab-case`
- **Examples:**
  - `/api/user-profile`
  - `/api/loads/active`

### Query Parameters
- **Format:** `camelCase` or `snake_case`
- **Examples:**
  - `?userId=123`
  - `?page=1&limit=50`

## Comments & Documentation

### Single-line Comments
```dart
// This is a single-line comment
final user = getUser(); // Inline comment
```

### Multi-line Comments
```dart
/// This is a documentation comment
/// It describes the purpose of the class/function
/// 
/// Example:
/// ```dart
/// final validator = InputValidator();
/// validator.validateEmail('test@example.com');
/// ```
class InputValidator {
  // Implementation
}
```

### TODO Comments
```dart
// TODO: Implement error handling
// FIXME: Fix memory leak in this function
// NOTE: This is a temporary workaround
```

## Anti-Patterns to Avoid

❌ **Don't:**
- Use single-letter variables (except in loops: `i`, `j`, `k`)
- Use abbreviations: `usr`, `pwd`, `btn`
- Use Hungarian notation: `strName`, `intCount`
- Mix naming conventions: `user_Name`, `UserID`
- Use generic names: `data`, `temp`, `value`

✅ **Do:**
- Use descriptive names: `userName`, `userCount`
- Be consistent throughout the codebase
- Follow Dart style guide
- Use meaningful variable names
- Add comments for complex logic

## Checklist

- [ ] File names are in snake_case
- [ ] Class names are in PascalCase
- [ ] Variables are in camelCase
- [ ] Private members start with underscore
- [ ] Boolean variables use is/has/should/can prefix
- [ ] Functions are descriptive and use camelCase
- [ ] Constants use SCREAMING_SNAKE_CASE or camelCase
- [ ] Providers follow naming convention
- [ ] Tests are descriptive
- [ ] Database columns use snake_case

---

**Last Updated:** January 22, 2026  
**Version:** 1.0.0
