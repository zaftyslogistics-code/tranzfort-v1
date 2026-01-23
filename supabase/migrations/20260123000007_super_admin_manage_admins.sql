-- Allow super_admins to manage admin_profiles (create/view/update other admins)
-- This enables the "Manage Admins" UI feature for super_admins only

-- Super admins can view all admin profiles
DROP POLICY IF EXISTS "Super admins can view all admin profiles" ON public.admin_profiles;
CREATE POLICY "Super admins can view all admin profiles"
  ON public.admin_profiles
  FOR SELECT
  USING (public.is_super_admin());

-- Super admins can insert new admin profiles
DROP POLICY IF EXISTS "Super admins can create admin profiles" ON public.admin_profiles;
CREATE POLICY "Super admins can create admin profiles"
  ON public.admin_profiles
  FOR INSERT
  WITH CHECK (public.is_super_admin());

-- Super admins can update admin profiles (role changes, etc.)
DROP POLICY IF EXISTS "Super admins can update admin profiles" ON public.admin_profiles;
CREATE POLICY "Super admins can update admin profiles"
  ON public.admin_profiles
  FOR UPDATE
  USING (public.is_super_admin())
  WITH CHECK (public.is_super_admin());

-- Super admins can delete admin profiles (revoke admin access)
DROP POLICY IF EXISTS "Super admins can delete admin profiles" ON public.admin_profiles;
CREATE POLICY "Super admins can delete admin profiles"
  ON public.admin_profiles
  FOR DELETE
  USING (public.is_super_admin());

-- Admins can insert audit logs (for their own actions)
DROP POLICY IF EXISTS "Admins can insert audit logs" ON public.audit_logs;
CREATE POLICY "Admins can insert audit logs"
  ON public.audit_logs
  FOR INSERT
  WITH CHECK (
    auth.uid() = admin_id
    AND public.is_admin()
  );
