# Transfort v0.02 Development TODO

**Project:** Transfort v0.02 - Modern Flat UI Redesign + Premium Features  
**Start Date:** TBD  
**Target Completion:** 4-6 weeks  
**Status:** Planning Phase Complete

---

## Development Phases

### Phase 1: Foundation & Setup (Week 1)
**Goal:** Prepare codebase and infrastructure for v0.02 development

#### 1.1 Project Setup
- [x] Create `feature/v0.02-redesign` branch from `main`
- [ ] Review and update all v0.02 documentation
- [ ] Set up staging Supabase project
- [ ] Configure CI/CD pipeline (GitHub Actions)
- [ ] Set up test coverage reporting

#### 1.2 Database Migration
- [x] Write migration scripts for new fields:
  - [x] `loads`: Add Super Load/Trucker fields
  - [x] `users`: Add bank details + approval flags
  - [x] `support_tickets`: Create new table
  - [x] `support_messages`: Create new table
- [ ] Test migrations on local Supabase
- [ ] Deploy migrations to staging
- [x] Create RLS policies for new tables
- [ ] Test RLS policies with different roles
- [x] Create indexes for performance

#### 1.3 Design System Update
- [x] Update `app_colors.dart` with flat color palette
- [x] Remove gradient/glass widgets from `shared/widgets/` (deprecated)
- [x] Create new flat card components
- [x] Update `app_theme.dart` with system theme support
- [x] Update bottom navigation component
- [x] Create profile header component (with ad placement)
- [x] Update button styles (flat, 48px height)
- [x] Update input field styles (flat, 48px height)

**Acceptance Criteria:**
- ✅ Migrations run successfully on staging
- ✅ All RLS policies tested and working
- ✅ Design system components documented
- [ ] CI/CD pipeline passing (pending setup)

---

### Phase 2: Auth & Navigation Redesign (Week 2)
**Goal:** Implement redesigned auth screens and navigation patterns

#### 2.1 Auth Screens Redesign
- [x] Update `splash_screen.dart`:
  - [x] Show logo image only (360×112px)
  - [x] Remove gradient background
  - [x] Flat design
- [x] Create `login_screen_v2.dart`:
  - [x] Remove logo
  - [x] Add Email/Phone segmented toggle
  - [x] 2 fields only (Email/Phone + Password)
  - [x] Apply flat design
- [x] Create `signup_screen_v2.dart`:
  - [x] Remove logo
  - [x] Add Email/Phone segmented toggle
  - [x] Max 3 fields (Name, Email/Phone, Password)
  - [x] Apply flat design
- [ ] Create `otp_verification_screen.dart`:
  - [ ] 6-digit input boxes
  - [ ] Resend button with cooldown
  - [ ] Apply flat design

#### 2.2 Bottom Navigation
- [x] `AppBottomNavigation` widget (already exists)
- [x] User app nav items:
  - [x] Home (Supplier Dashboard / Trucker Find)
  - [x] Loads (My Loads / My Trips)
  - [x] Chat
  - [x] Profile
- [x] Flat design colors applied
- [x] 56px height (thumb-friendly)

#### 2.3 Theme System
- [x] Implement system theme detection
- [x] Add theme toggle in Settings (ThemeSettingsScreen)
- [x] Persist theme preference (SharedPreferences)
- [x] Test Light/Dark/System modes
- [x] Theme changes apply immediately (no restart)

**Acceptance Criteria:**
- ✅ Auth screens match new design specs
- ✅ Email and Phone login both working
- ✅ Bottom navigation functional
- ✅ Theme switching works without restart

---

### Phase 3: Trucker Experience Redesign (Week 3)
**Goal:** Implement new Trucker find/results flow with Super Loads

#### 3.1 Trucker Find Loads
- [ ] Create `TruckerFindScreen` (`/trucker/find`):
  - [ ] From location picker
  - [ ] To location picker
  - [ ] "Use current location" button
  - [ ] "Find Loads" CTA (bottom, thumb-friendly)
- [ ] Update router to use new Trucker home

#### 3.2 Trucker Results
- [ ] Create `TruckerResultsScreen` (`/trucker/results`):
  - [ ] Expandable filter header
  - [ ] Tab bar: All Loads / Super Loads
  - [ ] Flat load cards
  - [ ] Infinite scroll pagination
- [ ] Implement filter logic
- [ ] Implement tab switching

#### 3.3 Super Loads (Trucker Side)
- [x] Create `LoadDetailScreenV2`:
  - [x] Show "Chat with us" CTA if Super Load and not approved
  - [x] Hide offer/chat CTAs if not approved
- [x] Super Loads approval check logic
- [x] Flat design with info cards

