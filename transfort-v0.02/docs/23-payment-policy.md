# Payment Policy (v0.02)

## Overview
Transfort does **not** process, track, or facilitate any financial transactions. All payments for Super Loads and Super Truckers are handled externally between parties.

---

## Payment Handling

### For All Transactions (Super Loads & Super Truckers)

#### 1) External Transactions Only
- **No in-app payment processing**
- **No payment tracking features**
- **No escrow or wallet system**

#### 2) Payment Coordination
- Parties coordinate payment details via:
  - Chat (within app)
  - Phone calls
  - External messaging (WhatsApp, etc.)
- Admin collects bank details during approval process (for verification only)

#### 3) Payment Methods (User Choice)
- Bank transfer
- UPI
- Cash on delivery
- Any other method agreed between parties

---

## Admin Role

### During Approval
- Admin collects bank details from truckers (Super Loads) and suppliers (Super Truckers)
- Purpose: Verification and record-keeping only
- **Not used for transaction processing**

### After Deal Completion
- Admin manually marks project as **completed** in admin panel
- Based on:
  - User confirmation via chat/support
  - External payment confirmation (if provided)
  - Mutual agreement between parties

---

## Project Status Tracking

### Status Flow
1. **Active:** Load posted and visible
2. **Negotiation:** Offers being exchanged
3. **Booked:** Deal accepted, work in progress
4. **Completed:** Admin marks as completed (manual)
5. **Cancelled:** Either party cancels

### Completion Criteria
- Admin receives confirmation from both parties
- Payment settled externally
- No disputes pending
- Admin manually updates status to "Completed"

---

## User Expectations

### What Users Should Know
- Transfort is a **marketplace/matching platform only**
- Payment is **user's responsibility**
- Platform does not guarantee payment
- Users should follow standard business practices:
  - Written agreements
  - Advance payments (if applicable)
  - Payment receipts
  - Dispute resolution outside platform

### Disclaimers (Required in UI)
- "Transfort does not process payments. All transactions are between you and the other party."
- "Please ensure payment terms are agreed before starting work."
- "Keep records of all payments for your protection."

---

## Future Considerations (Not v0.02)

### Potential Payment Features (v0.03+)
- Payment gateway integration (if business model changes)
- Escrow service (requires licensing)
- Invoice generation (non-financial, documentation only)
- Payment reminders (notification only, no processing)

### Current Decision
- **v0.02:** No payment features, external only
- **Reason:** Simplicity, compliance, focus on core marketplace

---

## Compliance & Legal

### Platform Liability
- Transfort is not liable for payment disputes
- Users agree to terms of service acknowledging external payments
- Platform provides communication tools only

### Data Handling
- Bank details collected during approval are:
  - Stored securely
  - Used for verification only
  - Not shared with other users
  - Subject to privacy policy

---

## Admin Panel Requirements

### Completion Marking Feature
- Route: `/admin/deals/:dealId/mark-complete`
- Fields:
  - Confirmation checkbox: "Both parties have confirmed completion"
  - Optional notes: Admin can add completion notes
  - Timestamp: Auto-recorded
- Action:
  - Updates deal status to "completed"
  - Sends notification to both parties
  - Logs action in audit trail

### UI Spec
```
┌─────────────────────────────────────┐
│  Mark Deal as Completed             │
│                                     │
│  Deal ID: #12345                    │
│  Supplier: Acme Logistics           │
│  Trucker: Fast Transport            │
│  Load: Mumbai → Delhi               │
│                                     │
│  ☑ Both parties confirmed completion│
│                                     │
│  Notes (Optional):                  │
│  [_________________________]       │
│                                     │
│  [Mark as Completed]                │
└─────────────────────────────────────┘
```

---

## Acceptance Criteria

### v0.02 Must Have:
- No payment processing features in app
- Clear disclaimers about external payments
- Admin can manually mark deals as completed
- Bank details collected during approval (verification only)
- Audit log for all completion actions

### v0.02 Must NOT Have:
- Payment tracking
- Payment reminders
- Invoice generation
- Payment gateway integration
- Escrow or wallet features
