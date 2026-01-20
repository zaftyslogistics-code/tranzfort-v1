-- Create trucks table for Fleet Management
-- Date: 2026-01-20

-- Create trucks table
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

-- Trigger: updated_at
DROP TRIGGER IF EXISTS update_trucks_updated_at ON public.trucks;
CREATE TRIGGER update_trucks_updated_at
  BEFORE UPDATE ON public.trucks
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE public.trucks ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Transporters can view their own trucks
CREATE POLICY "Transporters can view own trucks"
  ON public.trucks
  FOR SELECT
  USING (auth.uid() = transporter_id);

-- Transporters can insert their own trucks
CREATE POLICY "Transporters can insert own trucks"
  ON public.trucks
  FOR INSERT
  WITH CHECK (auth.uid() = transporter_id);

-- Transporters can update their own trucks
CREATE POLICY "Transporters can update own trucks"
  ON public.trucks
  FOR UPDATE
  USING (auth.uid() = transporter_id)
  WITH CHECK (auth.uid() = transporter_id);

-- Transporters can delete their own trucks
CREATE POLICY "Transporters can delete own trucks"
  ON public.trucks
  FOR DELETE
  USING (auth.uid() = transporter_id);

-- Storage bucket policies for truck documents
-- Assuming usage of existing 'verification-documents' or creating a new 'fleet-documents' bucket
-- Let's use 'fleet-documents' to keep it separate or 'verification-documents' if we want to consolidate.
-- Given the context, let's create a specific bucket for fleet to avoid permission confusion.

INSERT INTO storage.buckets (id, name, public)
VALUES ('fleet-documents', 'fleet-documents', false)
ON CONFLICT (id) DO NOTHING;

-- Policy: Transporters can upload their own truck documents
DROP POLICY IF EXISTS "Transporters can upload fleet documents" ON storage.objects;
CREATE POLICY "Transporters can upload fleet documents"
  ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'fleet-documents'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- Policy: Transporters can view their own truck documents
DROP POLICY IF EXISTS "Transporters can view fleet documents" ON storage.objects;
CREATE POLICY "Transporters can view fleet documents"
  ON storage.objects
  FOR SELECT
  USING (
    bucket_id = 'fleet-documents'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- Grant permissions
GRANT ALL ON public.trucks TO authenticated;
