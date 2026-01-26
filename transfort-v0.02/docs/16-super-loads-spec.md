# Super Loads (v0.02) — Feature + UX Spec

## Purpose
Super Loads are admin-posted marketplace loads used to seed supply/demand, showcase premium postings, and drive faster deals.

## Current State (from existing code)

### What works today
- Admin can:
  - List Super Loads: `AdminSuperLoadsScreen` (`/admin/super-loads`)
  - Create Super Load: reuses Post Load wizard
    - Step 1: `/admin/super-loads/create-step1` (reuses `PostLoadStep1Screen`)
    - Step 2: `/admin/super-loads/create-step2` (reuses `PostLoadStep2Screen`, `forceSuperLoad=true`)
  - Edit Super Load:
    - Step 1: `/admin/super-loads/edit-step1` (existing load passed in `extra`)
    - Step 2: `/admin/super-loads/edit-step2` (`forceSuperLoad=true`)
  - Delete, Clone & Repost (list actions)
- Data model:
  - `loads.is_super_load` boolean
  - `loads.posted_by_admin_id` uuid
  - `Load` entity and `LoadModel` include `isSuperLoad` + `postedByAdminId`
- Security:
  - RLS hardening exists to ensure only super admins can create/update/delete Super Loads.
- Marketplace UI:
  - `LoadCard` shows `SUPER LOAD` badge for `load.isSuperLoad == true`.

### What is missing today (core gaps)
1) **No admin-side “post → manage responses” flow**
- After posting a Super Load, the admin can only return to the list.
- There is no admin screen to:
  - View offers/inquiries against a Super Load
  - Open chat threads related to that Super Load
  - Convert negotiation → booked → completed
  - Manage the deal/RC flow

2) **No explicit “responses” surface area in admin UX**
- Offers exist (created from trucker load detail) but they are only manageable from the Supplier-side load detail screen.
- Admin app currently does not expose Supplier load detail UI.

3) **No canonical “admin acts as supplier” rule set**
- Technically works because Super Loads set `supplier_id = admin user id`.
- But UX and permissions are not specified (who replies, what tone, what audit).

4) **Status lifecycle not designed for Admin workflows**
- Load statuses used today: `active`, `negotiation`, `booked`, `completed` (+ expired).
- We need explicit admin actions to drive these transitions.

---

## v0.02 Target User Journey (end-to-end)

### A) Admin (Super Admin)
1. Create Super Load
2. Immediately land on Super Load Detail
3. Monitor Responses
4. Start/continue Chat with truckers
5. Accept an offer (or counter/reject)
6. Deal created/updated
7. RC share process if needed
8. Mark load booked/completed OR close as expired/cancelled

### B) Trucker
1. See Super Load in feed (badge)
2. Open load detail
3. CTA: Chat / Make offer
4. Chat + send truck card
5. Deal/RC share

---

## Required Screens (v0.02)

### Admin App
1) **Super Loads List** (existing)
- Route: `/admin/super-loads`
- CTA:
  - Primary: `Create`
  - Row actions: `Open`, `Edit`, `Clone & repost`, `Delete`

2) **Super Load Detail (Admin)** (NEW)
- Route: `/admin/super-loads/:loadId`
- Tabs:
  - Overview
  - Responses (Offers)
  - Chats
  - Activity/Audit

3) **Responses (Offers) Tab** (NEW)
- Route: tab within `/admin/super-loads/:loadId`
- Shows list of offers for the load

4) **Chats Tab** (NEW)
- Route: tab within `/admin/super-loads/:loadId`
- Shows chats for the load (or "Open chats" deep links)

5) **Chat Thread (Admin)**
- Option A (fast): reuse existing `/chat` route but inside admin router, with admin-safe chrome.
- Option B (clean): add `/admin/chat/:chatId` dedicated admin chat screen.

6) **Create/Edit Wizard** (existing)
- `/admin/super-loads/create-step1`
- `/admin/super-loads/create-step2`
- `/admin/super-loads/edit-step1`
- `/admin/super-loads/edit-step2`

### User App
- No new screens required for basic flow; existing load detail + chat + offer bottom sheet already supports Super Loads.

---

## Screen-by-Screen UX Spec (Admin)

### 1) Super Loads List (`/admin/super-loads`)
**Goal**: Manage inventory of Super Loads.

**Row content**
- Route summary: `fromCity → toCity`
- Chips: `truckTypeRequired`, `loadType`, optional `price`, `loadingDate`
- Status pill: `Active/Negotiation/Booked/Completed/Expired`
- Badges:
  - `SUPER LOAD`

