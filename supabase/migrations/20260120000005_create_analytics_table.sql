-- Create analytics_events table for performance monitoring and user behavior tracking
-- This enables comprehensive analytics and monitoring for the Transfort application

CREATE TABLE IF NOT EXISTS analytics_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_name TEXT NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  session_id TEXT,
  properties JSONB DEFAULT '{}',
  timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes for efficient querying
CREATE INDEX IF NOT EXISTS analytics_events_event_name_idx ON analytics_events(event_name);
CREATE INDEX IF NOT EXISTS analytics_events_user_id_idx ON analytics_events(user_id);
CREATE INDEX IF NOT EXISTS analytics_events_session_id_idx ON analytics_events(session_id);
CREATE INDEX IF NOT EXISTS analytics_events_timestamp_idx ON analytics_events(timestamp);
CREATE INDEX IF NOT EXISTS analytics_events_properties_idx ON analytics_events USING GIN (properties);

-- Enable RLS
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only read their own analytics events
CREATE POLICY "analytics_events_user_read_policy" ON analytics_events
  FOR SELECT USING (user_id = auth.uid());

-- Policy: Allow inserting analytics events (needed for tracking)
CREATE POLICY "analytics_events_insert_policy" ON analytics_events
  FOR INSERT WITH CHECK (true);

-- Policy: Super admins can read all analytics events
CREATE POLICY "analytics_events_admin_read_policy" ON analytics_events
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM auth.users
      WHERE auth.users.id = auth.uid()
      AND auth.users.raw_user_meta_data->>'role' = 'super_admin'
    )
  );

-- Add helpful comments
COMMENT ON TABLE analytics_events IS 'User behavior and performance analytics events';
COMMENT ON COLUMN analytics_events.event_name IS 'Name of the tracked event (e.g., screen_view, user_action)';
COMMENT ON COLUMN analytics_events.user_id IS 'User who triggered the event (nullable for anonymous events)';
COMMENT ON COLUMN analytics_events.session_id IS 'Unique session identifier for grouping events';
COMMENT ON COLUMN analytics_events.properties IS 'Event-specific data and metadata as JSON';
COMMENT ON COLUMN analytics_events.timestamp IS 'When the event occurred';

-- Create a view for common analytics queries
CREATE OR REPLACE VIEW analytics_summary AS
SELECT 
  event_name,
  COUNT(*) as event_count,
  COUNT(DISTINCT user_id) as unique_users,
  COUNT(DISTINCT session_id) as unique_sessions,
  DATE_TRUNC('day', timestamp) as event_date
FROM analytics_events
WHERE timestamp >= NOW() - INTERVAL '30 days'
GROUP BY event_name, DATE_TRUNC('day', timestamp)
ORDER BY event_date DESC, event_count DESC;

-- Create RLS policy for the view
CREATE POLICY "analytics_summary_admin_policy" ON analytics_events
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM auth.users
      WHERE auth.users.id = auth.uid()
      AND auth.users.raw_user_meta_data->>'role' = 'super_admin'
    )
  );

-- Grant access to the view for super admins
GRANT SELECT ON analytics_summary TO authenticated;

-- Create function to clean up old analytics data (optional, for data retention)
CREATE OR REPLACE FUNCTION cleanup_old_analytics()
RETURNS void AS $$
BEGIN
  -- Delete analytics events older than 1 year
  DELETE FROM analytics_events 
  WHERE timestamp < NOW() - INTERVAL '1 year';
  
  -- Log the cleanup
  RAISE NOTICE 'Analytics cleanup completed at %', NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
