-- Create verification tables + storage bucket policies
-- Ensure UUID extension is available (created in previous migration)

-- verification_requests
CREATE TABLE IF NOT EXISTS public.verification_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  role_type VARCHAR(20) NOT NULL CHECK (role_type IN ('supplier', 'trucker')),
  document_type VARCHAR(20) NOT NULL CHECK (document_type IN ('aadhaar', 'pan', 'manual')),
  document_number VARCHAR(50),
  document_front_url TEXT,
  document_back_url TEXT,
  company_name VARCHAR(200),
  vehicle_number VARCHAR(20),
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  rejection_reason TEXT,
  reviewed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- verification_payments
CREATE TABLE IF NOT EXISTS public.verification_payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  verification_request_id UUID REFERENCES public.verification_requests(id) ON DELETE SET NULL,
  role_type VARCHAR(20) NOT NULL CHECK (role_type IN ('supplier', 'trucker')),
  amount DECIMAL(10,2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'INR',
  payment_gateway VARCHAR(50) DEFAULT 'razorpay',
  payment_gateway_order_id VARCHAR(100) UNIQUE,
  payment_gateway_payment_id VARCHAR(100),
  payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'success', 'failed', 'refunded')),
  payment_method VARCHAR(50),
  paid_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_verification_requests_user_role ON public.verification_requests(user_id, role_type);
CREATE INDEX IF NOT EXISTS idx_verification_requests_status ON public.verification_requests(status);
CREATE INDEX IF NOT EXISTS idx_verification_payments_user ON public.verification_payments(user_id);
CREATE INDEX IF NOT EXISTS idx_verification_payments_order_id ON public.verification_payments(payment_gateway_order_id);

-- Triggers: updated_at
DROP TRIGGER IF EXISTS update_verification_requests_updated_at ON public.verification_requests;
CREATE TRIGGER update_verification_requests_updated_at
  BEFORE UPDATE ON public.verification_requests
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_verification_payments_updated_at ON public.verification_payments;
CREATE TRIGGER update_verification_payments_updated_at
  BEFORE UPDATE ON public.verification_payments
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE public.verification_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.verification_payments ENABLE ROW LEVEL SECURITY;

-- RLS Policies
DROP POLICY IF EXISTS "Users can view own verification requests" ON public.verification_requests;
CREATE POLICY "Users can view own verification requests"
  ON public.verification_requests
  FOR SELECT
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can create verification requests" ON public.verification_requests;
CREATE POLICY "Users can create verification requests"
  ON public.verification_requests
  FOR INSERT
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can view own payments" ON public.verification_payments;
CREATE POLICY "Users can view own payments"
  ON public.verification_payments
  FOR SELECT
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can create payments" ON public.verification_payments;
CREATE POLICY "Users can create payments"
  ON public.verification_payments
  FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- Function/trigger to update public.users verification status
CREATE OR REPLACE FUNCTION public.update_user_verification_status()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'approved' THEN
    IF NEW.role_type = 'supplier' THEN
      UPDATE public.users
      SET supplier_verification_status = 'verified'
      WHERE id = NEW.user_id;
    ELSIF NEW.role_type = 'trucker' THEN
      UPDATE public.users
      SET trucker_verification_status = 'verified'
      WHERE id = NEW.user_id;
    END IF;
  ELSIF NEW.status = 'rejected' THEN
    IF NEW.role_type = 'supplier' THEN
      UPDATE public.users
      SET supplier_verification_status = 'rejected'
      WHERE id = NEW.user_id;
    ELSIF NEW.role_type = 'trucker' THEN
      UPDATE public.users
      SET trucker_verification_status = 'rejected'
      WHERE id = NEW.user_id;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS update_user_verification_status_trigger ON public.verification_requests;
CREATE TRIGGER update_user_verification_status_trigger
  AFTER UPDATE OF status ON public.verification_requests
  FOR EACH ROW
  WHEN (NEW.status IN ('approved', 'rejected'))
  EXECUTE FUNCTION public.update_user_verification_status();

-- Storage bucket + policies for verification documents
INSERT INTO storage.buckets (id, name, public)
VALUES ('verification-documents', 'verification-documents', false)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Users can upload own documents" ON storage.objects;
CREATE POLICY "Users can upload own documents"
  ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'verification-documents'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

DROP POLICY IF EXISTS "Users can view own documents" ON storage.objects;
CREATE POLICY "Users can view own documents"
  ON storage.objects
  FOR SELECT
  USING (
    bucket_id = 'verification-documents'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

GRANT ALL ON public.verification_requests TO authenticated;
GRANT ALL ON public.verification_payments TO authenticated;
