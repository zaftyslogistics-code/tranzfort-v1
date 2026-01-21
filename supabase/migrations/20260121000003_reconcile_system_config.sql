ALTER TABLE public.system_config
  ADD COLUMN IF NOT EXISTS min_app_version TEXT NOT NULL DEFAULT '1.0.0';

ALTER TABLE public.system_config
  ADD COLUMN IF NOT EXISTS maintenance_mode BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE public.system_config
  ADD COLUMN IF NOT EXISTS maintenance_message TEXT;

ALTER TABLE public.system_config
  ADD COLUMN IF NOT EXISTS max_loads_per_user INTEGER NOT NULL DEFAULT 50;

ALTER TABLE public.system_config
  ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

ALTER TABLE public.system_config
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

ALTER TABLE public.system_config
  DROP COLUMN IF EXISTS verification_fee_trucker;

ALTER TABLE public.system_config
  DROP COLUMN IF EXISTS verification_fee_supplier;

ALTER TABLE public.system_config
  ALTER COLUMN load_expiry_days SET DEFAULT 30;

ALTER TABLE public.system_config ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Super admins can view system config" ON public.system_config;
DROP POLICY IF EXISTS "Super admins can update system config" ON public.system_config;
DROP POLICY IF EXISTS "system_config_read_policy" ON public.system_config;
DROP POLICY IF EXISTS "system_config_update_policy" ON public.system_config;

CREATE POLICY "system_config_read_policy"
  ON public.system_config
  FOR SELECT
  USING (true);

CREATE POLICY "system_config_update_policy"
  ON public.system_config
  FOR UPDATE
  USING (public.is_super_admin())
  WITH CHECK (public.is_super_admin());

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_trigger
    WHERE tgname = 'system_config_updated_at_trigger'
  ) THEN
    CREATE TRIGGER system_config_updated_at_trigger
      BEFORE UPDATE ON public.system_config
      FOR EACH ROW
      EXECUTE FUNCTION public.update_system_config_updated_at();
  END IF;
END;
$$;
