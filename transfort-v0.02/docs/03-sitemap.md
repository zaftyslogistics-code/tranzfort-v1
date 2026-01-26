# Sitemap (v0.02)

## 0) Quick Rules (non-negotiable)
- **Single navigation system**: only GoRouter routes (no `Navigator.push` flows in v0.02).
- **No indefinite loaders**: every async page must have timeout + retry.
- **User/Admin separation**: Admin routes must never be present in User app router.
- **Fast startup**: do not block first frame on storage/network (see `10-performance-startup.md`).

---

# 1) Entry Flows (Public → Auth → Role)

## 1.1 Public / Entry Screens
- Splash (`/splash`)
  - Purpose: first frame + session check
  - Shows: Full logo image (transfort-logo-trans.png)
  - Guard: stays until `hasCheckedAuth=true`
- Login (`/login`)
  - NO logo (logo only on splash)
  - Toggle: Email / Phone
  - Fields: Email/Phone + Password
  - Guard: if authenticated → dashboard routing
- Register (`/signup`)
  - NO logo (logo only on splash)
  - Toggle: Email / Phone
  - Fields: Name + Email/Phone + Password (max 3)
- OTP Verification (`/otp-verification`)
  - 6-digit code input
  - Resend option

## 1.2 Role / Intent Selection
- Intent Selection (`/intent-selection`)
  - Outcome:
    - `user.isSupplierEnabled=true` → Supplier Home
    - `user.isTruckerEnabled=true` → Trucker Home
  - Guard: if role already chosen → skip

## 1.3 User Home Routing
- Supplier Dashboard (`/supplier-dashboard`)
- Trucker Home (Find Loads) (NEW UX) (`/trucker/find`)

---

# 2) Shared Authenticated Areas (Both Supplier + Trucker)

## 2.1 Global Utilities
- Settings (`/settings`)
  - Theme Mode: System / Light / Dark
- Profile (`/profile`)
- Notifications (`/notifications`)
  - Actions: mark all read
- Saved Searches (`/saved-searches`)
- Ratings (`/ratings`)
- Help & Support (`/help`)
- Support Center (NEW) (`/support`)
  - New Support Request (NEW) (`/support/new`)
  - My Support Tickets (NEW) (`/support/tickets`)
  - Support Ticket Thread (NEW) (`/support/tickets/:ticketId`)
- Privacy (`/privacy`)

## 2.2 Chat
- Chat List (`/chat-list`)
  - Shows conversations scoped by user
- Chat Thread (`/chat`)
  - Embedded actions:
    - Send message
    - Mark as read
    - Send Truck Card (creates/updates Deal)

## 2.3 Verification
- Verification Center (`/verification`)
  - Role selection UI (if both roles enabled)
  - Starts document upload
- Document Upload (screen exists: `DocumentUploadScreen`) (v0.02: route required)
- Camera Capture (NEW) (`/verification/camera-capture`)
  - Real-time photo capture used for identity proof (stored and reviewed in admin KYC queue)
- Verification Success (screen exists: `VerificationSuccessScreen`) (v0.02: route required)

## 2.4 Search / Filters
- Filters (`/filters`)

---

# 3) Supplier Journey (User App)

## 3.1 Supplier Home
- Supplier Dashboard (`/supplier-dashboard`)
  - Key sections (v0.02 UX):
    - Quick actions: Post Load, My Loads, Verification, Chat
    - KPIs (optional)

## 3.1.1 Supplier Loads (Tab View)
- My Loads (`/my-loads`)
  - Tabs:
    - Tab A: `All Loads`
    - Tab B: `Super Truckers` (NEW)
  - Super Truckers tab:
    - Shows loads approved for premium trucker matching
    - CTA: "Chat for Super Truck" (if no pending request)

## 3.2 Load Lifecycle (Supplier)

### A) Post Load Wizard
- Post Load wrapper (`/post-load`)
- Post Load Step 1 (`/post-load-step1`)
  - Inputs: title, material, weight, truck type, locations, date, price