#### 3.4 Bank Details (Manual Collection)
- [x] No automated form (manual via chat)
- [x] Admin collects bank details via support chat
- [x] Admin sets `super_loads_approved` flag manually

**Acceptance Criteria:**
- ✅ Trucker can find loads by route
- ✅ Filters working correctly
- ✅ Super Loads tab shows only to approved truckers
- ✅ "Chat with us" CTA opens support chat

---

### Phase 4: Supplier Experience + Super Truckers (Week 4)
**Goal:** Add Super Truckers feature and update Supplier UI

#### 4.1 Supplier Loads Tab View
- [x] Create `MyLoadsScreenV2`:
  - [x] Add tab bar: All Loads / Super Truckers
  - [x] Show "Request Super Trucker" CTA
- [x] Apply flat design to load cards
- [x] Status badges and offers counter

#### 4.2 Super Trucker Request Flow
- [x] Create `SuperTruckerRequestBottomSheet`:
  - [x] Option 1: Select existing load
  - [x] Option 2: Create new load
  - [x] Submit button
- [x] Integrate with support chat system
- [x] Create support ticket on submission

#### 4.3 Post Load Wizard Update
- [x] Create `PostLoadScreenV2` with flat design
- [x] Simplified single-page form
- [x] Max 5 required fields enforced
- [x] Bottom CTA in thumb zone

#### 4.4 Support Chat Integration
- [x] Create `SupportChatScreen`
- [x] Message bubbles (admin/user)
- [x] Context banners for ticket types
- [x] Flat design

**Acceptance Criteria:**
- ✅ Supplier can request Super Trucker for loads
- ✅ Request creates support ticket
- ✅ Post load wizard follows flat design
- ✅ Max 5 fields per screen enforced
- ✅ Support chat functional

---

### Phase 5: Admin Features (Week 5)
**Goal:** Implement admin support inbox and approval workflows

#### 5.1 Admin Support Inbox
- [ ] Create `AdminSupportInboxScreen` (`/admin/support/inbox`):
  - [ ] Tabs: All / General / Super Loads / Super Truckers
  - [ ] Ticket list with filters
  - [ ] Search functionality
- [ ] Create `AdminSupportTicketScreen` (`/admin/support/tickets/:ticketId`):
  - [ ] Show ticket details
  - [ ] Show requester profile
  - [ ] Show load details (if applicable)
  - [ ] Action buttons: Approve / Reject / Request Info

#### 5.2 Super Load Management
- [ ] Create `AdminSuperLoadDetailScreen` (`/admin/super-loads/:loadId`):
  - [ ] Tabs: Overview / Responses / Chats / Activity
  - [ ] Show offers list
  - [ ] Show chats list
  - [ ] Admin actions

#### 5.3 Approval Workflows
- [ ] Implement Super Load approval logic
- [ ] Implement Super Trucker approval logic
- [ ] Create audit log entries for all actions
- [ ] Send notifications on approval/rejection

#### 5.4 Admin Chat
- [ ] Create `AdminSuperChatScreen` (`/admin/super-chat/:chatId`)
- [ ] Implement chat UI for admin
- [ ] Add deal/RC action buttons

**Acceptance Criteria:**
- ✅ Admin can view all support tickets
- ✅ Admin can approve/reject Super Load/Trucker requests
- ✅ Audit logs created for all admin actions
- ✅ Notifications sent to users on status change

---

### Phase 6: Profile & Social Features (Week 6)
**Goal:** Implement social-style profiles with ad placements

#### 6.1 Profile Redesign
- [ ] Update `SupplierProfileScreen`:
  - [ ] Cover area (180px) with ad placement
  - [ ] Avatar (80px) overlapping cover
  - [ ] Name + verified badge
  - [ ] Stats row
  - [ ] Tabs: About / Ratings / History
- [ ] Create `TruckerProfileScreen` (similar layout)
- [ ] Update `ProfileScreen` (own profile)

#### 6.2 History Timeline
- [ ] Create `SupplierHistoryScreen` (`/supplier/history`)
- [ ] Create `TruckerHistoryScreen` (`/trucker/history`)
- [ ] Show non-deletable business records

#### 6.3 Ad Integration
- [ ] Implement ad placeholder in profile covers
- [ ] Add "Sponsored" label
- [ ] Test ad display (no actual ads in v0.02)

**Acceptance Criteria:**
- ✅ Profiles match Facebook/Twitter style
- ✅ Ad placement areas functional
- ✅ History timeline shows all records
- ✅ No hard delete for business records

---

### Phase 7: Testing & QA (Week 7)
**Goal:** Comprehensive testing and bug fixes

