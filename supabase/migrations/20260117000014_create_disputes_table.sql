-- Create disputes table for rating dispute resolution
CREATE TABLE public.rating_disputes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  rating_id UUID NOT NULL REFERENCES public.ratings(id) ON DELETE CASCADE,
  reporter_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  dispute_reason VARCHAR(100) NOT NULL,
  dispute_description TEXT NOT NULL,
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'under_review', 'resolved', 'dismissed')),
  admin_notes TEXT,
  resolved_at TIMESTAMP WITH TIME ZONE,
  resolved_by UUID REFERENCES public.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_rating_disputes_rating_id ON public.rating_disputes(rating_id);
CREATE INDEX idx_rating_disputes_reporter_id ON public.rating_disputes(reporter_id);
CREATE INDEX idx_rating_disputes_status ON public.rating_disputes(status);

-- RLS Policies
ALTER TABLE public.rating_disputes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view disputes they reported"
  ON public.rating_disputes
  FOR SELECT
  USING (reporter_id = auth.uid());

CREATE POLICY "Admins can view all disputes"
  ON public.rating_disputes
  FOR SELECT
  USING (auth.jwt() ->> 'role' = 'admin'); -- Assuming admin role in JWT

CREATE POLICY "Users can create disputes"
  ON public.rating_disputes
  FOR INSERT
  WITH CHECK (reporter_id = auth.uid());

-- Trigger for updated_at
CREATE TRIGGER update_rating_disputes_updated_at
  BEFORE UPDATE ON public.rating_disputes
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
