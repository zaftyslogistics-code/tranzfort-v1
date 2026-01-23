-- Add admin RLS policies for verification_requests and storage access
-- This enables admins to view pending verification requests and approve/reject them

-- Admin can SELECT all verification requests (for queue)
DROP POLICY IF EXISTS "Admins can view all verification requests" ON public.verification_requests;
CREATE POLICY "Admins can view all verification requests"
  ON public.verification_requests
  FOR SELECT
  USING (public.is_admin());

-- Admin can UPDATE verification requests (approve/reject)
DROP POLICY IF EXISTS "Admins can update verification requests" ON public.verification_requests;
CREATE POLICY "Admins can update verification requests"
  ON public.verification_requests
  FOR UPDATE
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- Storage: Admins can view verification documents via signed URLs
-- Note: This policy was already added in 20260119000012_admin_rbac_and_system_config.sql
-- but we ensure it's present here for clarity
DROP POLICY IF EXISTS "Admins can view verification documents" ON storage.objects;
CREATE POLICY "Admins can view verification documents"
  ON storage.objects
  FOR SELECT
  USING (
    bucket_id = 'verification-documents'
    AND public.is_admin()
  );

-- Ensure users can UPDATE their own verification documents (for re-upload scenarios)
DROP POLICY IF EXISTS "Users can update own documents" ON storage.objects;
CREATE POLICY "Users can update own documents"
  ON storage.objects
  FOR UPDATE
  USING (
    bucket_id = 'verification-documents'
    AND auth.uid()::text = (storage.foldername(name))[1]
  )
  WITH CHECK (
    bucket_id = 'verification-documents'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- Ensure users can DELETE their own documents (for re-upload scenarios)
DROP POLICY IF EXISTS "Users can delete own documents" ON storage.objects;
CREATE POLICY "Users can delete own documents"
  ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'verification-documents'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );
