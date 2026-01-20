-- Create system_config table for remote configuration and feature flags
-- This allows dynamic control of app behavior without code deployments

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

-- Add helpful comments
COMMENT ON TABLE system_config IS 'Remote configuration and feature flags for the Transfort app';
COMMENT ON COLUMN system_config.enable_ads IS 'Global toggle for advertisement display';
COMMENT ON COLUMN system_config.min_app_version IS 'Minimum required app version (semantic versioning)';
COMMENT ON COLUMN system_config.load_expiry_days IS 'Number of days after which loads expire';
COMMENT ON COLUMN system_config.maintenance_mode IS 'Global maintenance mode toggle';
COMMENT ON COLUMN system_config.maintenance_message IS 'Message to display during maintenance';
COMMENT ON COLUMN system_config.max_loads_per_user IS 'Maximum number of active loads per user';
