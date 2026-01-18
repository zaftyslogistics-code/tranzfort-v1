-- Migration: Enable Realtime for Chat Messages
-- Purpose: Allow real-time message streaming in chat feature
-- Phase: 3 (Chat System)

-- Enable Realtime publication for chat_messages table
ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_messages;

-- Comments
COMMENT ON TABLE public.chat_messages IS 'Chat messages with Realtime enabled for live updates';
