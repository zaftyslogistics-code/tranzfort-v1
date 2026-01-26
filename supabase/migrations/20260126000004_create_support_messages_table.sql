-- Migration: Create support_messages table
-- Date: 2026-01-26
-- Description: Create table for support chat messages

-- Create support_messages table
CREATE TABLE IF NOT EXISTS public.support_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ticket_id UUID NOT NULL REFERENCES public.support_tickets(id) ON DELETE CASCADE,
    sender_user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    sender_admin_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    content TEXT NOT NULL,
    message_type VARCHAR(20) DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'document')),
    attachment_url TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT check_sender CHECK (
        (sender_user_id IS NOT NULL AND sender_admin_id IS NULL) OR
        (sender_user_id IS NULL AND sender_admin_id IS NOT NULL)
    )
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_support_messages_ticket_id ON public.support_messages(ticket_id);
CREATE INDEX IF NOT EXISTS idx_support_messages_created_at ON public.support_messages(created_at ASC);
CREATE INDEX IF NOT EXISTS idx_support_messages_sender_user_id ON public.support_messages(sender_user_id);
CREATE INDEX IF NOT EXISTS idx_support_messages_sender_admin_id ON public.support_messages(sender_admin_id);

-- Enable RLS
ALTER TABLE public.support_messages ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Users can view messages in their own tickets
CREATE POLICY "users_view_own_ticket_messages"
ON public.support_messages FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.support_tickets
        WHERE support_tickets.id = ticket_id
        AND support_tickets.user_id = auth.uid()
    )
);

-- Users can send messages in their own tickets
CREATE POLICY "users_send_messages"
ON public.support_messages FOR INSERT
TO authenticated
WITH CHECK (
    sender_user_id = auth.uid() AND
    EXISTS (
        SELECT 1 FROM public.support_tickets
        WHERE support_tickets.id = ticket_id
        AND support_tickets.user_id = auth.uid()
    )
);

-- Admins can view all messages
CREATE POLICY "admins_view_all_messages"
ON public.support_messages FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.admin_profiles
        WHERE admin_profiles.id = auth.uid()
    )
);

-- Admins can send messages
CREATE POLICY "admins_send_messages"
ON public.support_messages FOR INSERT
TO authenticated
WITH CHECK (
    sender_admin_id = auth.uid() AND
    EXISTS (
        SELECT 1 FROM public.admin_profiles
        WHERE admin_profiles.id = auth.uid()
    )
);

-- Admins can update all messages (e.g., mark as read)
CREATE POLICY "admins_update_all_messages"
ON public.support_messages FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.admin_profiles
        WHERE admin_profiles.id = auth.uid()
    )
);

-- Add comments
COMMENT ON TABLE public.support_messages IS 'Messages in support tickets';
COMMENT ON COLUMN public.support_messages.sender_user_id IS 'User who sent the message (NULL if admin sent)';
COMMENT ON COLUMN public.support_messages.sender_admin_id IS 'Admin who sent the message (NULL if user sent)';
COMMENT ON COLUMN public.support_messages.message_type IS 'Type: text, image, document';
