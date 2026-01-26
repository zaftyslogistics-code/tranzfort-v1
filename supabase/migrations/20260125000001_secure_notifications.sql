-- Secure notifications table against direct client inserts.
-- Enforce "RPC-only" notification creation.

-- Remove overly-permissive insert policy
DROP POLICY IF EXISTS "System can insert notifications" ON public.notifications;

-- Tighten table privileges (least privilege)
REVOKE ALL ON public.notifications FROM authenticated;
GRANT SELECT, UPDATE ON public.notifications TO authenticated;
