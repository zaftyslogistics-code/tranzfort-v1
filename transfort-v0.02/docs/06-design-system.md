# Design System (v0.02) — Modern Flat UI

## Design Philosophy
**Inspiration:** Facebook, Twitter, LinkedIn — clean, flat, content-first.

**Dropped (from old design):**
- Gradients
- Glassmorphism / glass cards
- Heavy shadows
- Glow effects

**Kept:**
- Dark teal brand colors (from logo/icon)
- Clean, readable typography
- Thumb-friendly navigation
- Fast rendering

---

## Color System

### Brand Colors (Dark Teal)
- **Primary:** `#008B8B` (Dark Cyan / Teal)
- **Primary Dark:** `#006666`
- **Primary Light:** `#00BFBF`
- **Accent:** `#00CED1` (lighter teal for highlights)

### Neutral Palette
- **Background (Light):** `#FFFFFF`
- **Background (Dark):** `#121212`
- **Surface (Light):** `#F5F5F5`
- **Surface (Dark):** `#1E1E1E`
- **Border (Light):** `#E0E0E0`
- **Border (Dark):** `#2C2C2C`

### Semantic Colors
- **Success:** `#10B981` (green)
- **Warning:** `#F59E0B` (amber)
- **Error:** `#EF4444` (red)
- **Info:** `#3B82F6` (blue)

### Text Colors
- **Primary (Light):** `#1F2937`
- **Primary (Dark):** `#F9FAFB`
- **Secondary (Light):** `#6B7280`
- **Secondary (Dark):** `#9CA3AF`

---

## Typography

### Font Family
- **Primary:** Inter / SF Pro / Roboto (system default)
- **Fallback:** System sans-serif

### Scale
- **Heading 1:** 28px, Bold (700)
- **Heading 2:** 24px, Bold (700)
- **Heading 3:** 20px, SemiBold (600)
- **Body Large:** 16px, Regular (400)
- **Body:** 14px, Regular (400)
- **Caption:** 12px, Regular (400)
- **Button:** 14px, SemiBold (600)

### Line Height
- Headings: 1.2
- Body: 1.5
- Captions: 1.4

---

## Component Library

### Cards
**Style:** Flat with subtle border (no shadows, no gradients)
- Background: Surface color
- Border: 1px solid Border color
- Border radius: 12px
- Padding: 16px
- Tap state: scale(0.98) + opacity 0.8

### Buttons

#### Primary Button
- Background: Primary color
- Text: White
- Border radius: 8px
- Height: 48px (thumb-friendly)
- Font: Button style
- Tap state: darken background 10%

#### Secondary Button
- Background: Transparent
- Border: 1px solid Primary
- Text: Primary color
- Border radius: 8px
- Height: 48px

#### Text Button
- Background: Transparent
- Text: Primary color
- No border
- Height: 40px

### Input Fields
- Border: 1px solid Border color
- Border radius: 8px
- Height: 48px
- Padding: 12px 16px
- Focus state: Border color → Primary
- Label: Caption style, Secondary text color

### Bottom Navigation
- Height: 56px
- Icons: 24px
- Active: Primary color
- Inactive: Secondary text color
- Labels: Caption style
- Thumb zone: bottom 80px of screen

### Top App Bar
- Height: 56px
- Background: Surface color
- Border bottom: 1px solid Border color
- Title: Heading 3
- Icons: 24px, Primary text color

---

## Layout Patterns

### Thumb-Friendly Zones
- **Primary actions:** Bottom 25% of screen
- **Navigation:** Bottom bar (56px)
- **Secondary actions:** Top right (within 120px from top)
- **Avoid:** Middle-center for critical CTAs

### Spacing System
- **xs:** 4px
- **sm:** 8px
- **md:** 16px
- **lg:** 24px
- **xl:** 32px
- **2xl:** 48px

### Screen Padding
- Horizontal: 16px
- Vertical: 16px (below app bar)

---

## Profile Header / Cover Area

### Layout (Facebook/Twitter style)
- **Cover area:** 180px height
  - Background: Ad placement OR user-uploaded cover (v0.02: ads only)
- **Avatar:** 80px circle
  - Positioned: overlapping cover bottom by 40px
  - Border: 4px solid Surface color
- **Name + Verified badge:** Below avatar
- **Bio / Stats row:** Below name

### Ad Placement Rules
- **Where:** Profile cover area (Supplier + Trucker profiles)
- **Format:** 16:9 banner (1200x675px recommended)
- **Fallback:** Solid Primary color background if no ad
- **CTA overlay:** Optional "Sponsored" label (top-right, 8px padding)

---

## Navigation Patterns

### Bottom Navigation (Primary)
- **User App:**
  - Home (Supplier Dashboard / Trucker Find)
  - Loads (My Loads / My Trips)
  - Chat
  - Notifications
  - Profile

### Tab Navigation (Secondary)
- Used within screens (e.g., Trucker Results: All Loads / Super Loads)
- Style: Underline indicator (Primary color, 2px height)
- Height: 48px

### No Hamburger Menus
- All primary navigation via bottom bar
- Settings/Support via Profile screen

---

## Form Design Principles

### No Long Forms
- Max 5 fields per screen
- Use multi-step wizards for complex flows
- Auto-save drafts
- Progress indicator for multi-step

### Input Optimization
- Smart defaults
- Autocomplete where possible
- Location picker (map + search)
- Date picker (calendar UI)
- Dropdowns for < 7 options, search for > 7

---

## Accessibility

### Minimum Standards
- **Contrast ratio:** 4.5:1 for body text, 3:1 for large text
- **Tap targets:** Minimum 48x48px
- **Font scaling:** Support system font size preferences
- **Screen reader:** Semantic labels for all interactive elements

---

## Performance
- No gradients = faster rendering
- Flat cards = simpler paint operations
- Const widgets wherever possible
- Image optimization: WebP, lazy loading

---

## Theme Strategy

### Default Behavior
- **System theme:** App follows device Light/Dark mode by default
- **No blocking:** Theme preference loaded asynchronously after first frame
- **Graceful fallback:** If preference not loaded, use system theme

### Manual Override
- **Settings screen:** Theme selector
  - Options: System (default) / Light / Dark
  - Persisted in local storage
  - Applied immediately (no app restart)

### Implementation
```dart
enum AppThemeMode {
  system,  // Follow device (default)
  light,   // Force light mode
  dark,    // Force dark mode
}
```
