-- Add Super Load support
-- Adds a flag to mark admin-posted "Super Loads" and (optionally) the admin id for auditing.

ALTER TABLE public.loads
  ADD COLUMN IF NOT EXISTS is_super_load BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS posted_by_admin_id UUID;

CREATE INDEX IF NOT EXISTS idx_loads_is_super_load ON public.loads(is_super_load);
CREATE INDEX IF NOT EXISTS idx_loads_posted_by_admin_id ON public.loads(posted_by_admin_id);
