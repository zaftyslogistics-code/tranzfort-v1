-- Migration: Create support_tickets table
-- Date: 2026-01-26
-- Description: Create table for admin support chat system

-- Create support_tickets table
CREATE TABLE IF NOT EXISTS public.support_tickets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    ticket_type VARCHAR(50) NOT NULL CHECK (ticket_type IN ('general_support', 'super_load_request', 'super_trucker_request')),
    status VARCHAR(20) NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')),
    subject VARCHAR(255),
    description TEXT,
    load_id UUID REFERENCES public.loads(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    resolved_at TIMESTAMP WITH TIME ZONE,
    resolved_by_admin_id UUID REFERENCES public.users(id)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_support_tickets_user_id ON public.support_tickets(user_id);
CREATE INDEX IF NOT EXISTS idx_support_tickets_status ON public.support_tickets(status);
CREATE INDEX IF NOT EXISTS idx_support_tickets_ticket_type ON public.support_tickets(ticket_type);
CREATE INDEX IF NOT EXISTS idx_support_tickets_created_at ON public.support_tickets(created_at DESC);

-- Enable RLS
ALTER TABLE public.support_tickets ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Users can view their own tickets
CREATE POLICY "users_view_own_tickets"
ON public.support_tickets FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- Users can create their own tickets
CREATE POLICY "users_create_tickets"
ON public.support_tickets FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

-- Admins can view all tickets
CREATE POLICY "admins_view_all_tickets"
ON public.support_tickets FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.admin_profiles
        WHERE admin_profiles.id = auth.uid()
    )
);

-- Admins can update all tickets
CREATE POLICY "admins_update_all_tickets"
ON public.support_tickets FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.admin_profiles
        WHERE admin_profiles.id = auth.uid()
    )
);

-- Create trigger for updated_at
CREATE TRIGGER update_support_tickets_updated_at
    BEFORE UPDATE ON public.support_tickets
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Add comments
COMMENT ON TABLE public.support_tickets IS 'Support tickets for admin chat system';
COMMENT ON COLUMN public.support_tickets.ticket_type IS 'Type: general_support, super_load_request, super_trucker_request';
COMMENT ON COLUMN public.support_tickets.status IS 'Status: open, in_progress, resolved, closed';
COMMENT ON COLUMN public.support_tickets.load_id IS 'Associated load ID (for Super Load/Trucker requests)';
