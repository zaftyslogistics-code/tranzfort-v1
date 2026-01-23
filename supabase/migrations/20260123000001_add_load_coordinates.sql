-- Add optional coordinates to loads for future map/distance features

ALTER TABLE public.loads
  ADD COLUMN IF NOT EXISTS from_lat DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS from_lng DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS to_lat DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS to_lng DOUBLE PRECISION;

CREATE INDEX IF NOT EXISTS idx_loads_from_lat_lng ON public.loads(from_lat, from_lng);
CREATE INDEX IF NOT EXISTS idx_loads_to_lat_lng ON public.loads(to_lat, to_lng);
