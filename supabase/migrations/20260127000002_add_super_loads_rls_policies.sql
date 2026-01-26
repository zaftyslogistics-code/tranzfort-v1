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
        SELECT 1 FROM public.admin_profiles
        WHERE admin_profiles.id = auth.uid()
    )
);

-- Policy: Only super_admin can update Super Loads
CREATE POLICY "super_admin_update_super_loads"
ON public.loads FOR UPDATE
TO authenticated
USING (
    is_super_load = TRUE AND
    EXISTS (
        SELECT 1 FROM public.admin_profiles
        WHERE admin_profiles.id = auth.uid()
    )
);

-- Policy: Only super_admins can delete Super Loads
CREATE POLICY "super_admins_delete_super_loads"
ON public.loads FOR DELETE
TO authenticated
USING (
    is_super_load = TRUE
    AND EXISTS (
        SELECT 1 FROM public.admin_profiles
        WHERE admin_profiles.id = auth.uid()
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

-- Note: Super Trucker policies removed - is_super_trucker column handled separately
-- Super Truckers use the same Super Loads approval system

-- Add comments
COMMENT ON POLICY "super_admin_create_super_loads" ON public.loads IS 'Only super_admin can create Super Loads';
COMMENT ON POLICY "verified_truckers_view_super_loads" ON public.loads IS 'Only verified truckers can view Super Loads';
