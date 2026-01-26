# Security & Compliance (v0.02)

## Overview
Security policies, data protection, and compliance requirements for Transfort v0.02.

---

## Security Principles

### 1) Defense in Depth
- Multiple layers of security
- No single point of failure
- Fail securely by default

### 2) Least Privilege
- Users see only their data
- Admins have role-based access
- RLS policies enforce boundaries

### 3) Secure by Default
- All endpoints require authentication
- Sensitive data encrypted at rest
- HTTPS only in production

---

## Authentication & Authorization

### Authentication Methods
1. **Email/Password** with OTP verification
2. **Phone/OTP** (optional)
3. **JWT tokens** (Supabase managed)

### Session Management
- **Token expiry:** 7 days
- **Refresh tokens:** Auto-refresh before expiry
- **Logout:** Clear local tokens + Supabase session

### Password Requirements
- Minimum 8 characters
- At least 1 uppercase
- At least 1 number
- No common passwords

### Authorization Levels
1. **User (Supplier/Trucker):** Own data only
2. **Support Agent:** Read user data, manage tickets
3. **Verification Officer:** Review verification requests
4. **Super Admin:** Full system access

---

## Data Protection

### Personal Data Collected
- **Required:**
  - Mobile number
  - Name
  - Email (optional)
  - Verification documents (Aadhaar, PAN, RC, etc.)

- **Optional:**
  - Profile photo
  - Bank details (for Super Loads/Truckers)
  - Location (for load matching)

### Data Encryption

#### At Rest
- **Database:** PostgreSQL encryption (Supabase default)
- **Storage:** Encrypted buckets for documents
- **Backups:** Encrypted by Supabase

#### In Transit
- **HTTPS only** for all API calls
- **TLS 1.2+** minimum
- **Certificate pinning** (future enhancement)

### Data Retention
- **Active users:** Indefinite
- **Inactive users (>2 years):** Notify before deletion
- **Deleted accounts:** 30-day grace period, then permanent deletion
- **Business records:** Loads/offers/deals archived (not deleted) unless account deleted

---

## Row Level Security (RLS)

### Core Principles
- Every table has RLS enabled
- No public access without explicit policy
- Policies tested before deployment

### User Data Policies
```sql
-- Users can view own profile
CREATE POLICY "users_view_own"
ON users FOR SELECT
TO authenticated
USING (id = auth.uid());

-- Users can update own profile (restricted fields)
CREATE POLICY "users_update_own"
ON users FOR UPDATE
TO authenticated
USING (id = auth.uid())
WITH CHECK (
  id = auth.uid() AND
  -- Cannot change verification status
  supplier_verification_status = OLD.supplier_verification_status AND
  trucker_verification_status = OLD.trucker_verification_status
);
```

### Load Data Policies
```sql
-- Anyone can view active loads
CREATE POLICY "loads_view_active"
ON loads FOR SELECT
TO authenticated
USING (status = 'active');

-- Suppliers can CRUD own loads
CREATE POLICY "loads_crud_own"
ON loads FOR ALL
TO authenticated
USING (supplier_id = auth.uid())
WITH CHECK (supplier_id = auth.uid());
```

### Admin Policies
```sql
-- Admins can view all data
CREATE POLICY "admins_view_all"
ON users FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM admins
    WHERE admins.user_id = auth.uid()
  )
);
```

---

## API Security

### Rate Limiting
- **Supabase default:** 100 requests/second per IP
- **Custom limits (future):** Per-user rate limiting

### Input Validation
- **Client-side:** Flutter form validators
- **Server-side:** PostgreSQL constraints + triggers
- **Sanitization:** Escape all user input

### SQL Injection Prevention
- **Parameterized queries** only
- **No raw SQL** in client code
- **Supabase SDK** handles escaping

---

## File Upload Security

### Allowed File Types
- **Documents:** PDF, JPG, PNG
- **Images:** JPG, PNG, WebP
- **Max size:** 5 MB per file

### Virus Scanning
- **Current:** None (Supabase default)
- **Future:** Integrate ClamAV or similar

### Storage Policies
```sql
-- Users can upload own verification docs
CREATE POLICY "verification_docs_upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'verification-docs' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Admins can view all verification docs
CREATE POLICY "admins_view_verification_docs"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'verification-docs' AND
  EXISTS (
    SELECT 1 FROM admins
    WHERE admins.user_id = auth.uid()
  )
);
```

