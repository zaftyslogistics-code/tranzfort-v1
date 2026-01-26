# UI Component Specifications (v0.02) — Flat Design

## Overview
This doc provides detailed specs for each reusable component in the modern flat UI redesign.

---

## 1) Load Card (Flat)

### Layout
```
┌─────────────────────────────────────┐
│ [SUPER LOAD badge]      [Bookmark]  │
│                                     │
│ From City → To City                 │
│ Material Type • Truck Type          │
│                                     │
│ ₹ Price | Weight: 10T | Date        │
│                                     │
│ [Verified] Supplier Name            │
└─────────────────────────────────────┘
```

### Style
- Background: Surface color
- Border: 1px solid Border color
- Border radius: 12px
- Padding: 16px
- Margin bottom: 12px
- Tap state: scale(0.98)

### Elements
- **Badge:** Primary background, white text, 8px padding, 4px radius
- **Icons:** 20px, Secondary text color
- **Title:** Heading 3 (20px, SemiBold)
- **Metadata:** Caption (12px), Secondary text color
- **Price:** Body Large (16px), Primary color, Bold

---

## 2) Bottom Navigation Bar

### Layout
```
┌─────────────────────────────────────┐
│  [Home]  [Loads]  [Chat]  [Notif]  [Profile] │
└─────────────────────────────────────┘
```

### Style
- Height: 56px
- Background: Surface color
- Border top: 1px solid Border color
- Safe area padding: bottom inset

### Items
- Icon: 24px
- Label: Caption (12px)
- Active: Primary color
- Inactive: Secondary text color
- Spacing: Equal distribution

---

## 3) Profile Header (Social Style)

### Layout
```
┌─────────────────────────────────────┐
│                                     │
│        [AD / COVER IMAGE]           │ 180px
│                                     │
├─────────────────────────────────────┤
│      ┌───────┐                      │
│      │ Avatar│                      │ 80px (overlaps)
│      └───────┘                      │
│                                     │
│  Name [Verified]                    │
│  Bio / Location                     │
│                                     │
│  Stats: 120 Loads | 4.8★ | 95%     │
│                                     │
│  [About] [Ratings] [History]       │ Tabs
└─────────────────────────────────────┘
```

### Cover Area
- Height: 180px
- Background: Ad image OR Primary color fallback
- "Sponsored" label: top-right, 8px padding, Caption, white text, semi-transparent black bg

### Avatar
- Size: 80px circle
- Position: overlaps cover bottom by 40px
- Border: 4px solid Surface color
- Image: User photo or initials

### Name Row
- Name: Heading 2 (24px, Bold)
- Verified badge: 16px icon, Success color, inline

### Stats Row
- Layout: Horizontal, equal spacing
- Style: Body (14px), Secondary text color
- Separator: " | "

### Tabs
- Height: 48px
- Style: Underline indicator (Primary, 2px)
- Label: Body (14px), SemiBold when active

---

## 4) Expandable Filter Header

### Collapsed State
```
┌─────────────────────────────────────┐
│ From → To • Truck Type • Date  [▼] │
└─────────────────────────────────────┘
```

### Expanded State
```
┌─────────────────────────────────────┐
│ Filters                        [▲]  │
│                                     │
│ Truck Type: [All ▼]                │
│ Body Type: [All ▼]                 │
│ Material: [All ▼]                  │
│ Weight: [Min] - [Max]              │
│ Price Type: [All ▼]                │
│                                     │
│          [Apply Filters]            │
└─────────────────────────────────────┘
```

### Style
- Background: Surface color
- Border bottom: 1px solid Border color
- Padding: 16px
- Animation: 200ms ease

### Collapsed
- Height: 56px
- Text: Caption (12px), Secondary text color
- Icon: 20px, Primary color

### Expanded
- Height: Auto (max 400px)
- Dropdowns: 48px height each
- Apply button: Primary button, bottom-aligned

---

## 5) Input Field (Flat)

### Style
- Border: 1px solid Border color
- Border radius: 8px
- Height: 48px
- Padding: 12px 16px
- Font: Body (14px)