**CTAs**
- Primary FAB: `Create`
- Row tap: `Open`
- Kebab:
  - `Edit`
  - `Clone & repost`
  - `Delete` (confirm modal)

**Rules**
- Only `super_admin` sees Create/Edit/Delete.
- Non-super admins can view list read-only (optional) or blocked.

**Motion**
- List refresh pull/toolbar.
- Skeleton placeholders for first load.

---

### 2) Super Load Detail (`/admin/super-loads/:loadId`) — NEW
**Goal**: One place for the admin to run the deal lifecycle.

**Header**
- Title: `fromCity → toCity`
- Subheader: `truckTypeRequired • loadType • weight`
- Status pill + expiry date

**Primary CTAs (top right)**
- `Edit`
- `Close` (sets status to cancelled/expired depending on policy)

**Tabs**

#### Tab A: Overview
- Sections:
  - Load details (all fields)
  - Contact preferences
  - Metrics: views, offer count, chat count
  - Timeline: created, last updated

CTAs:
- `View Responses` (jump to Responses tab)
- `View Chats` (jump to Chats tab)

#### Tab B: Responses (Offers)
- List item:
  - Trucker identity (masked or full depending on policy)
  - Price (optional)
  - Message (optional)
  - Truck selected (if provided)
  - Status: pending/countered/accepted/rejected

Item CTAs:
- `Open Chat`
- `Counter`
- `Reject`
- `Accept`

Rules:
- `Accept`:
  - Updates offer status → accepted
  - Updates load status → booked
  - Creates/updates Deal
  - Posts audit log entry

#### Tab C: Chats
- List chats for this load
- Item content:
  - Counterparty (trucker)
  - Last message preview
  - Unread count

Item CTA:
- `Open Chat`

#### Tab D: Activity/Audit
- Show audit logs:
  - super_load_created/updated/deleted
  - offer accepted/rejected/countered
  - rc requested/approved/revoked

---

### 3) Admin Chat Thread (route decision)
**Goal**: allow admin to negotiate and finalize details.

Required features
- Send message
- Mark as read
- Show contextual load banner
- Show “Deal” panel:
  - Truck card sent
  - RC requested/approved/revoked

CTAs
- `Request RC`
- `Approve RC`
- `Revoke RC`

Rules
- Only allowed if admin is super_admin and the chat is for a Super Load.

---

## Screen-by-Screen UX Spec (User / Trucker)

### 1) Trucker Feed (`/trucker-feed`)
- Super Loads appear with badge.
- Ranking rule (recommended): slightly boost Super Loads but never hide relevant normal loads.

### 2) Load Detail (Trucker) (`/load-detail-trucker`)
- If `isSuperLoad=true`:
  - Show badge prominently
  - CTA priority:
    - `Chat` (if allowed)
    - `Make Offer`
    - `Call` (if allowed)

### 3) Make Offer (Bottom Sheet)
Fields (existing)
- Price (optional)
- Message (optional)
- Truck (optional)

Rules
- After successful offer:
  - show success toast
  - optionally open chat CTA

---

## Data & Model Rules

### Load
- `is_super_load` must never be set by non-super-admin.
- `posted_by_admin_id` must be set for Super Loads.
- `supplier_id` is the admin user id for Super Loads (current implementation).

### Offer
- Offer attaches to (load_id, supplier_id, trucker_id).
- For Super Loads, supplier_id = admin user id.

### Deal
- Deal is created/updated when:
  - supplier/admin accepts offer
  - truck card is sent

---

## Required Backend / Policy Checks
- Confirm RLS allows:
  - Truckers to create offers against Super Loads
  - Admin to read offers for their own Super Loads
  - Admin to chat as supplier
- Audit log entries for all admin actions.

---

## Acceptance Criteria
- After creating a Super Load, admin can:
  - See it in list
  - Open detail
  - See offers
  - Open chat
  - Accept/counter/reject
  - Book and complete
- Trucker can:
  - See Super Load badge
  - Make offer
  - Chat

---

## Implementation Decisions (v0.02)

### 1) Super Load Access Process
- **Manual onboarding via "Chat with us" CTA**
- No automated bank details form/gate
- Admin collects:
  - Bank account details
  - Legal documents (photos/scans)
  - Verification status
- Admin approves trucker for Super Loads access via internal flag

### 2) Super Load Negotiation Chat
- Separate admin chat system (see `17-admin-chat-spec.md`)
- Admin routes:
  - `/admin/super-loads/:loadId/chats`
  - `/admin/super-chat/:chatId`

### 3) Contact Method
- **Chat-only** (no call CTA for Super Loads)
- Ensures audit trail and compliance
