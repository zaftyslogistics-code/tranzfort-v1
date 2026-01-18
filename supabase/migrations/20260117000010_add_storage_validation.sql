-- Migration: Add Storage Validation and Constraints
-- Purpose: Enforce file size and MIME type validation for verification documents
-- Phase: 4 (Verification - Storage Hardening)

-- Note: Supabase Storage bucket policies are configured via Dashboard or API.
-- This migration documents the recommended policies and adds helper functions.

-- ============================================
-- HELPER FUNCTIONS FOR STORAGE VALIDATION
-- ============================================

-- Function: Validate file size (max 5MB)
CREATE OR REPLACE FUNCTION public.validate_file_size(file_size_bytes BIGINT)
RETURNS BOOLEAN
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    RETURN file_size_bytes <= 5242880; -- 5MB in bytes
END;
$$;

-- Function: Validate MIME type for verification documents
CREATE OR REPLACE FUNCTION public.validate_verification_mime_type(mime_type TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    RETURN mime_type IN ('image/jpeg', 'image/png', 'application/pdf');
END;
$$;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.validate_file_size TO authenticated;
GRANT EXECUTE ON FUNCTION public.validate_verification_mime_type TO authenticated;

-- ============================================
-- STORAGE BUCKET POLICY DOCUMENTATION
-- ============================================

-- The following policies should be applied to the 'verification-documents' bucket:
--
-- 1. Upload Policy (INSERT):
--    - Allow authenticated users to upload to their own folder: {userId}/{roleType}/{requestId}/*
--    - Max file size: 5MB
--    - Allowed MIME types: image/jpeg, image/png, application/pdf
--
-- 2. Read Policy (SELECT):
--    - Allow users to read files from their own folder
--    - Allow admin/service role to read all files
--
-- 3. Update Policy (UPDATE):
--    - Disabled (files should not be updated after upload)
--
-- 4. Delete Policy (DELETE):
--    - Allow users to delete files from their own folder
--    - Allow admin/service role to delete any files
--
-- Example bucket policy (to be applied via Supabase Dashboard or API):
--
-- INSERT policy:
-- (bucket_id = 'verification-documents' AND 
--  auth.uid()::text = (storage.foldername(name))[1] AND
--  (storage.extension(name) IN ('jpg', 'jpeg', 'png', 'pdf')))
--
-- SELECT policy:
-- (bucket_id = 'verification-documents' AND 
--  auth.uid()::text = (storage.foldername(name))[1])

-- Comments
COMMENT ON FUNCTION public.validate_file_size IS 'Validates file size is under 5MB limit';
COMMENT ON FUNCTION public.validate_verification_mime_type IS 'Validates MIME type for verification documents (JPEG, PNG, PDF only)';
