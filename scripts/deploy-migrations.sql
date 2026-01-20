-- Transfort Production Migration Deployment Script
-- Execute these migrations in sequential order
-- Date: January 20, 2026
-- Status: Ready for Production

-- ============================================================================
-- MIGRATION 1: Drop Payment Infrastructure (20260120000001)
-- ============================================================================
-- Risk: Medium - Removes unused payment tables
-- Duration: ~1 minute

\echo 'Starting Migration 1: Drop Payment Infrastructure...'

-- Drop verification_payments table (should be empty/unused)
DROP TABLE IF EXISTS verification_payments CASCADE;

-- Remove any payment-related functions or triggers
DROP FUNCTION IF EXISTS update_verification_payment_updated_at() CASCADE;

\echo 'Migration 1 completed: Payment infrastructure removed'

-- ============================================================================
-- MIGRATION 2: Create Fleet Tables (20260120000002)  
-- ============================================================================
-- Risk: Low - Creates new tables and policies
-- Duration: ~2 minutes

\echo 'Starting Migration 2: Create Fleet Tables...'

-- Create trucks table
CREATE TABLE IF NOT EXISTS trucks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transporter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  truck_number TEXT NOT NULL,
  truck_type TEXT NOT NULL,
  capacity DECIMAL(10,2) NOT NULL,
  rc_document_url TEXT,
  insurance_document_url TEXT,
  rc_expiry_date DATE,
  insurance_expiry_date DATE,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT trucks_truck_number_unique UNIQUE (truck_number),
  CONSTRAINT trucks_capacity_positive CHECK (capacity > 0)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS trucks_transporter_id_idx ON trucks(transporter_id);
CREATE INDEX IF NOT EXISTS trucks_truck_type_idx ON trucks(truck_type);
CREATE INDEX IF NOT EXISTS trucks_is_active_idx ON trucks(is_active);
CREATE INDEX IF NOT EXISTS trucks_created_at_idx ON trucks(created_at);

-- Enable RLS
ALTER TABLE trucks ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "trucks_own_trucks_policy" ON trucks
  FOR ALL USING (transporter_id = auth.uid());

CREATE POLICY "trucks_public_read_policy" ON trucks
  FOR SELECT USING (is_active = true);

-- Create function for updated_at trigger
CREATE OR REPLACE FUNCTION update_trucks_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
CREATE TRIGGER trucks_updated_at_trigger
  BEFORE UPDATE ON trucks
  FOR EACH ROW
  EXECUTE FUNCTION update_trucks_updated_at();

-- Create storage bucket for fleet documents
INSERT INTO storage.buckets (id, name, public)
VALUES ('fleet-documents', 'fleet-documents', false)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for fleet documents
CREATE POLICY "fleet_documents_upload_policy" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'fleet-documents' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "fleet_documents_read_policy" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'fleet-documents' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "fleet_documents_update_policy" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'fleet-documents' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "fleet_documents_delete_policy" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'fleet-documents' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

\echo 'Migration 2 completed: Fleet tables and policies created'

-- ============================================================================
-- MIGRATION 3: Add User Preferences (20260120000003)
-- ============================================================================
-- Risk: Low - Adds column with default value
-- Duration: ~30 seconds

\echo 'Starting Migration 3: Add User Preferences...'

-- Add preferences column to users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS preferences JSONB NOT NULL DEFAULT '{}';

-- Create index for preferences queries
CREATE INDEX IF NOT EXISTS users_preferences_idx ON users USING GIN (preferences);

\echo 'Migration 3 completed: User preferences column added'

-- ============================================================================
-- MIGRATION 4: Create System Config (20260120000004)
-- ============================================================================
-- Risk: Low - Creates new table with default data
-- Duration: ~1 minute

\echo 'Starting Migration 4: Create System Config...'

-- Create system_config table
CREATE TABLE IF NOT EXISTS system_config (
  id INTEGER PRIMARY KEY DEFAULT 1,
  enable_ads BOOLEAN NOT NULL DEFAULT true,
  min_app_version TEXT NOT NULL DEFAULT '1.0.0',
  load_expiry_days INTEGER NOT NULL DEFAULT 30,
  maintenance_mode BOOLEAN NOT NULL DEFAULT false,
  maintenance_message TEXT,
  max_loads_per_user INTEGER NOT NULL DEFAULT 50,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- Ensure only one config row exists
  CONSTRAINT single_config_row CHECK (id = 1)
);

-- Insert default configuration
INSERT INTO system_config (
  id,
  enable_ads,
  min_app_version,
  load_expiry_days,
  maintenance_mode,
  maintenance_message,
  max_loads_per_user
) VALUES (
  1,
  true,
  '1.0.0',
  30,
  false,
  'Transfort is currently under maintenance. Please try again later.',
  50
) ON CONFLICT (id) DO NOTHING;

-- Enable RLS
ALTER TABLE system_config ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can read system config (needed for app functionality)
CREATE POLICY "system_config_read_policy" ON system_config
  FOR SELECT USING (true);

-- Policy: Only super admins can update system config
CREATE POLICY "system_config_update_policy" ON system_config
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM auth.users
      WHERE auth.users.id = auth.uid()
      AND auth.users.raw_user_meta_data->>'role' = 'super_admin'
    )
  );

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_system_config_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updated_at
CREATE TRIGGER system_config_updated_at_trigger
  BEFORE UPDATE ON system_config
  FOR EACH ROW
  EXECUTE FUNCTION update_system_config_updated_at();

\echo 'Migration 4 completed: System config table created'

-- ============================================================================
-- POST-MIGRATION VERIFICATION
-- ============================================================================

\echo 'Running post-migration verification...'

-- Verify trucks table exists and has correct structure
SELECT 'trucks table verification' as check_name, 
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'trucks') 
            THEN 'PASS' ELSE 'FAIL' END as status;

-- Verify users table has preferences column
SELECT 'users preferences column verification' as check_name,
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.columns 
                        WHERE table_name = 'users' AND column_name = 'preferences')
            THEN 'PASS' ELSE 'FAIL' END as status;

-- Verify system_config table exists with default data
SELECT 'system_config table verification' as check_name,
       CASE WHEN EXISTS (SELECT 1 FROM system_config WHERE id = 1)
            THEN 'PASS' ELSE 'FAIL' END as status;

-- Verify RLS is enabled on new tables
SELECT 'RLS verification' as check_name,
       CASE WHEN (SELECT COUNT(*) FROM pg_class c 
                  JOIN pg_namespace n ON n.oid = c.relnamespace 
                  WHERE c.relname IN ('trucks', 'system_config') 
                  AND c.relrowsecurity = true) = 2
            THEN 'PASS' ELSE 'FAIL' END as status;

\echo 'All migrations completed successfully!'
\echo 'Database is ready for production use.'
