-- Curate truck types for MVP by introducing an active flag
-- Keep legacy values for existing loads/trucks, but hide them from UI by default.

ALTER TABLE public.truck_types
ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT true;

-- Ensure curated MVP options exist
INSERT INTO public.truck_types (name, is_active) VALUES
  ('Open Body', true),
  ('Flat Body', true),
  ('Bulker', true),
  ('Container', true)
ON CONFLICT (name) DO UPDATE SET is_active = EXCLUDED.is_active;

-- Deactivate all other values to reduce dropdown size
UPDATE public.truck_types
SET is_active = false
WHERE name NOT IN (
  'Open Body',
  'Flat Body',
  'Bulker',
  'Container'
);