- Post Load Step 2 (`/post-load-step2`)
  - Confirm + publish

### B) Manage Loads
- My Loads (`/my-loads`)
  - Tab view: All Loads / Super Truckers
  - Filters by status
  - Open load detail

### B.1) Super Trucker Request (NEW)
- Route: Chat-based (via support)
- Flow:
  1. Supplier clicks "Chat for Super Truck"
  2. Bottom sheet: Choose option
     - Select existing load
     - Create new load
  3. Submit request to admin
  4. Admin reviews via support inbox
  5. Admin approves/rejects/requests more info
  6. If approved: load flagged as `is_super_trucker=true`
  7. Load visible only to verified truckers

### C) Load Detail (Supplier view)
- Load Details (Supplier) (`/load-detail-supplier`)
  - Embedded sub-flows:
    - View offers list
    - Counter offer
    - Reject offer
    - Accept offer
      - Sets load status → `booked`
      - Ensures Deal is created/updated
      - Sends best-effort notification (RPC)
    - Delete load

### E) Supplier Public Profile / Details
- Supplier Profile (existing) (`/supplier-profile/:supplierId`)
  - Shows:
    - Verified badge
    - Ratings summary
    - Operating routes
    - Products handled
    - Active loads
  - CTAs:
    - Call
    - Chat (TODO in current code; v0.02 must implement)

### F) Supplier History / Timeline (NEW)
- History Timeline (NEW) (`/supplier/history`)
  - Non-deletable records (archived, not hard-deleted):
    - loads posted
    - offers received/accepted
    - deals booked/completed
    - ratings received
    - verification events

### D) Deal / RC Share (Supplier)
- Deal is not a separate routed screen today; it is surfaced via:
  - Load detail actions
  - Chat thread actions
  - RC request/approve/revoke flows (provider-driven)

---

# 4) Trucker Journey (User App)

## 4.1 Trucker Home
- Trucker Find Loads (NEW) (`/trucker/find`)
  - Step 1: Select From/To
    - From: city/area selector + “Use current location”
    - To: city/area selector
    - CTA: `Find Loads`
  - Guard (policy): may allow browse without verification; posting/offers may require verification

- Trucker Results (NEW) (`/trucker/results`)
  - Expandable header:
    - Collapsed: route summary chips (From/To, date, truck type)
    - Expanded: filters (truck type, body type, material/load type, weight range, price type)
  - Tabs:
    - Tab A: `All Loads` (normal + super loads mixed)
    - Tab B: `Super Loads`
  - Rules:
    - Super Loads are always visually marked
    - “Nearby” and “Available” sections can be represented as sort modes or top segments

## 4.2 Load Engagement (Trucker)

### A) Load Detail (Trucker view)
- Load Details (Trucker) (`/load-detail-trucker`)
  - Embedded sub-flows:
    - Open chat for load (`getOrCreateChatId` → `/chat`)
    - Make Offer (bottom sheet)
      - Optional price
      - Optional message
      - Optional truck selection (from Fleet)
      - On success: may update load status → `negotiation`
    - Bookmark / share (UI-level)

### A.1 Super Loads Access (Manual Process)
- **No dedicated route/form**
- Super Loads show "Chat with us" CTA
- Admin manually collects bank details + legal docs via support chat
- Admin flags trucker as Super Loads approved (internal)

### B) Fleet Management
- Fleet Management (`/fleet-management`)
  - List trucks
  - Add truck
  - Edit truck
  - Delete truck
- Add Truck (`/add-truck`)
  - Optional documents upload: RC, insurance
- Edit Truck (`/edit-truck/:truckId`)

### D) Trucker Public Profile / Details (NEW)
- Trucker Profile (NEW) (`/trucker-profile/:truckerId`)
  - Shows:
    - Verification status
    - Fleet summary (public-safe)
    - Ratings summary
    - Recent activity (optional)
  - CTAs:
    - Chat
    - Call (if allowed)