---

## Admin Security

### Admin Roles & Permissions
| Role | Permissions |
|------|-------------|
| **Super Admin** | Full access, manage admins, Super Loads |
| **Verification Officer** | Review verification requests only |
| **Support Agent** | View users, manage support tickets |
| **Analyst** | Read-only analytics access |

### Admin Authentication
- **Separate admin table** with role field
- **Admin-only routes** in admin app
- **No admin access in user app**

### Audit Logging
```sql
CREATE TABLE admin_audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  admin_id UUID REFERENCES admins(id),
  action VARCHAR NOT NULL,
  target_type VARCHAR,
  target_id UUID,
  details JSONB,
  created_at TIMESTAMP DEFAULT now()
);
```

**Logged Actions:**
- User verification approval/rejection
- Super Load creation/approval
- Super Trucker approval
- Admin role changes
- Sensitive data access

---

## Compliance

### Data Privacy (India)
- **IT Act 2000:** Compliance with data protection rules
- **Digital Personal Data Protection Act 2023:** User consent, data minimization

### User Rights
1. **Right to Access:** Users can download their data
2. **Right to Deletion:** Users can delete account
3. **Right to Correction:** Users can update profile
4. **Right to Portability:** Export data in JSON format

### Privacy Policy Requirements
- Clear data collection disclosure
- Purpose of data usage
- Third-party sharing (none in v0.02)
- User rights and contact info

### Terms of Service Requirements
- Platform is marketplace only (no payment processing)
- User responsibilities
- Liability limitations
- Dispute resolution

---

## Incident Response

### Security Incident Types
1. **Data breach:** Unauthorized access to user data
2. **Account compromise:** User account hacked
3. **DDoS attack:** Service unavailable
4. **Malicious upload:** Virus/malware in documents

### Response Plan

#### Step 1: Detection
- Monitor Supabase logs
- User reports
- Automated alerts

#### Step 2: Containment
- Disable affected accounts
- Block malicious IPs
- Isolate compromised data

#### Step 3: Investigation
- Identify root cause
- Assess impact
- Document timeline

#### Step 4: Remediation
- Patch vulnerability
- Reset compromised credentials
- Notify affected users

#### Step 5: Post-Incident
- Update security policies
- Improve monitoring
- Train team

### Notification Requirements
- **Users affected:** Within 72 hours
- **Authorities:** As per local law
- **Public disclosure:** If > 1000 users affected

---

## Secure Development Practices

### Code Review
- All PRs require review
- Security-focused review for auth/data changes
- No secrets in code

### Dependency Management
- Regular updates for security patches
- Scan for vulnerable dependencies
- Pin versions in production

### Secret Management
- **Never commit:** `.env` files, API keys
- **Use:** Environment variables
- **Rotate:** Keys every 90 days

### Testing
- Unit tests for auth logic
- Integration tests for RLS policies
- Penetration testing (future)

---

## Monitoring & Alerts

### Security Monitoring
- Failed login attempts (> 5 in 5 minutes)
- RLS policy violations
- Unusual admin activity
- Large data exports

### Alerting Channels
- Email to security team
- Slack/Discord webhook
- SMS for critical incidents

---

## Third-Party Services

### Supabase
- **Data location:** India region (if available) or Singapore
- **Compliance:** SOC 2, GDPR-ready
- **Encryption:** At rest and in transit

### Google AdMob (User App Only)
- **Data shared:** Device ID, ad interaction
- **Privacy policy:** Link to Google's policy
- **User consent:** Required in EU (not India yet)

---

## Vulnerability Disclosure

### Responsible Disclosure Policy
- **Email:** security@transfort.app
- **Response time:** 48 hours
- **Bounty:** None (v0.02), consider in future

### Scope
- **In scope:** App, API, database
- **Out of scope:** Social engineering, DDoS

---

## Acceptance Criteria

### v0.02 Security Must Have:
- All RLS policies tested and working
- Admin audit logging implemented
- User data encrypted at rest
- HTTPS enforced in production
- Password requirements enforced
- File upload size limits enforced
- Admin roles and permissions working
- Privacy policy and ToS published
- Incident response plan documented
