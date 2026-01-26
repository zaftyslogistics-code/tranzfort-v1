# App Redesign Notes (v0.02) — Modern UX + AI-Ready

## Goal
Redesign Transfort UX to feel modern, fast, and scalable while keeping the core logistics marketplace flows intact.

---

## 1) Trucker Landing Redesign (Primary)

### 1.1 New Trucker first-run flow
- Signup/Login
- Intent Selection → choose Trucker
- If trucker verification is required: prompt but do not block browsing unless policy requires.
- Go to **Find Loads** entry screen.

### 1.2 Find Loads (NEW)
- Route: `/trucker/find`
- Primary input: **From** + **To** (location selectors)
- CTA:
  - `Find Loads`
- Secondary CTAs:
  - `Use current location` (sets From)
  - `Saved routes`

### 1.3 Load Results (NEW)
- Route: `/trucker/results`
- Layout:
  - Top area: **expandable header**
    - collapsed: summary pills (From/To, date, truck type)
    - expanded: full filters
  - Below header: **Tab bar**
    - Tab 1: `All Loads` (normal + super loads mixed)
    - Tab 2: `Super Loads`

### 1.4 Super Loads Access — Manual Process
- **No automated gate or form**
- Super Loads show \"Chat with us\" CTA if trucker not approved
- Admin manually collects via support chat:
  - Bank account details
  - Legal documents (photos/scans as required)
- Admin approves trucker internally
- Once approved, trucker can interact with Super Loads normally

---

## 2) Social-Style Profiles (Supplier + Trucker)

### 2.1 Profile UX (Facebook-style)
Profile pages should present:
- Cover area + avatar
- Verified badge + verification status
- Bio + location
- Stats:
  - Supplier: loads posted, completion rate, avg rating
  - Trucker: trips completed, on-time %, avg rating
- Tabs:
  - About
  - Ratings
  - History

### 2.2 Verification photo (real-time camera)
- During verification, capture a live camera photo and store as proof.
- Route additions:
  - `/verification/camera-capture` (NEW)

---

## 3) Non-Deletable History System (Long-term trust)

### 3.1 Principle
Business events must not be hard-deleted. They are archived.

### 3.2 History feed (both roles)
- Shows timeline of:
  - loads posted / offers made / deals booked
  - ratings received
  - verification events

---

## 4) Truck Cards (Trust UX)

### 4.1 Truck Card content
Supplier should be able to view a truck card containing:
- Truck images
- Vehicle number
- Basic truck type

### 4.2 Visibility rules
- Before offer: hidden
- After offer: preview allowed (policy)
- After deal accepted/booked: full truck card (images + number)

---

## 5) AI-Ready Foundations (Paid users future)

### 5.1 Required platform hooks
- Event stream (audit + product analytics)
- Feature flags / entitlements
- Message metadata support (for summarization)
- Clean boundaries for AI services (Edge Function / separate microservice)

### 5.2 Candidate AI features
- Load matching suggestions
- Price guidance
- Chat summarization
- Auto-fill for load posting
- Fraud risk signals
