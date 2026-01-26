# One-Pager Sitemap (v0.02)

## Entry
- Splash (logo image only)
- Login / Signup (NO logo, Email/Phone toggle)
- OTP Verification
- Intent Selection (Supplier / Trucker)
- Verification Center (Supplier / Trucker)

## Trucker App
- Trucker Home (Find Loads)
  - From/To selector
  - Results (Nearby + Available)
  - Filters (expandable header)
  - Tabs: All Loads / Super Loads
- Super Loads Access (Manual)
  - "Chat with us" CTA
  - Admin collects bank details + docs
  - Admin approves internally
- Load Detail (Trucker)
  - Offer (bottom sheet, max 3 fields)
  - Chat
  - Truck Card (share)
- Fleet
  - Trucks
  - Documents
- Trucker Profile (social-style)
  - Cover: Ad placement
  - Avatar + Stats
  - Tabs: About / Ratings / History

## Supplier App
- Supplier Dashboard
- Post Load (2-step wizard, max 5 fields/step)
- My Loads (Tab view)
  - All Loads
  - Super Truckers (NEW)
    - "Chat for Super Truck" CTA
    - Submit existing/new load for premium trucker matching
    - Admin approval workflow
- Load Detail (Supplier)
  - Offers
  - Chat
  - Deal / RC share
- Supplier Profile (social-style)
  - Cover: Ad placement
  - Avatar + Stats
  - Tabs: About / Ratings / History

## Shared
- Chat List / Thread
- Notifications
- Settings
- Support Center
- Saved Searches

## Admin App
- Admin Dashboard
- Verifications Queue
- Super Loads
  - Inventory
  - Responses
  - Super Load Negotiation Chat
- Admin Support Inbox
- Users / Reports / Analytics

## Design System (v0.02)
- **Flat UI:** No gradients, no glassmorphism
- **Colors:** Dark teal brand (#008B8B)
- **Cards:** Flat with subtle borders
- **Navigation:** Bottom bar (thumb-friendly)
- **Forms:** Max 5 fields per screen
- **Profiles:** Facebook/Twitter style with ad placement in cover area

## Cross-Cutting Data Rules
- No hard delete for business history (loads/offers/deals/ratings/messages) except on full account deletion.
- Feature flags + paid tiers (AI-ready).
