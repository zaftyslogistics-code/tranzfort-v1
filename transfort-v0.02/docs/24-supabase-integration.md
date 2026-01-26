# Supabase Integration (v0.02)

## Overview
Transfort uses Supabase as Backend-as-a-Service (BaaS) for authentication, database, storage, and real-time features.

---

## Supabase Services Used

### 1) Authentication
- **Email/Password** with OTP verification
- **Phone Authentication** (optional)
- Session management
- JWT tokens

### 2) PostgreSQL Database
- All application data
- Row Level Security (RLS) policies
- Triggers and functions
- Indexes for performance

### 3) Storage
- Document uploads (verification docs)
- Truck images (RC, insurance)
- User profile photos
- Load images (optional)

### 4) Realtime
- Chat messages
- Notifications
- Live updates for offers/deals

### 5) Edge Functions (Future)
- Notification delivery
- Background jobs
- Third-party integrations

---

## Database Schema (Existing)

### Core Tables (Already Implemented)
1. **users** - User profiles and verification status
2. **loads** - Load postings
3. **chats** - Chat conversations
4. **chat_messages** - Individual messages
5. **offers** - Load offers from truckers
6. **deals** - Confirmed deals with truck card
7. **trucks** - Trucker fleet management
8. **verification_requests** - Document verification queue
9. **notifications** - User notifications
10. **saved_searches** - Saved search filters
11. **ratings** - User ratings and reviews

### v0.02 New Tables Required
1. **support_tickets** - Support chat system
   - `id`, `user_id`, `ticket_type`, `status`, `created_at`, `updated_at`
   - Types: `general_support`, `super_load_request`, `super_trucker_request`

2. **support_messages** - Support chat messages
   - `id`, `ticket_id`, `sender_user_id`, `sender_admin_id`, `content`, `created_at`

### v0.02 Schema Updates Required
**loads table:**
- Add `is_super_load` (boolean, default false)
- Add `posted_by_admin_id` (uuid, nullable)
- Add `is_super_trucker` (boolean, default false)
- Add `super_trucker_request_status` (enum: pending/approved/rejected, nullable)
- Add `super_trucker_approved_by_admin_id` (uuid, nullable)
- Add `super_trucker_approved_at` (timestamp, nullable)

**users table:**
- Add `super_loads_approved` (boolean, default false) - Trucker approved for Super Loads
- Add `bank_account_holder` (varchar, nullable)
- Add `bank_name` (varchar, nullable)
- Add `bank_account_number` (varchar, nullable)
- Add `bank_ifsc` (varchar, nullable)
- Add `bank_upi_id` (varchar, nullable)

---

## Row Level Security (RLS) Policies

### Existing Policies (Keep)
- Users can view own profile
- Users can update own profile (restricted fields)
- Anyone can view active loads
- Suppliers can CRUD own loads
- Truckers can create offers
- Chat participants can view/send messages

### v0.02 New Policies Required

#### Super Loads
```sql
-- Only super_admin can create/update/delete Super Loads
CREATE POLICY "super_admin_super_loads_insert"
ON loads FOR INSERT
TO authenticated
WITH CHECK (
  is_super_load = true AND
  EXISTS (
    SELECT 1 FROM admins
    WHERE admins.user_id = auth.uid()
    AND admins.role = 'super_admin'
  )
);

-- Verified truckers can view Super Loads
CREATE POLICY "verified_truckers_view_super_loads"
ON loads FOR SELECT
TO authenticated
USING (
  is_super_load = true AND
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.super_loads_approved = true
  )
);
```

#### Super Truckers
```sql
-- Verified truckers can view Super Trucker loads
CREATE POLICY "verified_truckers_view_super_trucker_loads"
ON loads FOR SELECT
TO authenticated
USING (
  is_super_trucker = true AND
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.super_loads_approved = true
  )
);
```

#### Support Tickets
```sql
-- Users can view own tickets
CREATE POLICY "users_view_own_tickets"
ON support_tickets FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- Users can create tickets
CREATE POLICY "users_create_tickets"
ON support_tickets FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

-- Admins can view all tickets
CREATE POLICY "admins_view_all_tickets"
ON support_tickets FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM admins
    WHERE admins.user_id = auth.uid()
  )
);
```

---

## Storage Buckets

### Existing Buckets
1. **verification-docs** - User verification documents
   - Public: No
   - RLS: User can upload own docs, admins can view all

2. **truck-images** - Truck photos and RC/insurance
   - Public: No
   - RLS: Trucker can upload own truck images

3. **profile-photos** - User avatars
   - Public: Yes (read-only)
   - RLS: User can upload own photo

### v0.02 New Buckets (Optional)
1. **load-images** - Load photos (optional feature)
   - Public: Yes (read-only)
   - RLS: Supplier can upload for own loads

---

## Realtime Subscriptions

### Existing Subscriptions
```dart
// Chat messages
supabase
  .from('chat_messages')
  .stream(primaryKey: ['id'])
  .eq('chat_id', chatId)
  .listen((data) { /* handle */ });

// Notifications
supabase
  .from('notifications')
  .stream(primaryKey: ['id'])
  .eq('user_id', userId)
  .listen((data) { /* handle */ });
```

