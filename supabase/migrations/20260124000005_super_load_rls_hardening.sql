-- Super Load RLS hardening
-- Goal: Only super_admin can create/update/delete loads where is_super_load = true.
-- Normal supplier loads remain unaffected.

-- =============================
-- Replace supplier write policies
-- =============================

DROP POLICY IF EXISTS "Suppliers can insert own loads" ON public.loads;
CREATE POLICY "Suppliers can insert own loads"
  ON public.loads
  FOR INSERT
  WITH CHECK (
    auth.uid() = supplier_id
    AND (
      (is_super_load = false AND posted_by_admin_id IS NULL)
      OR (
        public.is_super_admin()
        AND is_super_load = true
        AND posted_by_admin_id = auth.uid()
      )
    )
  );

DROP POLICY IF EXISTS "Suppliers can update own loads" ON public.loads;
CREATE POLICY "Suppliers can update own loads"
  ON public.loads
  FOR UPDATE
  USING (
    auth.uid() = supplier_id
    AND (
      is_super_load = false
      OR public.is_super_admin()
    )
  )
  WITH CHECK (
    auth.uid() = supplier_id
    AND (
      (is_super_load = false AND posted_by_admin_id IS NULL)
      OR (
        public.is_super_admin()
        AND is_super_load = true
        AND posted_by_admin_id IS NOT NULL
      )
    )
  );

DROP POLICY IF EXISTS "Suppliers can delete own loads" ON public.loads;
CREATE POLICY "Suppliers can delete own loads"
  ON public.loads
  FOR DELETE
  USING (
    auth.uid() = supplier_id
    AND (
      is_super_load = false
      OR public.is_super_admin()
    )
  );

-- =============================
-- Replace admin update policy
-- =============================

DROP POLICY IF EXISTS "Admins can update all loads" ON public.loads;
CREATE POLICY "Admins can update all loads"
  ON public.loads
  FOR UPDATE
  USING (
    public.is_admin()
    AND (
      is_super_load = false
      OR public.is_super_admin()
    )
  )
  WITH CHECK (
    public.is_admin()
    AND (
      is_super_load = false
      OR (
        public.is_super_admin()
        AND posted_by_admin_id IS NOT NULL
      )
    )
  );

-- =============================
-- Admin delete policy (moderation)
-- =============================

DROP POLICY IF EXISTS "Admins can delete loads" ON public.loads;
CREATE POLICY "Admins can delete loads"
  ON public.loads
  FOR DELETE
  USING (
    public.is_admin()
    AND (
      is_super_load = false
      OR public.is_super_admin()
    )
  );
