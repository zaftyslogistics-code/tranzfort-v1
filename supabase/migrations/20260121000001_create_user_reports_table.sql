-- Migration: Create User Reports Table
-- Purpose: Allow users to report other users, loads, or chats for moderation
-- Phase: 7 (Admin Panel & Moderation)

CREATE TABLE IF NOT EXISTS public.user_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    reported_entity_type VARCHAR(50) NOT NULL CHECK (reported_entity_type IN ('user', 'load', 'chat')),
    reported_entity_id UUID NOT NULL, -- ID of the user, load, or chat being reported
    reason VARCHAR(50) NOT NULL, -- e.g., 'scam', 'spam', 'abusive', 'other'
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'investigating', 'resolved', 'dismissed')),
    admin_notes TEXT,
    resolved_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    resolved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_user_reports_status ON public.user_reports(status);
CREATE INDEX idx_user_reports_reporter_id ON public.user_reports(reporter_id);
CREATE INDEX idx_user_reports_created_at ON public.user_reports(created_at DESC);

-- RLS Policies
ALTER TABLE public.user_reports ENABLE ROW LEVEL SECURITY;

-- Users can create reports
CREATE POLICY "Users can create reports"
    ON public.user_reports
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = reporter_id);

-- Users can view their own reports
CREATE POLICY "Users can view own reports"
    ON public.user_reports
    FOR SELECT
    TO authenticated
    USING (auth.uid() = reporter_id);

-- Admins can view all reports
CREATE POLICY "Admins can view all reports"
    ON public.user_reports
    FOR SELECT
    TO authenticated
    USING (public.is_admin());

-- Admins can update reports
CREATE POLICY "Admins can update reports"
    ON public.user_reports
    FOR UPDATE
    TO authenticated
    USING (public.is_admin())
    WITH CHECK (public.is_admin());

-- Trigger for updated_at
CREATE TRIGGER set_user_reports_updated_at
    BEFORE UPDATE ON public.user_reports
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- Comments
COMMENT ON TABLE public.user_reports IS 'Reports submitted by users regarding issues with other users or content';
