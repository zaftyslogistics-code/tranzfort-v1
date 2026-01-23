-- Fix admin_profiles REST 500 caused by RLS recursion when policies call is_super_admin()
-- Also ensure analytics_events is accessible via PostgREST to avoid /rest/v1/analytics_events 404.

-- ============================================
-- Admin helper functions (SECURITY DEFINER)
-- ============================================

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM public.admin_profiles ap
    WHERE ap.id = auth.uid()
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM public.admin_profiles ap
    WHERE ap.id = auth.uid()
      AND ap.role = 'super_admin'
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.is_super_admin() TO authenticated, anon;

-- ============================================
-- Analytics events (ensure table + grants)
-- ============================================

CREATE TABLE IF NOT EXISTS public.analytics_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_name TEXT NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  session_id TEXT,
  properties JSONB DEFAULT '{}',
  timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS analytics_events_event_name_idx
  ON public.analytics_events(event_name);
CREATE INDEX IF NOT EXISTS analytics_events_user_id_idx
  ON public.analytics_events(user_id);
CREATE INDEX IF NOT EXISTS analytics_events_session_id_idx
  ON public.analytics_events(session_id);
CREATE INDEX IF NOT EXISTS analytics_events_timestamp_idx
  ON public.analytics_events(timestamp);
CREATE INDEX IF NOT EXISTS analytics_events_properties_idx
  ON public.analytics_events USING GIN (properties);

ALTER TABLE public.analytics_events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "analytics_events_user_read_policy" ON public.analytics_events;
CREATE POLICY "analytics_events_user_read_policy" ON public.analytics_events
  FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS "analytics_events_insert_policy" ON public.analytics_events;
CREATE POLICY "analytics_events_insert_policy" ON public.analytics_events
  FOR INSERT WITH CHECK (true);

GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT, INSERT ON public.analytics_events TO anon, authenticated;
