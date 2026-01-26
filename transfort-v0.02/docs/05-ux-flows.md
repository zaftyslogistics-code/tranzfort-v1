# UX Flows (v0.02) — Modern Flat UI

## Design Principles
- **Flat design:** No gradients, no glassmorphism
- **Thumb-friendly:** Primary actions in bottom 25% of screen
- **Short forms:** Max 5 fields per screen, multi-step wizards
- **Bottom navigation:** All primary nav at bottom (no hamburger menus)
- **Card-based:** Flat cards with subtle borders

---

## Auth Flow
1. Splash (shows logo image, session check)
2. Login / Signup (NO logo, Email/Phone toggle)
3. OTP Verification (if phone signup)
4. Intent Selection (Supplier / Trucker)
5. App Home

---

## Trucker Flow: Find Loads (Redesigned)

### Step 1: Find Loads Entry
- Route: `/trucker/find`
- Inputs:
  - From (location picker)
  - To (location picker)
  - CTA: "Find Loads" (bottom, thumb-friendly)

### Step 2: Results
- Route: `/trucker/results`
- Layout:
  - Expandable filter header (collapsed by default)
  - Tabs: All Loads / Super Loads
  - Load cards (flat, bordered)

### Step 3: Load Detail
- Route: `/load-detail-trucker`
- CTAs:
  - Make Offer (bottom sheet, max 3 fields)
  - Chat
  - (Super Loads: "Chat with us" if not approved)

---

## Supplier Flow: Post Load (Simplified)

### Step 1: Basic Info
- Max 5 fields:
  - From/To (location pickers)
  - Material type (dropdown)
  - Truck type (dropdown)
  - Weight (number input)
- CTA: "Next" (bottom)

### Step 2: Details
- Max 5 fields:
  - Price (optional)
  - Loading date (date picker)
  - Notes (text area, 200 char limit)
  - Contact preferences (toggles)
- CTA: "Post Load" (bottom)

### Step 3: Published
- Success screen
- CTAs:
  - View Load
  - Post Another

---

## Super Truckers Flow (Supplier Side)

### Step 1: Discover Super Truckers
- Route: `/my-loads`
- Tab view: All Loads / Super Truckers
- CTA: "Chat for Super Truck"

### Step 2: Request Super Trucker
- Bottom sheet opens
- Choose:
  - Select existing load (dropdown)
  - Create new load (wizard)
- Add optional message
- Submit request

### Step 3: Admin Review
- Admin receives request in support inbox
- Admin reviews load + supplier profile
- Admin actions:
  - Approve → load becomes Super Trucker load
  - Reject → supplier notified with reason
  - Request info → chat continues

### Step 4: Post-Approval
- Load appears in Super Truckers tab
- Visible only to verified truckers
- Supplier manages normally (offers/chat/deals)

---

## Verification Flow (Unchanged)
- User: Request verification -> Upload docs -> Camera capture -> Pending
- Admin: Queue -> Review -> Approve/Deny -> Audit trail

---

## Super Loads Access (Manual)

### Trucker Side
1. Trucker sees Super Load in results (badge)
2. Opens Super Load detail
3. If not approved: "Chat with us" CTA (prominent)
4. Trucker initiates support chat
5. Admin collects bank details + legal docs manually
6. Admin flags trucker as approved
7. Trucker can now interact with Super Loads

### Admin Side
1. Support chat request received
2. Admin collects:
   - Bank account details
   - Legal documents (photos/scans)
3. Admin verifies and approves
4. Admin sets internal flag: `super_loads_approved = true`

---

## Profile UX (Social Style)

### Layout
- Cover area (180px): Ad placement
- Avatar (80px): Overlaps cover
- Name + Verified badge
- Stats row (loads posted, rating, completion %)
- Tabs: About / Ratings / History

### Navigation
- Bottom nav: Home / Loads / Chat / Notifications / Profile
- No hamburger menu
- Settings/Support accessed via Profile screen

---

## UX Requirements (Non-Negotiable)

### Every Async Screen Must Have:
- Explicit loading state (skeleton or spinner)
- Timeout + retry (max 30s)
- Empty state (with illustration + CTA)
- Error state (with actionable message)

### Form Rules:
- Max 5 fields per screen
- Auto-save drafts
- Smart defaults
- Inline validation
- Clear error messages

### Thumb-Friendly:
- Primary CTAs: Bottom 25% of screen
- Minimum tap target: 48x48px
- Bottom nav: 56px height
- No critical actions in middle-center
