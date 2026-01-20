-- Drop verification_payments table and clean up related columns
-- Date: 2026-01-20
-- Reason: Pivot to Free Model (Removed Payment Gateway)

-- Drop the payments table if it exists
DROP TABLE IF EXISTS public.verification_payments CASCADE;

-- Note: verification_requests table might have had payment related logic in triggers
-- We should ensure no triggers depend on payments.
-- The previous migration 20260117000004_create_verification_tables.sql created:
-- 1. verification_requests
-- 2. verification_payments
-- 3. update_user_verification_status_trigger on verification_requests (depends only on status, not payments)

-- We are safe to drop the table.

-- If there were any columns in verification_requests related to payment (none explicitly in the create script, 
-- but good to double check if we added any later. The create script shows:
-- id, user_id, role_type, document_type, document_number, document_front_url, document_back_url, 
-- company_name, vehicle_number, status, rejection_reason, reviewed_at, created_at, updated_at
-- No payment columns in verification_requests.

-- We should also remove any payment related configuration if we stored it in the DB (we didn't, it was in AppConfig).

-- Grant permissions (just in case we re-create or for general sanity, though dropping doesn't need grants)
-- No action needed.

COMMENT ON TABLE public.verification_requests IS 'Verification requests (Document-only, Free Model)';
