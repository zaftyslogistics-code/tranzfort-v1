# Manual QA Checklist - Transfort v0.02

**Date:** January 27, 2026  
**Version:** 0.02.0  
**Tester:** _______________

## Device Information
- **Device Model:** _______________
- **OS Version:** _______________
- **Screen Size:** _______________
- **Network:** WiFi / 4G / 5G

## Phase 1: Auth & Navigation

### Login Flow
- [ ] Email login works
- [ ] Phone login works
- [ ] Email/Phone toggle switches correctly
- [ ] Password visibility toggle works
- [ ] "Forgot Password" link works
- [ ] Error messages display correctly
- [ ] Loading indicator shows during login
- [ ] Navigation to home after successful login

### Signup Flow
- [ ] Email signup works
- [ ] Phone signup works
- [ ] Name field validation works
- [ ] Email/Phone validation works
- [ ] Password strength indicator works
- [ ] Terms and conditions link works
- [ ] Navigation to OTP for phone signup
- [ ] Navigation to home after successful signup

### OTP Verification
- [ ] 6-digit input boxes work
- [ ] Auto-focus moves between boxes
- [ ] Auto-verify on 6th digit
- [ ] Resend button works
- [ ] 60-second cooldown timer works
- [ ] Error message for invalid OTP
- [ ] Navigation to home after verification

### Theme System
- [ ] System theme works (follows device)
- [ ] Light theme works
- [ ] Dark theme works
- [ ] Theme persists after app restart
- [ ] Theme settings screen accessible
- [ ] Theme changes apply immediately

### Bottom Navigation
- [ ] All 4 tabs visible and labeled correctly
- [ ] Supplier tabs: Post Load, My Loads, Chats, Profile
- [ ] Trucker tabs: Find Loads, My Trips, Chats, Profile
- [ ] Active tab highlighted correctly
- [ ] Navigation between tabs works
- [ ] Tab state persists

## Phase 2: Trucker Experience

### Find Loads
- [ ] From location picker works
- [ ] To location picker works
- [ ] "Use current location" button works
- [ ] "Find Loads" CTA navigates to results
- [ ] Flat design applied correctly

### Results Screen
- [ ] Load cards display correctly
- [ ] All Loads tab shows regular loads
- [ ] Super Loads tab shows premium loads
- [ ] Filter header expands/collapses
- [ ] Truck Type filter works
- [ ] Material filter works
- [ ] Weight filter works
- [ ] Price filter works
- [ ] Empty state shows when no loads

### Load Detail
- [ ] Load information displays correctly
- [ ] Super Load badge shows for premium loads
- [ ] "Chat with us" CTA shows for unapproved truckers
- [ ] Offer/Call CTAs hidden for unapproved on Super Loads
- [ ] Offer/Call CTAs work for approved truckers
- [ ] Supplier info displays correctly
- [ ] Verified badge shows for verified suppliers

## Phase 3: Supplier Experience

### My Loads
- [ ] All Loads tab shows posted loads
- [ ] Super Truckers tab shows promoted loads
- [ ] Load cards display status correctly
- [ ] Offers counter shows on cards
- [ ] "Post Load" FAB works
- [ ] "Request Super Trucker" button works

### Super Trucker Request
- [ ] Bottom sheet opens correctly
- [ ] Option 1: Select existing load works
- [ ] Option 2: Create new load works
- [ ] Radio button selection works
- [ ] Continue button submits request
- [ ] Success message shows

### Post Load
- [ ] From location field works
- [ ] To location field works
- [ ] Material type dropdown works
- [ ] Truck type dropdown works
- [ ] Weight field accepts numbers only
- [ ] Price field (optional) works
- [ ] Max 5 required fields enforced
- [ ] Submit button works
- [ ] Success navigation works

## Phase 4: Admin Features

### Support Inbox
- [ ] All 4 tabs display correctly
- [ ] Stats row shows correct counts
- [ ] Ticket cards display correctly
- [ ] Status filter dropdown works
- [ ] Unread count badge shows
- [ ] Tap on ticket opens detail

### Ticket Detail
- [ ] Ticket info card displays correctly
- [ ] User details show correctly
- [ ] Message thread displays
- [ ] Approve button works (for open tickets)
- [ ] Reject button works (for open tickets)
- [ ] Message input works
- [ ] Send button works

### Super Load Detail
- [ ] Overview tab shows load info
- [ ] Responses tab shows offers
- [ ] Quick stats display correctly
- [ ] Status badges show correctly

## Phase 5: Profile & Social

### Supplier Profile
- [ ] Cover area (180px) displays
- [ ] Ad placement area visible
- [ ] Avatar (80px) overlaps cover correctly
- [ ] Name and verified badge show
- [ ] Location and member since show
- [ ] Bio text displays
- [ ] Stats row shows correct numbers
- [ ] About tab works
- [ ] Ratings tab works
- [ ] History tab works

### Trucker Profile
- [ ] Cover area displays
- [ ] Avatar overlaps correctly
- [ ] Super Trucker badge shows (if applicable)
- [ ] Stats row shows trips/rating
- [ ] All tabs work correctly

### History Timeline
- [ ] Timeline displays chronologically
- [ ] Icons show for each event type
- [ ] Status badges display correctly
- [ ] Non-deletable (no delete option)
- [ ] Loads for supplier history
- [ ] Trips for trucker history

## Design System Verification

### Flat Design
- [ ] No gradients anywhere
- [ ] No glassmorphic effects
- [ ] No shadows (elevation: 0)
- [ ] Border radius: 8px for buttons/inputs
- [ ] Border radius: 12px for cards
- [ ] 1px borders throughout

### Colors
- [ ] Primary color: Dark Teal (#008B8B)
- [ ] Success: Green
- [ ] Warning: Orange
- [ ] Error: Red
- [ ] Info: Blue
- [ ] Text colors correct for light/dark

### Components
- [ ] FlatCard used throughout
- [ ] PrimaryButton: 48px height
- [ ] SecondaryButton: 48px height
- [ ] FlatInput: 48px height
- [ ] Bottom nav: 56px height
- [ ] All thumb-friendly (min 48px touch targets)

## Performance

### Load Times
- [ ] Splash screen < 2 seconds
- [ ] Login screen < 1 second
- [ ] Home screen < 2 seconds
- [ ] Load results < 3 seconds
- [ ] Profile screen < 2 seconds

### Animations
- [ ] Smooth transitions (60 FPS)
- [ ] No jank or stuttering
- [ ] Tab switches smooth
- [ ] Bottom sheet animations smooth

### Memory
- [ ] No memory leaks
- [ ] App doesn't crash
- [ ] No ANR (Application Not Responding)

## Offline Behavior
- [ ] Cached data displays when offline
- [ ] "No internet" message shows
- [ ] Actions queue when offline
- [ ] Sync happens when back online

## Edge Cases
- [ ] Long names don't overflow
- [ ] Long addresses don't overflow
- [ ] Empty states show correctly
- [ ] Error states show correctly
- [ ] Loading states show correctly
- [ ] Very long lists scroll smoothly

## Critical Bugs Found
1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

## High Priority Bugs Found
1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

## Low Priority Issues
1. _______________________________________________
2. _______________________________________________

## Overall Assessment
- [ ] Ready for production
- [ ] Needs minor fixes
- [ ] Needs major fixes
- [ ] Not ready for production

**Notes:**
_______________________________________________
_______________________________________________
_______________________________________________

**Tester Signature:** _______________  
**Date:** _______________
