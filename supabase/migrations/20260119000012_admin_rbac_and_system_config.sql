-- Admin RBAC policies + persisted system configuration

-- Helper: check if current auth user is an admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.admin_profiles ap
    WHERE ap.id = auth.uid()
  );
$$;

CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.admin_profiles ap
    WHERE ap.id = auth.uid()
      AND ap.role = 'super_admin'
  );
$$;

-- ============================================
-- Admin access to users
-- ============================================
DROP POLICY IF EXISTS "Admins can view all users" ON public.users;
CREATE POLICY "Admins can view all users"
  ON public.users
  FOR SELECT
  USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can update all users" ON public.users;
CREATE POLICY "Admins can update all users"
  ON public.users
  FOR UPDATE
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- ============================================
-- Admin access to loads
-- ============================================
DROP POLICY IF EXISTS "Admins can view all loads" ON public.loads;
CREATE POLICY "Admins can view all loads"
  ON public.loads
  FOR SELECT
  USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can update all loads" ON public.loads;
CREATE POLICY "Admins can update all loads"
  ON public.loads
  FOR UPDATE
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- ============================================
-- Admin access to verification
-- ============================================
DROP POLICY IF EXISTS "Admins can view verification requests" ON public.verification_requests;
CREATE POLICY "Admins can view verification requests"
  ON public.verification_requests
  FOR SELECT
  USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can update verification requests" ON public.verification_requests;
CREATE POLICY "Admins can update verification requests"
  ON public.verification_requests
  FOR UPDATE
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Admins can view verification payments" ON public.verification_payments;
CREATE POLICY "Admins can view verification payments"
  ON public.verification_payments
  FOR SELECT
  USING (public.is_admin());

-- Storage: allow admins to view verification documents
DROP POLICY IF EXISTS "Admins can view verification documents" ON storage.objects;
CREATE POLICY "Admins can view verification documents"
  ON storage.objects
  FOR SELECT
  USING (
    bucket_id = 'verification-documents'
    AND public.is_admin()
  );

-- ============================================
-- Persisted system configuration
-- ============================================
CREATE TABLE IF NOT EXISTS public.system_config (
  id INT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  enable_ads BOOLEAN NOT NULL DEFAULT TRUE,
  verification_fee_trucker INT NOT NULL DEFAULT 499,
  verification_fee_supplier INT NOT NULL DEFAULT 499,
  load_expiry_days INT NOT NULL DEFAULT 90,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.system_config ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Super admins can view system config" ON public.system_config;
CREATE POLICY "Super admins can view system config"
  ON public.system_config
  FOR SELECT
  USING (public.is_super_admin());

DROP POLICY IF EXISTS "Super admins can update system config" ON public.system_config;
CREATE POLICY "Super admins can update system config"
  ON public.system_config
  FOR UPDATE
  USING (public.is_super_admin())
  WITH CHECK (public.is_super_admin());

INSERT INTO public.system_config (id)
VALUES (1)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- Auth trigger: support email-based logins too
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, mobile_number, country_code)
  VALUES (
    NEW.id,
    COALESCE(
      NEW.phone,
      SUBSTRING(REPLACE(NEW.id::text, '-', ''), 1, 15)
    ),
    COALESCE(NEW.raw_user_meta_data->>'country_code', '+91')
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
