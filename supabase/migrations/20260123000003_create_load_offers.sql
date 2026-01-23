-- Create load_offers table for offer/negotiation workflow

-- Ensure trucks table exists (idempotent) to avoid failing FK references on environments
-- where fleet migrations were not applied.
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

CREATE INDEX IF NOT EXISTS idx_trucks_transporter_id ON public.trucks(transporter_id);
CREATE INDEX IF NOT EXISTS idx_trucks_truck_number ON public.trucks(truck_number);

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

ALTER TABLE public.trucks ENABLE ROW LEVEL SECURITY;

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

GRANT ALL ON public.trucks TO authenticated;

CREATE TABLE IF NOT EXISTS public.load_offers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  load_id UUID NOT NULL REFERENCES public.loads(id) ON DELETE CASCADE,
  supplier_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  trucker_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  truck_id UUID REFERENCES public.trucks(id) ON DELETE SET NULL,
  price DECIMAL(10,2),
  message TEXT,
  status VARCHAR(20) NOT NULL DEFAULT 'proposed'
    CHECK (status IN ('proposed', 'countered', 'rejected', 'accepted', 'expired')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_load_offers_load_id ON public.load_offers(load_id);
CREATE INDEX IF NOT EXISTS idx_load_offers_supplier_id ON public.load_offers(supplier_id);
CREATE INDEX IF NOT EXISTS idx_load_offers_trucker_id ON public.load_offers(trucker_id);
CREATE INDEX IF NOT EXISTS idx_load_offers_status ON public.load_offers(status);
CREATE INDEX IF NOT EXISTS idx_load_offers_created_at ON public.load_offers(created_at);

-- Trigger: updated_at
DROP TRIGGER IF EXISTS update_load_offers_updated_at ON public.load_offers;
CREATE TRIGGER update_load_offers_updated_at
  BEFORE UPDATE ON public.load_offers
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS
ALTER TABLE public.load_offers ENABLE ROW LEVEL SECURITY;

-- RLS policies
DROP POLICY IF EXISTS "Truckers can create offers" ON public.load_offers;
CREATE POLICY "Truckers can create offers"
  ON public.load_offers
  FOR INSERT
  WITH CHECK (auth.uid() = trucker_id);

DROP POLICY IF EXISTS "Offer participants can view offers" ON public.load_offers;
CREATE POLICY "Offer participants can view offers"
  ON public.load_offers
  FOR SELECT
  USING (auth.uid() = trucker_id OR auth.uid() = supplier_id);

DROP POLICY IF EXISTS "Suppliers can update offer status" ON public.load_offers;
CREATE POLICY "Suppliers can update offer status"
  ON public.load_offers
  FOR UPDATE
  USING (auth.uid() = supplier_id)
  WITH CHECK (auth.uid() = supplier_id);

GRANT ALL ON public.load_offers TO authenticated;
