-- Deal truck share requests (RC privacy workflow)

CREATE TABLE IF NOT EXISTS public.deal_truck_shares (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  offer_id UUID REFERENCES public.load_offers(id) ON DELETE SET NULL,
  load_id UUID NOT NULL REFERENCES public.loads(id) ON DELETE CASCADE,
  supplier_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  trucker_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  truck_id UUID REFERENCES public.trucks(id) ON DELETE SET NULL,
  rc_share_status VARCHAR(20) NOT NULL DEFAULT 'not_requested'
    CHECK (rc_share_status IN ('not_requested', 'requested', 'approved', 'revoked')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Uniqueness: one share workflow per (load, supplier, trucker)
CREATE UNIQUE INDEX IF NOT EXISTS idx_deal_truck_shares_unique
ON public.deal_truck_shares (load_id, supplier_id, trucker_id);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_deal_truck_shares_offer_id ON public.deal_truck_shares(offer_id);
CREATE INDEX IF NOT EXISTS idx_deal_truck_shares_status ON public.deal_truck_shares(rc_share_status);

-- Trigger: updated_at
DROP TRIGGER IF EXISTS update_deal_truck_shares_updated_at ON public.deal_truck_shares;
CREATE TRIGGER update_deal_truck_shares_updated_at
  BEFORE UPDATE ON public.deal_truck_shares
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS
ALTER TABLE public.deal_truck_shares ENABLE ROW LEVEL SECURITY;

-- RLS policies
DROP POLICY IF EXISTS "Deal parties can view truck share" ON public.deal_truck_shares;
CREATE POLICY "Deal parties can view truck share"
  ON public.deal_truck_shares
  FOR SELECT
  USING (auth.uid() = supplier_id OR auth.uid() = trucker_id);

DROP POLICY IF EXISTS "Suppliers can request RC share" ON public.deal_truck_shares;
CREATE POLICY "Suppliers can request RC share"
  ON public.deal_truck_shares
  FOR UPDATE
  USING (auth.uid() = supplier_id)
  WITH CHECK (auth.uid() = supplier_id);

DROP POLICY IF EXISTS "Truckers can approve or revoke RC share" ON public.deal_truck_shares;
CREATE POLICY "Truckers can approve or revoke RC share"
  ON public.deal_truck_shares
  FOR UPDATE
  USING (auth.uid() = trucker_id)
  WITH CHECK (auth.uid() = trucker_id);

DROP POLICY IF EXISTS "Deal parties can create truck share" ON public.deal_truck_shares;
CREATE POLICY "Deal parties can create truck share"
  ON public.deal_truck_shares
  FOR INSERT
  WITH CHECK (auth.uid() = supplier_id OR auth.uid() = trucker_id);

GRANT ALL ON public.deal_truck_shares TO authenticated;
