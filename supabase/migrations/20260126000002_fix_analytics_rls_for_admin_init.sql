-- Fix analytics_events RLS to allow unauthenticated event insertion during app initialization
-- This resolves the 42501 permission denied error that blocks admin app startup

-- Revoke existing policies to avoid conflicts
DROP POLICY IF EXISTS "analytics_events_insert_policy" ON public.analytics_events;
DROP POLICY IF EXISTS "analytics_events_user_read_policy" ON public.analytics_events;

-- Create new insert policy that allows anyone (including anon) to insert events
-- This is safe because analytics events don't contain sensitive data
CREATE POLICY "analytics_events_insert_policy" ON public.analytics_events
  FOR INSERT WITH CHECK (true);

-- Create read policy that only allows users to read their own events
CREATE POLICY "analytics_events_user_read_policy" ON public.analytics_events
  FOR SELECT USING (user_id = auth.uid() OR user_id IS NULL);

-- Ensure grants are correct
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT, INSERT ON public.analytics_events TO anon, authenticated;