### E) Trucker History / Timeline (NEW)
- History Timeline (NEW) (`/trucker/history`)
  - Non-deletable records (archived, not hard-deleted):
    - offers made
    - deals booked/completed
    - ratings received
    - verification events

### C) Trips
- My Trips (`/my-trips`)

---

# 5) Cross-Cutting Business Flows (Offers + Deals)

## 5.1 Offers (Negotiation)
- Trucker creates Offer from Trucker Load Detail
- Supplier manages Offers from Supplier Load Detail
  - statuses observed in UI/actions:
    - `accepted`, `rejected`, `countered` (and active negotiation lifecycle)

## 5.2 Deals (Truck Card / RC Sharing)
- Deal creation/updates triggered by:
  - Supplier accepting offer
  - Chat → “Send Truck Card”
- RC share lifecycle (provider-driven):
  - request RC
  - approve RC
  - revoke RC
  - signed RC URL retrieval (short-lived)

## 5.3 Truck Card Visibility Rules (v0.02)
- Before offer: supplier sees no truck card
- After offer (optional policy): supplier sees limited truck preview
- After deal accepted/booked: supplier sees full truck card (images + vehicle number)

## 5.4 Data Retention / No Hard Delete (v0.02)
- Business history must not be hard-deleted:
  - loads
  - offers
  - deals
  - ratings
  - chat messages
- Only full account deletion may purge data (policy-defined)

---

# 6) Admin App (Separate APK)

## 6.1 Entry
- Admin Splash (`/admin-splash`)
- Admin Login (`/admin-login`)
- Admin Not Authorized (`/admin-not-authorized`)

## 6.2 Admin Modules (Routes)
- Admin Dashboard (Overview) (`/admin/dashboard`)
- KYC Verifications (Queue) (`/admin/verifications`)
  - review documents
  - approve / reject / needs more info
- User Management (`/admin/users`)
- Reports & Moderation (`/admin/reports`)
- Analytics (`/admin/analytics`)
- Load Monitoring (`/admin/loads`)
- System Config (`/admin/config`)
- Manage Admins (`/admin/manage-admins`)

## 6.2.1 Admin Support Chat (Customer Support) (NEW)
- Support Inbox (NEW) (`/admin/support/inbox`)
  - Tabs/Filters:
    - All
    - General Support
    - Super Load Requests (trucker → admin)
    - Super Trucker Requests (supplier → admin)
- Support Ticket Thread (NEW) (`/admin/support/tickets/:ticketId`)
  - Admin actions:
    - Approve (for Super Load/Trucker requests)
    - Reject (with reason)
    - Request More Info (keeps ticket open)
- Notes:
  - This is NOT the marketplace chat.
  - Used for customer support + Super Load/Trucker approvals by support_agent / super_admin.

## 6.3 Super Admin: Super Loads
- Super Loads List (`/admin/super-loads`)
- Super Load Detail (NEW) (`/admin/super-loads/:loadId`)
  - Tabs (v0.02):
    - Overview
    - Responses (Offers)
    - Chats
    - Activity/Audit
- Create Super Load (wizard)
  - Step 1 (`/admin/super-loads/create-step1`)
  - Step 2 (`/admin/super-loads/create-step2`)
- Edit Super Load (wizard)
  - Step 1 (`/admin/super-loads/edit-step1`)
  - Step 2 (`/admin/super-loads/edit-step2`)

## 6.4 Admin Deal / Chat Follow-through (Required for Super Loads)
- Super Load Negotiation Chats (NEW)
  - Load chats list (NEW) (`/admin/super-loads/:loadId/chats`)
  - Super load chat thread (NEW) (`/admin/super-chat/:chatId`)
- Deal / RC actions (provider-driven, surfaced inside chat and/or super load detail)
  - Request RC
  - Approve RC
  - Revoke RC

