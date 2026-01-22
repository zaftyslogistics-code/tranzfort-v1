-- Ensure trucks table exists (idempotent)
-- Date: 2026-01-22
-- Fix for: PostgrestException - Could not find table 'public.trucks'

-- Create trucks table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.trucks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transporter_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  truck_number VARCHAR(20) NOT NULL,
  truck_type VARCHAR(50) NOT NULL,
  capacity DECIMAL(10,2) NOT NULL,
  
  rc_document_url TEXT,
  insurance_document_url TEXT,
  
  rc_expiry_date TIMESTAMP WITH TIME ZONE,
  insurance_expiry_date TIMESTAMP WITH TIME ZONE,
  
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_trucks_transporter_id ON public.trucks(transporter_id);
CREATE INDEX IF NOT EXISTS idx_trucks_truck_number ON public.trucks(truck_number);

-- Trigger: updated_at (only if function exists)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'update_updated_at_column') THEN
    DROP TRIGGER IF EXISTS update_trucks_updated_at ON public.trucks;
    CREATE TRIGGER update_trucks_updated_at
      BEFORE UPDATE ON public.trucks
      FOR EACH ROW
      EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;

-- Enable Row Level Security
ALTER TABLE public.trucks ENABLE ROW LEVEL SECURITY;

-- RLS Policies (drop and recreate to ensure they exist)
DROP POLICY IF EXISTS "Transporters can view own trucks" ON public.trucks;
CREATE POLICY "Transporters can view own trucks"
  ON public.trucks
  FOR SELECT
  USING (auth.uid() = transporter_id);

DROP POLICY IF EXISTS "Transporters can insert own trucks" ON public.trucks;
CREATE POLICY "Transporters can insert own trucks"
  ON public.trucks
  FOR INSERT
  WITH CHECK (auth.uid() = transporter_id);

DROP POLICY IF EXISTS "Transporters can update own trucks" ON public.trucks;
CREATE POLICY "Transporters can update own trucks"
  ON public.trucks
  FOR UPDATE
  USING (auth.uid() = transporter_id)
  WITH CHECK (auth.uid() = transporter_id);

DROP POLICY IF EXISTS "Transporters can delete own trucks" ON public.trucks;
CREATE POLICY "Transporters can delete own trucks"
  ON public.trucks
  FOR DELETE
  USING (auth.uid() = transporter_id);

-- Grant permissions
GRANT ALL ON public.trucks TO authenticated;