### States
- **Default:** Border color
- **Focus:** Border → Primary color, 2px width
- **Error:** Border → Error color, helper text below
- **Disabled:** Background → Surface color, opacity 0.5

### Label
- Position: Above input, 4px margin
- Style: Caption (12px), Secondary text color
- Required indicator: " *" in Error color

---

## 6) Button Variants

### Primary Button
```
┌─────────────────────┐
│   Button Text       │ 48px height
└─────────────────────┘
```
- Background: Primary color
- Text: White, Button style (14px, SemiBold)
- Border radius: 8px
- Padding: 0 24px
- Tap state: darken 10%

### Secondary Button
```
┌─────────────────────┐
│   Button Text       │ 48px height
└─────────────────────┘
```
- Background: Transparent
- Border: 1px solid Primary
- Text: Primary color, Button style
- Border radius: 8px
- Tap state: Background → Primary 10% opacity

### Text Button
- Background: Transparent
- Text: Primary color, Button style
- Height: 40px
- Tap state: opacity 0.7

---

## 7) Bottom Sheet (Offer / Action)

### Layout
```
┌─────────────────────────────────────┐
│          [Drag Handle]              │
│                                     │
│  Make an Offer                      │
│                                     │
│  Price (Optional)                   │
│  [₹ ________]                       │
│                                     │
│  Message (Optional)                 │
│  [____________]                     │
│                                     │
│  Select Truck                       │
│  [Truck 1 ▼]                        │
│                                     │
│          [Send Offer]               │
└─────────────────────────────────────┘
```

### Style
- Background: Surface color
- Border radius: 16px (top corners only)
- Max height: 80% of screen
- Padding: 24px
- Drag handle: 32px width, 4px height, Border color

### Rules
- Max 3-5 fields
- Primary CTA at bottom (thumb-friendly)
- Dismissible via drag or backdrop tap

---

## 8) Tab Bar (Secondary Navigation)

### Layout
```
┌─────────────────────────────────────┐
│  All Loads        Super Loads       │
│  ─────────                          │
└─────────────────────────────────────┘
```

### Style
- Height: 48px
- Background: Surface color
- Border bottom: 1px solid Border color

### Tab Item
- Label: Body (14px), SemiBold when active
- Padding: 12px 16px
- Indicator: 2px height, Primary color, bottom-aligned
- Active text: Primary text color
- Inactive text: Secondary text color

---

## 9) Empty State

### Layout
```
┌─────────────────────────────────────┐
│                                     │
│         [Illustration]              │
│                                     │
│      No loads found                 │
│  Try adjusting your filters         │
│                                     │
│       [Clear Filters]               │
└─────────────────────────────────────┘
```

### Style
- Centered vertically
- Illustration: 120px size, Secondary text color
- Title: Heading 3 (20px, SemiBold)
- Subtitle: Body (14px), Secondary text color
- CTA: Secondary button

---

## 10) Loading State (Skeleton)

### Card Skeleton
```
┌─────────────────────────────────────┐
│ ████████████                        │
│ ██████  ████████                    │
│                                     │
│ ████  ████  ████                    │
└─────────────────────────────────────┘
```

### Style
- Background: Border color
- Border radius: 4px
- Animation: shimmer (1.5s infinite)
- Opacity: 0.6

---

## 11) Toast / Snackbar

### Layout
```
┌─────────────────────────────────────┐
│ [Icon] Message text          [✕]   │
└─────────────────────────────────────┘
```

### Style
- Position: Bottom, 16px from edge
- Background: Surface color (elevated)
- Border: 1px solid Border color
- Border radius: 8px
- Padding: 12px 16px
- Shadow: subtle (0 2px 8px rgba(0,0,0,0.1))
- Duration: 3s (auto-dismiss)

### Variants
- Success: Success color icon
- Error: Error color icon
- Info: Info color icon
- Warning: Warning color icon

---

## Implementation Notes
- All components must support Light/Dark themes
- Use const constructors where possible
- Animations: 200-300ms, ease curve
- Tap feedback: scale(0.98) or opacity 0.8
- No gradients, no heavy shadows