#### 7.1 Unit Tests
- [ ] Auth providers
- [ ] Super Loads providers
- [ ] Super Truckers providers
- [ ] Support chat providers
- [ ] Achieve >70% coverage

#### 7.2 Widget Tests
- [ ] Auth screens
- [ ] Trucker find/results screens
- [ ] Supplier loads screens
- [ ] Admin support inbox
- [ ] Profile screens

#### 7.3 Integration Tests
- [ ] Login/Signup flow
- [ ] Trucker find loads flow
- [ ] Super Loads request flow
- [ ] Super Truckers request flow
- [ ] Admin approval workflow

#### 7.4 Manual QA
- [ ] Test on physical Android devices (min 3 devices)
- [ ] Test on physical iOS devices (min 2 devices)
- [ ] Test all user roles (Supplier, Trucker, Admin)
- [ ] Test Light/Dark themes
- [ ] Test offline behavior
- [ ] Test performance (load times, animations)

#### 7.5 Bug Fixes
- [ ] Fix all critical bugs
- [ ] Fix all high-priority bugs
- [ ] Document known issues (low priority)

**Acceptance Criteria:**
- ✅ All tests passing
- ✅ >70% code coverage
- ✅ No critical bugs
- ✅ Performance acceptable (< 3s load times)

---

### Phase 8: Deployment & Launch (Week 8)
**Goal:** Deploy to production and monitor

#### 8.1 Pre-Deployment
- [ ] Create `release/v0.02.0` branch
- [ ] Update version in `pubspec.yaml` to `0.02.0`
- [ ] Update changelog
- [ ] Build release APKs (user + admin)
- [ ] Test APKs on physical devices
- [ ] Run database migration on production (with backup)

#### 8.2 Deployment
- [ ] Merge to `main`
- [ ] Tag release: `git tag v0.02.0`
- [ ] Push tag: `git push origin v0.02.0`
- [ ] Upload User APK to Play Store (internal testing)
- [ ] Upload Admin APK to internal distribution
- [ ] Merge back to `develop`

#### 8.3 Post-Deployment
- [ ] Monitor crash reports (24 hours)
- [ ] Monitor user feedback
- [ ] Monitor server metrics
- [ ] Hotfix if critical issues
- [ ] Update release notes

#### 8.4 Documentation
- [ ] Update README
- [ ] Update API documentation
- [ ] Update user guides
- [ ] Update admin guides

**Acceptance Criteria:**
- ✅ APKs uploaded successfully
- ✅ No critical crashes in first 24 hours
- ✅ Database migration successful
- ✅ All documentation updated

---

## Dependencies & Blockers

### Critical Path
1. Database migration must complete before feature development
2. Design system must be ready before UI work
3. Auth redesign must complete before navigation changes
4. Admin features depend on support chat system

### External Dependencies
- Supabase staging environment
- Play Store developer account
- Test devices availability

### Risk Mitigation
- Daily standups to track progress
- Weekly demos to stakeholders
- Rollback plan for each phase
- Staging environment for testing

---

## Success Metrics

### Technical Metrics
- [ ] >70% test coverage
- [ ] <3s app startup time
- [ ] <5s load posting time
- [ ] 0 critical bugs in production

### User Metrics
- [ ] >80% auth completion rate
- [ ] >60% load detail → contact conversion
- [ ] >20% Super Loads/Truckers adoption (among verified users)

---

## Team & Responsibilities

### Roles (Adjust as needed)
- **Lead Developer:** Overall architecture, code review
- **Frontend Developer:** UI implementation
- **Backend Developer:** Supabase migrations, RLS policies
- **QA Engineer:** Testing, bug reporting
- **Designer:** UI/UX review, asset creation

---

## Notes

### Decisions Made
- ✅ Flat design (no gradients/glass)
- ✅ Dark teal brand colors (#008B8B)
- ✅ System theme by default
- ✅ Logo only on splash
- ✅ Email/Phone toggle on auth
- ✅ Super Loads/Truckers manual approval
- ✅ External payments only
- ✅ Reuse existing Supabase schema

### Open Questions
- [ ] Exact launch date?
- [ ] Marketing plan for v0.02?
- [ ] User communication strategy?
- [ ] Rollback plan if major issues?

---

## Progress Tracking

### Week 1: ⬜ Not Started
### Week 2: ⬜ Not Started
### Week 3: ⬜ Not Started
### Week 4: ⬜ Not Started
### Week 5: ⬜ Not Started
### Week 6: ⬜ Not Started
### Week 7: ⬜ Not Started
### Week 8: ⬜ Not Started

---

**Last Updated:** January 26, 2026  
**Next Review:** Start of Phase 1