---

# 7) Route Guards & Access Rules (v0.02)

## 7.1 User App Guards (from current router behavior)
- If not authenticated → force `/login`
- If authenticated but role not chosen → force `/intent-selection`
- If authenticated and Supplier enabled → default to `/supplier-dashboard`
- If authenticated and Trucker enabled → default to `/trucker-feed`
- If authenticated and session is Admin → force `/admin-account-not-allowed`

## 7.2 Admin App Guards (from current admin router behavior)
- Until `hasCheckedAuth=true` and `isLoading=false` → stay on `/admin-splash`
- If not authenticated → `/admin-login`
- If authenticated but `admin == null` → `/admin-not-authorized`
- If authenticated admin → `/admin/dashboard`
- Admin app routes must always be `/admin/*`

---

# 8) Layer Map (Screens → Providers → Domain/Data)

This section exists so every sitemap item maps to code and remains scalable.

## 8.1 Auth
- **Screens**: Splash/Login/Signup/Intent Selection
- **Provider**: `authNotifierProvider`
- **Backend**: Supabase Auth + user/admin profile tables

## 8.2 Loads
- **Screens**:
  - Supplier Dashboard, Trucker Feed
  - Post Load (Step1/Step2)
  - Load Detail (Supplier/Trucker)
  - My Loads
- **Provider**: `loadsNotifierProvider`
- **Use cases**:
  - `GetLoads`, `GetLoadById`, `CreateLoad`, `UpdateLoad`, `DeleteLoad`
- **Data**:
  - `SupabaseLoadsDataSource` → `LoadsRepositoryImpl`

## 8.3 Offers
- **UI surfaced inside**: Load Detail (Supplier/Trucker)
- **Provider**: `offersNotifierProvider`
- **Use cases**:
  - `CreateOffer`, `ListOffersForLoad`, `UpdateOffer`
- **Data**:
  - `SupabaseOffersDataSource` → `OffersRepositoryImpl`

## 8.4 Deals / RC
- **UI surfaced inside**: Chat + Supplier Load Detail
- **Provider**: `dealsNotifierProvider`
- **Data**:
  - `SupabaseDealsDataSource` → `DealsRepositoryImpl`
- **Backend**:
  - uses RPC notifications for RC and offer events (best-effort)

## 8.5 Chat
- **Screens**: Chat List, Chat Thread
- **Provider**: `chatNotifierProvider`, `chatMessagesProvider(chatId)`
- **Use cases**:
  - `GetChats`, `GetChatById`, `GetMessages`, `SendMessage`, `MarkAsRead`
- **Data**:
  - `SupabaseChatDataSource` → `ChatRepositoryImpl`

## 8.6 Fleet
- **Screens**: Fleet Management, Add Truck, Edit Truck
- **Provider**: `fleetNotifierProvider`
- **Data**:
  - `SupabaseFleetDataSource` → `FleetRepositoryImpl`

## 8.7 Notifications
- **Screen**: Notifications
- **Providers**:
  - `notificationsProvider` (Stream)
  - `unreadNotificationsCountProvider` (Future)
  - `markAllNotificationsAsReadProvider`
- **Data**:
  - `NotificationsDataSource`

## 8.8 Verification
- **Screens**: Verification Center, Document Upload, Success
- **Providers**: verification providers live under `features/verification/presentation/providers/*`
- **Backend**: Supabase Storage + verification tables with RLS

---

# 9) v0.02 Cleanup TODOs (Sitemap-driven)

## 9.1 Convert implicit screens into real routes
- Add GoRouter routes for:
  - `DocumentUploadScreen`
  - `VerificationSuccessScreen`
  - `OtpVerificationScreen` (if required)

## 9.2 Remove mixed navigation
- Replace `Navigator.push(MaterialPageRoute(...))` flows with GoRouter routes.

## 9.3 Deep link separation
- User app claims user deep links.
- Admin app must not claim user deep links.
