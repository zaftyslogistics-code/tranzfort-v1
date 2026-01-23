-- Add optional needs_more_info status for verification_requests
-- This allows admins to request additional info without rejecting the verification.

DO $$
BEGIN
  -- Default constraint name when created inline is typically verification_requests_status_check
  IF EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'verification_requests_status_check'
  ) THEN
    ALTER TABLE public.verification_requests
      DROP CONSTRAINT verification_requests_status_check;
  END IF;

  ALTER TABLE public.verification_requests
    ADD CONSTRAINT verification_requests_status_check
    CHECK (status IN ('pending', 'approved', 'rejected', 'needs_more_info'));
END $$;
