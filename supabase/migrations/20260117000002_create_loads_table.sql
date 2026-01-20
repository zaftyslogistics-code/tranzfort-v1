-- Create loads + master tables
-- Ensure UUID extension is properly enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA public;

-- Master table: truck types
CREATE TABLE IF NOT EXISTS public.truck_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(80) UNIQUE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Master table: material types
CREATE TABLE IF NOT EXISTS public.material_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(80) UNIQUE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Loads table
CREATE TABLE public.loads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  supplier_id UUID NOT NULL REFERENCES public.users(id),

  from_city VARCHAR(100) NOT NULL,
  from_state VARCHAR(50) NOT NULL,
  to_city VARCHAR(100) NOT NULL,
  to_state VARCHAR(50) NOT NULL,

  material_type VARCHAR(50) NOT NULL,
  truck_type VARCHAR(50) NOT NULL,

  weight_in_tons DECIMAL(10,2),
  price DECIMAL(10,2),
  payment_terms VARCHAR(20),
  loading_date DATE,
  notes TEXT,

  status VARCHAR(20) DEFAULT 'active',
  view_count INTEGER DEFAULT 0,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '90 days')
);

-- Indexes
CREATE INDEX idx_loads_supplier ON public.loads(supplier_id);
CREATE INDEX idx_loads_from_city ON public.loads(from_city);
CREATE INDEX idx_loads_to_city ON public.loads(to_city);
CREATE INDEX idx_loads_truck_type ON public.loads(truck_type);
CREATE INDEX idx_loads_material_type ON public.loads(material_type);
CREATE INDEX idx_loads_status ON public.loads(status);
CREATE INDEX idx_loads_created_at ON public.loads(created_at);
CREATE INDEX idx_loads_expires_at ON public.loads(expires_at);

-- Trigger: updated_at
CREATE TRIGGER update_loads_updated_at
  BEFORE UPDATE ON public.loads
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE public.loads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.truck_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.material_types ENABLE ROW LEVEL SECURITY;

-- RLS policies: loads
-- Anyone authenticated can view active loads
CREATE POLICY "Authenticated users can view active loads"
  ON public.loads
  FOR SELECT
  USING (
    auth.role() = 'authenticated'
    AND status = 'active'
    AND expires_at > NOW()
  );

-- Suppliers can view their own loads (any status)
CREATE POLICY "Suppliers can view own loads"
  ON public.loads
  FOR SELECT
  USING (auth.uid() = supplier_id);

-- Suppliers can insert their own loads
CREATE POLICY "Suppliers can insert own loads"
  ON public.loads
  FOR INSERT
  WITH CHECK (auth.uid() = supplier_id);

-- Suppliers can update their own loads
CREATE POLICY "Suppliers can update own loads"
  ON public.loads
  FOR UPDATE
  USING (auth.uid() = supplier_id)
  WITH CHECK (auth.uid() = supplier_id);

-- Suppliers can delete their own loads
CREATE POLICY "Suppliers can delete own loads"
  ON public.loads
  FOR DELETE
  USING (auth.uid() = supplier_id);

-- RLS policies: master tables (read-only for authenticated users)
CREATE POLICY "Authenticated users can view truck types"
  ON public.truck_types
  FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can view material types"
  ON public.material_types
  FOR SELECT
  USING (auth.role() = 'authenticated');

-- Helper function: increment view count
CREATE OR REPLACE FUNCTION public.increment_load_view_count(load_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.loads
  SET view_count = COALESCE(view_count, 0) + 1
  WHERE id = load_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.increment_load_view_count(UUID) TO authenticated;

-- Seed master data
INSERT INTO public.truck_types (name) VALUES
  ('Open Truck'),
  ('Closed Container'),
  ('Trailer'),
  ('Flatbed'),
  ('Tanker'),
  ('Tipper'),
  ('Reefer'),
  ('Mini Truck'),
  ('Pickup'),
  ('LCV'),
  ('HCV'),
  ('Multi Axle'),
  ('Single Axle'),
  ('Semi Trailer'),
  ('Bulker'),
  ('Car Carrier'),
  ('Crane Truck'),
  ('Dumper')
ON CONFLICT (name) DO NOTHING;

INSERT INTO public.material_types (name) VALUES
  ('Cement'),
  ('Steel'),
  ('Bricks'),
  ('Sand'),
  ('Stone'),
  ('Coal'),
  ('Chemicals'),
  ('FMCG'),
  ('Food Grains'),
  ('Fruits & Vegetables'),
  ('Electronics'),
  ('Machinery'),
  ('Textiles'),
  ('Paper'),
  ('Automobile Parts'),
  ('Furniture'),
  ('Others')
ON CONFLICT (name) DO NOTHING;
