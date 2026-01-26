# Super Truckers (v0.02) — Supplier-Side Premium Feature

## Overview
**Super Truckers** is the supplier-side equivalent of Super Loads. It allows suppliers to request premium trucker matching by submitting their loads for admin review and promotion to verified, high-quality truckers.

---

## Concept

### What is a Super Trucker?
- A verified, premium trucker approved by admin
- Has completed bank verification + legal docs
- Receives priority access to high-value loads
- Visible in "Super Truckers" tab for suppliers

### What is a Super Trucker Load Request?
- Supplier submits a load (existing or new) for Super Trucker consideration
- Admin reviews and approves/rejects
- If approved, load is promoted to Super Truckers and shown to verified truckers only

---

## User Journey

### Supplier Side

#### Step 1: Discover Super Truckers
- Route: `/supplier-dashboard` or `/my-loads`
- UI: Tab view
  - Tab A: `All Loads`
  - Tab B: `Super Truckers` (NEW)

#### Step 2: Request Super Trucker for Load
- Supplier sees "Chat for Super Truck" CTA
- Opens chat-based request flow

#### Step 3: Submit Load for Super Trucker
Two options:
1. **Select Existing Load**
   - Dropdown/list of active loads
   - Select one
   - Add optional message
   - Submit

2. **Create New Load for Super Trucker**
   - Same form as regular Post Load (2-step wizard, max 5 fields/step)
   - Flagged as Super Trucker request
   - Submit

#### Step 4: Admin Review
- Admin receives request via support chat
- Admin reviews:
  - Load details
  - Supplier verification status
  - Payment history (optional)
- Admin actions:
  - **Approve:** Load promoted to Super Truckers, visible to verified truckers only
  - **Reject:** Supplier notified with reason
  - **Ask for More Info:** Admin requests clarification (price, dates, docs, etc.)

#### Step 5: Post-Approval
- Load appears in Super Truckers tab
- Only verified truckers (Super Loads approved) can see and interact
- Supplier manages offers/chat normally

---

## Admin Workflow

### Receive Super Trucker Request
- Route: `/admin/support/inbox`
- Request appears as support ticket
- Type: `super_trucker_request`

### Review Request
- Admin opens ticket
- Views:
  - Load details (if new load: full form data; if existing: load ID + link)
  - Supplier profile
  - Verification status
  - Request message

### Admin Actions

#### 1) Approve
- Admin clicks "Approve"
- System:
  - Sets `load.is_super_trucker = true`
  - Sets `load.approved_by_admin_id = admin.id`
  - Sends notification to supplier
  - Closes ticket

#### 2) Reject
- Admin clicks "Reject"
- Admin provides reason (dropdown + optional text)
  - Reasons: Incomplete info, Verification required, Policy violation, Other
- System:
  - Sends notification to supplier with reason
  - Closes ticket

#### 3) Ask for More Info
- Admin clicks "Request Info"
- Admin specifies what's needed (checkboxes + text):
  - Price clarification
  - Loading date confirmation
  - Additional documents
  - Verification completion
  - Other (free text)
- System:
  - Sends message to supplier via chat
  - Ticket remains open
  - Supplier replies via chat
  - Admin reviews again

---

## Data Model

### Load Table Updates
Add fields:
- `is_super_trucker` (boolean, default false)
- `super_trucker_request_status` (enum: null, pending, approved, rejected)
- `super_trucker_approved_by_admin_id` (uuid, nullable)
- `super_trucker_approved_at` (timestamp, nullable)

### Support Tickets Table
Add type:
- `ticket_type` enum: `general_support`, `super_load_request`, `super_trucker_request`

---

## UI Specs

### Supplier Dashboard / My Loads (Tab View)

```
┌─────────────────────────────────────┐
│  All Loads    Super Truckers        │
│  ─────────                          │
├─────────────────────────────────────┤
│                                     │
│  [+ Chat for Super Truck]           │ (if no pending request)
│                                     │
│  ┌───────────────────────────────┐ │
│  │ Load Card (Super Trucker)     │ │
│  │ [SUPER TRUCKER badge]         │ │
│  │ From → To                     │ │
│  │ Status: Active | 3 offers     │ │
│  └───────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

### Chat for Super Truck (Bottom Sheet)

```
┌─────────────────────────────────────┐
│  Request Super Trucker              │
│                                     │
│  Choose an option:                  │
│                                     │
│  ○ Select Existing Load             │
│  ○ Create New Load                  │
│                                     │
│  [Continue]                         │
└─────────────────────────────────────┘
```

#### If "Select Existing Load"
```
┌─────────────────────────────────────┐
│  Select Load                        │
│                                     │
│  [Load 1: Mumbai → Delhi ▼]        │
│                                     │
│  Message (Optional)                 │
│  [_________________________]       │
│                                     │
│  [Submit Request]                   │
└─────────────────────────────────────┘
```

#### If "Create New Load"
- Reuse Post Load wizard (2-step)
- Add hidden flag: `is_super_trucker_request = true`
- On submit: creates load + opens support ticket

---

## Admin Support Inbox (Super Trucker Requests)

```
┌─────────────────────────────────────┐
│  Support Inbox                      │
│  [All] [Super Loads] [Super Truckers] │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ [SUPER TRUCKER]               │ │
│  │ Supplier: Acme Logistics      │ │
│  │ Load: Mumbai → Delhi          │ │
│  │ Status: Pending               │ │
│  │ 2 hours ago                   │ │
│  └───────────────────────────────┘ │
└─────────────────────────────────────┘
```

### Admin Review Screen

```
┌─────────────────────────────────────┐
│  Super Trucker Request              │
│                                     │
│  Supplier: Acme Logistics           │
│  Verified: ✓                        │
│                                     │
│  Load Details:                      │
│  From: Mumbai                       │
│  To: Delhi                          │
│  Material: Steel                    │
│  Truck Type: 20ft Container         │
│  Weight: 15T                        │
│  Price: ₹50,000                     │
│  Date: 2026-02-01                   │
│                                     │
│  Message:                           │
│  "Urgent delivery needed..."        │
│                                     │
│  [Approve] [Reject] [Request Info]  │
└─────────────────────────────────────┘
```

---

## Business Rules

### Eligibility
- Supplier must be verified to request Super Trucker
- Load must meet minimum criteria (price, weight, route)
- Supplier can have max 3 pending Super Trucker requests at a time

### Visibility
- Super Trucker loads visible only to:
  - Verified truckers (Super Loads approved)
  - Admin

### Pricing (Future)
- v0.02: Free (manual approval)
- Future: Paid feature with auto-approval for premium suppliers

---

## Acceptance Criteria

### Supplier Can:
- See Super Truckers tab
- Request Super Trucker via chat
- Submit existing or new load
- Receive approval/rejection notification
- Manage Super Trucker loads normally after approval

### Admin Can:
- See Super Trucker requests in support inbox
- Review load details + supplier profile
- Approve/reject/request more info
- Track approval history

### System Must:
- Flag loads as `is_super_trucker = true` on approval
- Show Super Trucker loads only to verified truckers
- Send notifications on status changes
- Audit log all admin actions

---

## Open Questions for Refinement

1. Should Super Trucker requests have a fee? (v0.02: no, future: yes)
2. Should suppliers see a preview of verified truckers before requesting? (v0.02: no)
3. Should there be a "Super Trucker badge" for truckers in search results? (v0.02: yes, in profile)
4. Auto-approval criteria for trusted suppliers? (v0.02: no, all manual)
