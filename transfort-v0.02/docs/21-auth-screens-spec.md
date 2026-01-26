# Auth Screens Specification (v0.02) — Simplified & Modern

## Overview
Redesigned auth flow with cleaner UX: logo only on splash, email/phone choice on login/signup, system theme with manual override.

---

## 1) Splash Screen

### Purpose
- App initialization
- Session check
- Brand presentation

### Layout
```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│                                     │
│          [TRANSFORT LOGO]           │ (Full logo image)
│                                     │
│                                     │
│                                     │
│         Loading...                  │
└─────────────────────────────────────┘
```

### Specs
- **Logo:** Full brand logo image (transfort-logo-trans.png)
- **Size:** 360px × 112px (2x original)
- **Position:** Center
- **Background:** Solid color (Primary or Background color, no gradient)
- **Loading indicator:** Small spinner below logo (optional)
- **Duration:** Max 3 seconds, then redirect

### Behavior
- Check session
- If authenticated → App Home
- If not authenticated → Login

---

## 2) Login Screen

### Purpose
- User authentication
- Email or Phone choice

### Layout
```
┌─────────────────────────────────────┐
│                                     │
│  Welcome Back                       │ (Heading 1)
│  Sign in to continue                │ (Body, Secondary)
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ○ Email    ○ Phone          │   │ (Toggle)
│  └─────────────────────────────┘   │
│                                     │
│  [Email / Phone input]              │
│  [Password input]                   │
│                                     │
│  [Forgot Password?]                 │ (Text button, right)
│                                     │
│  [Sign In]                          │ (Primary button)
│                                     │
│  Don't have an account? [Sign Up]   │
│                                     │
└─────────────────────────────────────┘
```

### Specs
- **NO LOGO** (logo only on splash)
- **Title:** "Welcome Back" (Heading 1, 28px, Bold)
- **Subtitle:** "Sign in to continue" (Body, 14px, Secondary text)
- **Toggle:** Email / Phone (segmented control, 48px height)
- **Input fields:** 48px height, border radius 8px
- **Primary CTA:** "Sign In" (bottom, thumb-friendly)
- **Background:** Solid Background color (no gradient)

### Behavior
- Toggle switches input type:
  - Email: email input + password
  - Phone: country code + phone number + OTP (or password)
- Forgot Password: opens reset flow
- Sign Up: navigates to `/signup`

---

## 3) Signup Screen

### Purpose
- New user registration
- Email or Phone choice

### Layout
```
┌─────────────────────────────────────┐
│                                     │
│  Create Account                     │ (Heading 1)
│  Join Transfort today               │ (Body, Secondary)
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ○ Email    ○ Phone          │   │ (Toggle)
│  └─────────────────────────────┘   │
│                                     │
│  [Name input]                       │
│  [Email / Phone input]              │
│  [Password input]                   │
│                                     │
│  [Sign Up]                          │ (Primary button)
│                                     │
│  Already have an account? [Sign In] │
│                                     │
└─────────────────────────────────────┘
```

### Specs
- **NO LOGO** (logo only on splash)
- **Title:** "Create Account" (Heading 1, 28px, Bold)
- **Subtitle:** "Join Transfort today" (Body, 14px, Secondary text)
- **Toggle:** Email / Phone (segmented control, 48px height)
- **Max 3 fields:** Name, Email/Phone, Password
- **Primary CTA:** "Sign Up" (bottom, thumb-friendly)
- **Background:** Solid Background color (no gradient)

### Behavior
- Toggle switches input type:
  - Email: email + password → verify email
  - Phone: country code + phone → OTP verification
- On success: navigate to Intent Selection

---

## 4) OTP Verification Screen

### Purpose
- Verify phone number

### Layout
```
┌─────────────────────────────────────┐
│                                     │
│  Verify Your Number                 │ (Heading 1)
│  Enter the 6-digit code sent to     │
│  +91 98765 43210                    │
│                                     │
│  ┌───┬───┬───┬───┬───┬───┐         │
│  │ _ │ _ │ _ │ _ │ _ │ _ │         │ (OTP input)
│  └───┴───┴───┴───┴───┴───┘         │
│                                     │
│  Didn't receive? [Resend]           │ (Text button)
│                                     │
│  [Verify]                           │ (Primary button)
│                                     │
└─────────────────────────────────────┘
```

### Specs
- **Title:** "Verify Your Number"
- **OTP input:** 6 boxes, auto-focus, numeric keyboard
- **Resend:** Text button, 30s cooldown
- **Primary CTA:** "Verify"

---

## 5) Forgot Password Screen

### Layout
```
┌─────────────────────────────────────┐
│                                     │
│  Reset Password                     │ (Heading 1)
│  Enter your email to receive        │
│  a reset link                       │
│                                     │
│  [Email input]                      │
│                                     │
│  [Send Reset Link]                  │ (Primary button)
│                                     │
│  [Back to Sign In]                  │ (Text button)
│                                     │
└─────────────────────────────────────┘
```

---

## Icon vs Logo Usage

### App Icon (Launcher Icon)
- **File:** `transfort-icon.png`
- **Usage:** Android/iOS app icon only
- **Format:** Square, 1024x1024px
- **Design:** Icon/symbol only (no text)

### Logo (Brand Mark)
- **File:** `transfort-logo-trans.png`
- **Usage:** Splash screen only
- **Format:** Horizontal, transparent background
- **Design:** Full logo with text

### Rule
- **Splash:** Logo image
- **Login/Signup:** NO logo
- **App Icon:** Icon only

---

## Theme System

### Default Behavior
- **System theme:** Follows device Light/Dark mode
- **No blocking:** Theme loaded asynchronously after first frame

### Manual Override
- **Settings screen:** Theme toggle
  - Options: System / Light / Dark
  - Persisted in local storage
  - Applied immediately (no restart)

### Implementation
```dart
enum ThemeMode {
  system,  // Follow device
  light,   // Force light
  dark,    // Force dark
}
```

---

## Accessibility

### All Auth Screens Must Have:
- Minimum 48px tap targets
- 4.5:1 contrast ratio for text
- Screen reader labels
- Keyboard navigation support (web)
- Auto-focus on first input
- Clear error messages

---

## Error Handling

### Common Errors
- Invalid email/phone format
- Weak password
- User already exists
- Invalid OTP
- Network error

### Error Display
- Inline below input field
- Red text (Error color)
- Icon + message
- Clear, actionable text

Example:
```
[Email input with error border]
⚠ Please enter a valid email address
```

---

## Acceptance Criteria

### Splash Screen:
- Shows logo image (not icon)
- Max 3s duration
- Redirects based on session

### Login/Signup:
- NO logo displayed
- Email/Phone toggle works
- Max 3 fields per screen
- Primary CTA at bottom (thumb-friendly)
- Solid background (no gradient)

### Theme:
- Defaults to system theme
- Manual override in Settings
- No blocking on startup

### Icon/Logo:
- App icon: icon only
- Splash: logo image
- Login/Signup: no logo
