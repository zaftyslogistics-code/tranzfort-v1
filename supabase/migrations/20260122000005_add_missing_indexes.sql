-- Add missing database indexes for performance
-- Date: 2026-01-22
-- Issue: #15 from audit report

-- Add index on chat_messages.sender_id for faster sender queries
CREATE INDEX IF NOT EXISTS idx_chat_messages_sender 
  ON public.chat_messages(sender_id);

-- Add composite index for notifications related entity lookups
CREATE INDEX IF NOT EXISTS idx_notifications_related_entity 
  ON public.notifications(related_entity_type, related_entity_id) 
  WHERE related_entity_id IS NOT NULL;

-- Add index for notifications by type and user
CREATE INDEX IF NOT EXISTS idx_notifications_type_user 
  ON public.notifications(user_id, notification_type, created_at DESC);

-- Add index for chat messages by chat and timestamp (for pagination)
CREATE INDEX IF NOT EXISTS idx_chat_messages_chat_time 
  ON public.chat_messages(chat_id, created_at DESC);

-- Add index for loads by status and expiration (for cleanup queries)
CREATE INDEX IF NOT EXISTS idx_loads_status_expiration 
  ON public.loads(status, expires_at) 
  WHERE status = 'active';

-- Add index for verification requests by status (for admin dashboard)
CREATE INDEX IF NOT EXISTS idx_verification_requests_status_created 
  ON public.verification_requests(status, created_at DESC);

COMMENT ON INDEX idx_chat_messages_sender IS 'Improves performance for sender-based message queries';
COMMENT ON INDEX idx_notifications_related_entity IS 'Speeds up related entity lookups in notifications';
COMMENT ON INDEX idx_loads_status_expiration IS 'Optimizes load expiration queries';
