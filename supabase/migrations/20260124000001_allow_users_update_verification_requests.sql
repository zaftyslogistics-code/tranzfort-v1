-- Allow users to update their own verification_requests records in limited states
-- This is required to attach document paths after storage upload.

-- Users should be able to update only their own requests while the request is still in a user-actionable state.
-- NOTE: Column-level restrictions are not possible with RLS; we restrict by row ownership and status.

DROP POLICY IF EXISTS "Users can update own pending verification requests" ON public.verification_requests;
CREATE POLICY "Users can update own pending verification requests"
  ON public.verification_requests
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (
    user_id = auth.uid()
    AND status IN ('pending', 'needs_more_info')
  );
