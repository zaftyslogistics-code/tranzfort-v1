-- Align loads schema with app models (presentation/domain)
-- Keep existing columns for compatibility, but add the columns used by the app.

ALTER TABLE public.loads
  ADD COLUMN IF NOT EXISTS from_location TEXT,
  ADD COLUMN IF NOT EXISTS to_location TEXT,
  ADD COLUMN IF NOT EXISTS load_type VARCHAR(50),
  ADD COLUMN IF NOT EXISTS truck_type_required VARCHAR(50),
  ADD COLUMN IF NOT EXISTS weight DECIMAL(10,2),
  ADD COLUMN IF NOT EXISTS price_type VARCHAR(20) DEFAULT 'negotiable',
  ADD COLUMN IF NOT EXISTS contact_preferences_call BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS contact_preferences_chat BOOLEAN DEFAULT true;

-- Backfill new columns from existing ones where possible
UPDATE public.loads
SET
  from_location = COALESCE(from_location, from_city || ', ' || from_state),
  to_location = COALESCE(to_location, to_city || ', ' || to_state),
  load_type = COALESCE(load_type, material_type),
  truck_type_required = COALESCE(truck_type_required, truck_type),
  weight = COALESCE(weight, weight_in_tons)
WHERE TRUE;

-- Optional indexes for common filters
CREATE INDEX IF NOT EXISTS idx_loads_load_type ON public.loads(load_type);
CREATE INDEX IF NOT EXISTS idx_loads_truck_type_required ON public.loads(truck_type_required);
