-- Data Retention Policy Migration
-- Implements GDPR-compliant data retention and anonymization
-- Created: January 22, 2026

-- Function to anonymize deleted user data
CREATE OR REPLACE FUNCTION public.anonymize_deleted_user(user_id_to_anonymize UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Anonymize user profile
  UPDATE public.users
  SET 
    name = 'Deleted User',
    email = CONCAT('deleted_', user_id_to_anonymize, '@anonymized.local'),
    mobile_number = '0000000000',
    country_code = '+00',
    is_supplier_enabled = false,
    is_trucker_enabled = false,
    updated_at = NOW()
  WHERE id = user_id_to_anonymize;

  -- Anonymize verification requests
  UPDATE public.verification_requests
  SET 
    document_number = NULL,
    document_front_url = NULL,
    document_back_url = NULL,
    company_name = NULL,
    vehicle_number = NULL,
    rejection_reason = NULL,
    updated_at = NOW()
  WHERE user_id = user_id_to_anonymize;

  -- Delete sensitive documents from storage
  -- Note: This requires manual cleanup of storage buckets
  -- Storage bucket cleanup should be done via Supabase dashboard or API

  RAISE NOTICE 'User % anonymized successfully', user_id_to_anonymize;
END;
$$;

-- Function to delete expired loads (older than 90 days)
CREATE OR REPLACE FUNCTION public.delete_expired_loads()
RETURNS TABLE(deleted_count INTEGER)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  count_deleted INTEGER;
BEGIN
  -- Delete loads that expired more than 90 days ago
  DELETE FROM public.loads
  WHERE 
    status = 'expired'
    AND expires_at < (NOW() - INTERVAL '90 days');
  
  GET DIAGNOSTICS count_deleted = ROW_COUNT;
  
  RAISE NOTICE 'Deleted % expired loads', count_deleted;
  
  RETURN QUERY SELECT count_deleted;
END;
$$;

-- Function to archive old analytics events (older than 1 year)
CREATE OR REPLACE FUNCTION public.archive_old_analytics()
RETURNS TABLE(archived_count INTEGER)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  count_archived INTEGER;
BEGIN
  -- Delete analytics events older than 1 year
  DELETE FROM public.analytics_events
  WHERE created_at < (NOW() - INTERVAL '1 year');
  
  GET DIAGNOSTICS count_archived = ROW_COUNT;
  
  RAISE NOTICE 'Archived % old analytics events', count_archived;
  
  RETURN QUERY SELECT count_archived;
END;
$$;

-- Function to clean up old notifications (older than 30 days)
CREATE OR REPLACE FUNCTION public.cleanup_old_notifications()
RETURNS TABLE(cleaned_count INTEGER)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  count_cleaned INTEGER;
BEGIN
  -- Delete read notifications older than 30 days
  DELETE FROM public.notifications
  WHERE 
    is_read = true
    AND created_at < (NOW() - INTERVAL '30 days');
  
  GET DIAGNOSTICS count_cleaned = ROW_COUNT;
  
  RAISE NOTICE 'Cleaned up % old notifications', count_cleaned;
  
  RETURN QUERY SELECT count_cleaned;
END;
$$;

-- Function to delete old chat messages (older than 6 months for inactive chats)
CREATE OR REPLACE FUNCTION public.cleanup_inactive_chats()
RETURNS TABLE(deleted_messages INTEGER, deleted_chats INTEGER)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  count_messages INTEGER := 0;
  count_chats INTEGER := 0;
BEGIN
  -- Delete messages from chats with no activity in 6 months
  DELETE FROM public.chat_messages
  WHERE chat_id IN (
    SELECT id FROM public.chats
    WHERE updated_at < (NOW() - INTERVAL '6 months')
  );
  
  GET DIAGNOSTICS count_messages = ROW_COUNT;
  
  -- Delete inactive chats
  DELETE FROM public.chats
  WHERE updated_at < (NOW() - INTERVAL '6 months');
  
  GET DIAGNOSTICS count_chats = ROW_COUNT;
  
  RAISE NOTICE 'Deleted % messages and % chats', count_messages, count_chats;
  
  RETURN QUERY SELECT count_messages, count_chats;
END;
$$;

-- Create a view for data retention summary
CREATE OR REPLACE VIEW public.data_retention_summary AS
SELECT
  'Expired Loads (>90 days)' as category,
  COUNT(*) as count,
  pg_size_pretty(pg_total_relation_size('public.loads')) as table_size
FROM public.loads
WHERE status = 'expired' AND expires_at < (NOW() - INTERVAL '90 days')
UNION ALL
SELECT
  'Old Analytics (>1 year)' as category,
  COUNT(*) as count,
  pg_size_pretty(pg_total_relation_size('public.analytics_events')) as table_size
FROM public.analytics_events
WHERE created_at < (NOW() - INTERVAL '1 year')
UNION ALL
SELECT
  'Old Notifications (>30 days)' as category,
  COUNT(*) as count,
  pg_size_pretty(pg_total_relation_size('public.notifications')) as table_size
FROM public.notifications
WHERE is_read = true AND created_at < (NOW() - INTERVAL '30 days')
UNION ALL
SELECT
  'Inactive Chats (>6 months)' as category,
  COUNT(*) as count,
  pg_size_pretty(pg_total_relation_size('public.chats')) as table_size
FROM public.chats
WHERE updated_at < (NOW() - INTERVAL '6 months');

-- Grant execute permissions to authenticated users for data export
GRANT EXECUTE ON FUNCTION public.anonymize_deleted_user TO authenticated;
GRANT SELECT ON public.data_retention_summary TO authenticated;

-- Grant execute permissions to service role for cleanup functions
-- These should be called by scheduled jobs, not directly by users
GRANT EXECUTE ON FUNCTION public.delete_expired_loads TO service_role;
GRANT EXECUTE ON FUNCTION public.archive_old_analytics TO service_role;
GRANT EXECUTE ON FUNCTION public.cleanup_old_notifications TO service_role;
GRANT EXECUTE ON FUNCTION public.cleanup_inactive_chats TO service_role;

-- Add comments for documentation
COMMENT ON FUNCTION public.anonymize_deleted_user IS 'GDPR-compliant user data anonymization';
COMMENT ON FUNCTION public.delete_expired_loads IS 'Delete loads expired more than 90 days ago';
COMMENT ON FUNCTION public.archive_old_analytics IS 'Archive analytics events older than 1 year';
COMMENT ON FUNCTION public.cleanup_old_notifications IS 'Clean up read notifications older than 30 days';
COMMENT ON FUNCTION public.cleanup_inactive_chats IS 'Delete messages and chats with no activity in 6 months';
COMMENT ON VIEW public.data_retention_summary IS 'Summary of data eligible for retention cleanup';

-- Note: These functions should be called by scheduled jobs
-- Recommended schedule:
-- - delete_expired_loads(): Daily
-- - archive_old_analytics(): Weekly
-- - cleanup_old_notifications(): Daily
-- - cleanup_inactive_chats(): Weekly
