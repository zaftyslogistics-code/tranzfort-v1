-- Migration: Add Super Loads fields to loads table
-- Date: 2026-01-26
-- Description: Add fields to support Super Loads feature (admin-posted premium loads)

-- Add Super Loads fields to loads table
ALTER TABLE public.loads
ADD COLUMN IF NOT EXISTS is_super_load BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS posted_by_admin_id UUID REFERENCES public.users(id),
ADD COLUMN IF NOT EXISTS is_super_trucker BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS super_trucker_request_status VARCHAR(20) CHECK (super_trucker_request_status IN ('pending', 'approved', 'rejected')),
ADD COLUMN IF NOT EXISTS super_trucker_approved_by_admin_id UUID REFERENCES public.users(id),
ADD COLUMN IF NOT EXISTS super_trucker_approved_at TIMESTAMP WITH TIME ZONE;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_loads_is_super_load ON public.loads(is_super_load) WHERE is_super_load = TRUE;
CREATE INDEX IF NOT EXISTS idx_loads_is_super_trucker ON public.loads(is_super_trucker) WHERE is_super_trucker = TRUE;
CREATE INDEX IF NOT EXISTS idx_loads_posted_by_admin_id ON public.loads(posted_by_admin_id) WHERE posted_by_admin_id IS NOT NULL;

-- Add comment
COMMENT ON COLUMN public.loads.is_super_load IS 'True if this is a Super Load (admin-posted premium load)';
COMMENT ON COLUMN public.loads.posted_by_admin_id IS 'Admin user who posted this Super Load';
COMMENT ON COLUMN public.loads.is_super_trucker IS 'True if this load is promoted to Super Truckers (verified truckers only)';
COMMENT ON COLUMN public.loads.super_trucker_request_status IS 'Status of Super Trucker request: pending, approved, rejected';
COMMENT ON COLUMN public.loads.super_trucker_approved_by_admin_id IS 'Admin who approved this load for Super Truckers';
COMMENT ON COLUMN public.loads.super_trucker_approved_at IS 'Timestamp when load was approved for Super Truckers';