### v0.02 New Subscriptions
```dart
// Support messages
supabase
  .from('support_messages')
  .stream(primaryKey: ['id'])
  .eq('ticket_id', ticketId)
  .listen((data) { /* handle */ });

// Admin: New support tickets
supabase
  .from('support_tickets')
  .stream(primaryKey: ['id'])
  .eq('status', 'open')
  .listen((data) { /* handle */ });
```

---

## Environment Configuration

### Required Environment Variables
```env
# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key

# Feature Flags (Development)
USE_MOCK_AUTH=false
USE_MOCK_LOADS=false
USE_MOCK_CHAT=false
```

### Local Development
```env
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=local-anon-key
```

---

## Migration Strategy

### Option A: Reuse Existing Schema (Recommended)
**Pros:**
- No data loss
- Faster implementation
- Existing users preserved

**Cons:**
- Must write migration scripts
- Schema may have legacy fields

**Steps:**
1. Write migration SQL for new fields
2. Test on staging database
3. Run on production with backup
4. Update Flutter models

### Option B: Fresh Schema (Clean Slate)
**Pros:**
- Clean, optimized schema
- No legacy baggage
- Easier to document

**Cons:**
- All data lost
- Users must re-register
- Longer implementation

**Steps:**
1. Export critical data (if any)
2. Drop all tables
3. Run fresh schema
4. Update Flutter models
5. Notify users of reset

### Recommendation
**Use Option A** unless there are critical schema issues. The existing schema is well-designed and can accommodate v0.02 features with minimal changes.

---

## Database Functions (Existing)

### 1) Auto-create user profile on signup
```sql
CREATE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.users (id, mobile_number, created_at)
  VALUES (new.id, new.phone, now());
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 2) Update timestamps
```sql
CREATE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

---

## Performance Optimization

### Indexes (Existing)
- `users.mobile_number`
- `loads.supplier_id`
- `loads.status`
- `loads.from_city`, `loads.to_city`
- `chats.load_id`
- `chat_messages.chat_id`

### v0.02 New Indexes Required
```sql
CREATE INDEX idx_loads_is_super_load ON loads(is_super_load) WHERE is_super_load = true;
CREATE INDEX idx_loads_is_super_trucker ON loads(is_super_trucker) WHERE is_super_trucker = true;
CREATE INDEX idx_users_super_loads_approved ON users(super_loads_approved) WHERE super_loads_approved = true;
CREATE INDEX idx_support_tickets_status ON support_tickets(status);
CREATE INDEX idx_support_tickets_user_id ON support_tickets(user_id);
```

---

## Security Best Practices

### 1) Never expose service_role key in client
- Use anon key only
- Service role key stays on server/Edge Functions

### 2) RLS policies are mandatory
- Every table must have RLS enabled
- No public access without explicit policy

### 3) Sensitive data encryption
- Bank details encrypted at rest
- Use Supabase Vault for secrets (future)

### 4) Audit logging
- Log all admin actions
- Track Super Load/Trucker approvals
- Monitor RLS policy violations

---

## Backup & Recovery

### Automated Backups (Supabase)
- Daily automatic backups
- 7-day retention (free tier)
- Point-in-time recovery (paid tier)

### Manual Backup Strategy
```bash
# Export schema
pg_dump -h db.your-project.supabase.co -U postgres -s > schema.sql

# Export data
pg_dump -h db.your-project.supabase.co -U postgres -a > data.sql
```

### Disaster Recovery Plan
1. Restore from latest Supabase backup
2. Run migration scripts if needed
3. Verify data integrity
4. Test critical flows
5. Notify users if downtime occurred

---

## Monitoring & Alerts

### Supabase Dashboard Metrics
- Database size
- Active connections
- Query performance
- Storage usage
- Realtime connections

### Custom Monitoring (Future)
- Sentry for error tracking
- Custom analytics for business metrics
- Alert on RLS policy violations

---

## Cost Estimation

### Supabase Free Tier Limits
- 500 MB database
- 1 GB storage
- 2 GB bandwidth
- Unlimited API requests

### Estimated v0.02 Usage
- **Database:** ~200 MB (10k users, 50k loads)
- **Storage:** ~500 MB (verification docs + images)
- **Bandwidth:** ~1 GB/month

### When to Upgrade
- > 500 MB database
- > 1 GB storage
- Need point-in-time recovery
- Need custom domain

---

## Testing Strategy

### Local Development
- Use Supabase CLI for local instance
- Seed data with test users/loads
- Test RLS policies with different roles

### Staging Environment
- Separate Supabase project
- Mirror production schema
- Test migrations before production

### Production
- Blue-green deployment for schema changes
- Rollback plan for failed migrations
- Monitor for 24 hours post-deployment

---

## Acceptance Criteria

### v0.02 Supabase Integration Must Have:
- All new tables created with RLS policies
- Schema migrations tested on staging
- Realtime subscriptions working for support chat
- Storage buckets configured
- Indexes created for performance
- Backup verified before production deployment
