-- Admin SQL Scripts: Verification Review Workflow
-- Purpose: Helper queries for manual verification review via Supabase Dashboard
-- Usage: Run these queries in Supabase SQL Editor with service_role permissions

-- ============================================
-- 1. VIEW PENDING VERIFICATION REQUESTS
-- ============================================

-- Get all pending verification requests with user details
SELECT 
    vr.id AS request_id,
    vr.user_id,
    u.mobile_number,
    u.country_code,
    vr.role_type,
    vr.document_type,
    vr.document_number,
    vr.document_front_url,
    vr.document_back_url,
    vr.company_name,
    vr.vehicle_number,
    vr.status,
    vr.created_at,
    vr.updated_at,
    -- Payment status
    vp.payment_status,
    vp.amount AS payment_amount,
    vp.paid_at
FROM public.verification_requests vr
INNER JOIN auth.users au ON vr.user_id = au.id
INNER JOIN public.users u ON vr.user_id = u.id
LEFT JOIN public.verification_payments vp ON vr.id = vp.verification_request_id
WHERE vr.status = 'pending'
ORDER BY vr.created_at DESC;

-- ============================================
-- 2. APPROVE VERIFICATION REQUEST
-- ============================================

-- Template: Replace {request_id} with actual UUID
-- This will:
-- 1. Update verification_requests.status to 'approved'
-- 2. Trigger will auto-update users table verification status

UPDATE public.verification_requests
SET 
    status = 'approved',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE id = '{request_id}';

-- Example:
-- UPDATE public.verification_requests
-- SET status = 'approved', reviewed_at = NOW(), updated_at = NOW()
-- WHERE id = '123e4567-e89b-12d3-a456-426614174000';

-- ============================================
-- 3. REJECT VERIFICATION REQUEST
-- ============================================

-- Template: Replace {request_id} and {rejection_reason}
UPDATE public.verification_requests
SET 
    status = 'rejected',
    rejection_reason = '{rejection_reason}',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE id = '{request_id}';

-- Example:
-- UPDATE public.verification_requests
-- SET status = 'rejected', 
--     rejection_reason = 'Document image unclear - please resubmit',
--     reviewed_at = NOW(), 
--     updated_at = NOW()
-- WHERE id = '123e4567-e89b-12d3-a456-426614174000';

-- ============================================
-- 4. VIEW USER VERIFICATION STATUS
-- ============================================

-- Get complete verification status for a user
SELECT 
    u.id AS user_id,
    u.mobile_number,
    u.country_code,
    u.name,
    u.is_supplier_enabled,
    u.is_trucker_enabled,
    u.supplier_verification_status,
    u.trucker_verification_status,
    -- Supplier verification details
    (SELECT COUNT(*) FROM public.verification_requests 
     WHERE user_id = u.id AND role_type = 'supplier') AS supplier_requests_count,
    (SELECT status FROM public.verification_requests 
     WHERE user_id = u.id AND role_type = 'supplier' 
     ORDER BY created_at DESC LIMIT 1) AS latest_supplier_request_status,
    -- Trucker verification details
    (SELECT COUNT(*) FROM public.verification_requests 
     WHERE user_id = u.id AND role_type = 'trucker') AS trucker_requests_count,
    (SELECT status FROM public.verification_requests 
     WHERE user_id = u.id AND role_type = 'trucker' 
     ORDER BY created_at DESC LIMIT 1) AS latest_trucker_request_status
FROM public.users u
WHERE u.id = '{user_id}';

-- ============================================
-- 5. VIEW PAYMENT RECONCILIATION
-- ============================================

-- Get all payments with verification request details
SELECT 
    vp.id AS payment_id,
    vp.user_id,
    u.mobile_number,
    vp.verification_request_id,
    vr.role_type,
    vp.amount,
    vp.currency,
    vp.payment_status,
    vp.payment_gateway,
    vp.payment_gateway_order_id,
    vp.payment_gateway_payment_id,
    vp.payment_method,
    vp.paid_at,
    vp.created_at,
    vr.status AS request_status
FROM public.verification_payments vp
INNER JOIN public.users u ON vp.user_id = u.id
LEFT JOIN public.verification_requests vr ON vp.verification_request_id = vr.id
ORDER BY vp.created_at DESC;

-- ============================================
-- 6. BULK APPROVE (USE WITH CAUTION)
-- ============================================

-- Approve all pending requests older than 24 hours with successful payment
-- (Example for automated approval - review carefully before using)

UPDATE public.verification_requests vr
SET 
    status = 'approved',
    reviewed_at = NOW(),
    updated_at = NOW()
WHERE vr.status = 'pending'
  AND vr.created_at < NOW() - INTERVAL '24 hours'
  AND EXISTS (
      SELECT 1 FROM public.verification_payments vp
      WHERE vp.verification_request_id = vr.id
        AND vp.payment_status = 'success'
  );

-- ============================================
-- 7. STATISTICS & ANALYTICS
-- ============================================

-- Verification request statistics
SELECT 
    role_type,
    status,
    COUNT(*) AS count,
    AVG(EXTRACT(EPOCH FROM (reviewed_at - created_at)) / 3600) AS avg_review_hours
FROM public.verification_requests
WHERE reviewed_at IS NOT NULL
GROUP BY role_type, status
ORDER BY role_type, status;

-- Payment statistics
SELECT 
    payment_status,
    COUNT(*) AS count,
    SUM(amount) AS total_amount,
    AVG(amount) AS avg_amount
FROM public.verification_payments
GROUP BY payment_status
ORDER BY payment_status;

-- Daily verification request volume
SELECT 
    DATE(created_at) AS date,
    role_type,
    COUNT(*) AS requests
FROM public.verification_requests
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE(created_at), role_type
ORDER BY date DESC, role_type;
