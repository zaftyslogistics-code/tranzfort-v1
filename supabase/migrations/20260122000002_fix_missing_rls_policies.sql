-- Fix missing RLS policies identified in comprehensive audit
-- Date: 2026-01-22
-- Issues: #3, #4, #5, #6 from audit report

-- ============================================
-- Fix #3: Complete ratings SELECT policy
-- ============================================
DROP POLICY IF EXISTS "Users can read ratings about them" ON public.ratings;
CREATE POLICY "Users can read ratings about them"
  ON public.ratings
  FOR SELECT
  TO authenticated
  USING (auth.uid() = rated_user_id OR auth.uid() = rater_user_id);

-- ============================================
-- Fix #4: Add chat message UPDATE and DELETE policies
-- ============================================
DROP POLICY IF EXISTS "Users can update own messages" ON public.chat_messages;
CREATE POLICY "Users can update own messages"
  ON public.chat_messages
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = sender_id)
  WITH CHECK (auth.uid() = sender_id);

DROP POLICY IF EXISTS "Users can delete own messages" ON public.chat_messages;
CREATE POLICY "Users can delete own messages"
  ON public.chat_messages
  FOR DELETE
  TO authenticated
  USING (auth.uid() = sender_id);

-- ============================================
-- Fix #5: Add notifications INSERT policy
-- ============================================
-- Allow system/authenticated users to create notifications
DROP POLICY IF EXISTS "System can insert notifications" ON public.notifications;
CREATE POLICY "System can insert notifications"
  ON public.notifications
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- ============================================
-- Fix #6: Fix analytics INSERT policy with validation
-- ============================================
DROP POLICY IF EXISTS "analytics_events_insert_policy" ON analytics_events;
CREATE POLICY "analytics_events_insert_policy" 
  ON analytics_events
  FOR INSERT 
  TO authenticated
  WITH CHECK (user_id = auth.uid() OR user_id IS NULL);

-- Grant necessary permissions
GRANT ALL ON public.chat_messages TO authenticated;
GRANT ALL ON public.notifications TO authenticated;
GRANT ALL ON analytics_events TO authenticated;
