-- Migration: Add RLS policies for Super Loads
-- Date: 2026-01-26
-- Description: Add Row Level Security policies for Super Loads and Super Truckers

-- Policy: Only super_admin can create Super Loads
CREATE POLICY "super_admin_create_super_loads"
ON public.loads FOR INSERT
TO authenticated
WITH CHECK (
    is_super_load = TRUE AND
    posted_by_admin_id = auth.uid() AND
    EXISTS (
        SELECT 1 FROM public.admins
        WHERE admins.user_id = auth.uid()
        AND admins.role = 'super_admin'
    )
);

-- Policy: Only super_admin can update Super Loads
CREATE POLICY "super_admin_update_super_loads"
ON public.loads FOR UPDATE
TO authenticated
USING (
    is_super_load = TRUE AND
    EXISTS (
        SELECT 1 FROM public.admins
        WHERE admins.user_id = auth.uid()
        AND admins.role = 'super_admin'
    )
);

-- Policy: Only super_admin can delete Super Loads
CREATE POLICY "super_admin_delete_super_loads"
ON public.loads FOR DELETE
TO authenticated
USING (
    is_super_load = TRUE AND
    EXISTS (
        SELECT 1 FROM public.admins
        WHERE admins.user_id = auth.uid()
        AND admins.role = 'super_admin'
    )
);

-- Policy: Verified truckers can view Super Loads
CREATE POLICY "verified_truckers_view_super_loads"
ON public.loads FOR SELECT
TO authenticated
USING (
    is_super_load = TRUE AND
    status = 'active' AND
    EXISTS (
        SELECT 1 FROM public.users
        WHERE users.id = auth.uid()
        AND users.super_loads_approved = TRUE
    )
);

-- Policy: Verified truckers can view Super Trucker loads
CREATE POLICY "verified_truckers_view_super_trucker_loads"
ON public.loads FOR SELECT
TO authenticated
USING (
    is_super_trucker = TRUE AND
    status = 'active' AND
    EXISTS (
        SELECT 1 FROM public.users
        WHERE users.id = auth.uid()
        AND users.super_loads_approved = TRUE
    )
);

-- Policy: Admins can view all Super Loads and Super Trucker loads
CREATE POLICY "admins_view_super_loads"
ON public.loads FOR SELECT
TO authenticated
USING (
    (is_super_load = TRUE OR is_super_trucker = TRUE) AND
    EXISTS (
        SELECT 1 FROM public.admins
        WHERE admins.user_id = auth.uid()
    )
);

-- Add comments
COMMENT ON POLICY "super_admin_create_super_loads" ON public.loads IS 'Only super_admin can create Super Loads';
COMMENT ON POLICY "verified_truckers_view_super_loads" ON public.loads IS 'Only verified truckers can view Super Loads';
COMMENT ON POLICY "verified_truckers_view_super_trucker_loads" ON public.loads IS 'Only verified truckers can view Super Trucker loads';
