-- Fix migration hygiene issues identified in code review
-- 1. Email column existence guard in anonymization function
-- 2. Dynamic constraint dropping
-- 3. Consolidate analytics table definitions

-- ============================================
-- 1. Fix anonymize_deleted_user to handle missing email column
-- ============================================

CREATE OR REPLACE FUNCTION public.anonymize_deleted_user(user_id_to_anonymize UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
DECLARE
  has_email_column BOOLEAN;
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE EXCEPTION 'Not allowed';
  END IF;

  -- Check if email column exists
  SELECT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_schema = 'public' 
      AND table_name = 'users' 
      AND column_name = 'email'
  ) INTO has_email_column;

  -- Anonymize user profile (conditionally handle email)
  IF has_email_column THEN
    UPDATE public.users
    SET 
      name = 'Deleted User',
      email = CONCAT('deleted_', user_id_to_anonymize, '@anonymized.local'),
      mobile_number = '0000000000',
      country_code = '+00',
      is_supplier_enabled = false,
      is_trucker_enabled = false,
      updated_at = NOW()
    WHERE id = user_id_to_anonymize;
  ELSE
    UPDATE public.users
    SET 
      name = 'Deleted User',
      mobile_number = '0000000000',
      country_code = '+00',
      is_supplier_enabled = false,
      is_trucker_enabled = false,
      updated_at = NOW()
    WHERE id = user_id_to_anonymize;
  END IF;

  -- Anonymize verification requests
  UPDATE public.verification_requests
  SET 
    document_number = NULL,
    document_front_url = NULL,
    document_back_url = NULL,
    company_name = NULL,
    vehicle_number = NULL,
    rejection_reason = NULL,
    updated_at = NOW()
  WHERE user_id = user_id_to_anonymize;

  RAISE NOTICE 'User % anonymized successfully', user_id_to_anonymize;
END;
$$;

-- ============================================
-- 2. Create helper function for dynamic constraint dropping
-- ============================================

CREATE OR REPLACE FUNCTION public.drop_constraint_if_exists(
  p_table_name TEXT,
  p_constraint_pattern TEXT
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  constraint_name TEXT;
BEGIN
  -- Find constraint by pattern
  SELECT conname INTO constraint_name
  FROM pg_constraint
  WHERE conrelid = (
    SELECT oid 
    FROM pg_class 
    WHERE relname = p_table_name 
      AND relnamespace = 'public'::regnamespace
  )
  AND conname LIKE p_constraint_pattern
  LIMIT 1;

  -- Drop if found
  IF constraint_name IS NOT NULL THEN
    EXECUTE format('ALTER TABLE public.%I DROP CONSTRAINT %I', p_table_name, constraint_name);
    RAISE NOTICE 'Dropped constraint % from table %', constraint_name, p_table_name;
  ELSE
    RAISE NOTICE 'No constraint matching % found on table %', p_constraint_pattern, p_table_name;
  END IF;
END;
$$;

COMMENT ON FUNCTION public.drop_constraint_if_exists IS 'Safely drop constraint by pattern match, used for migration robustness';

-- ============================================
-- 3. Consolidate analytics_events table definition
-- ============================================

-- Drop duplicate policies from earlier migrations
DROP POLICY IF EXISTS "analytics_events_admin_read_policy" ON public.analytics_events;
DROP POLICY IF EXISTS "analytics_summary_admin_policy" ON public.analytics_events;

-- Ensure only these policies exist:
-- 1. analytics_events_user_read_policy (users read own)
-- 2. analytics_events_insert_policy (controlled insert)

-- Note: Admin read access is now controlled via the analytics RPCs
-- which were restricted in migration 20260125000004

-- ============================================
-- 4. Add email uniqueness with proper strategy
-- ============================================

-- Drop existing email index if it exists
DROP INDEX IF EXISTS public.users_email_idx;

-- Create partial unique index (only for non-null emails)
-- This allows multiple NULL emails but enforces uniqueness for actual email addresses
CREATE UNIQUE INDEX IF NOT EXISTS users_email_unique_idx 
ON public.users(email) 
WHERE email IS NOT NULL;

COMMENT ON INDEX public.users_email_unique_idx IS 'Partial unique index: enforces email uniqueness only for non-null values';
