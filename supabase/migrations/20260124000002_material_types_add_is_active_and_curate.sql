-- Curate material types for MVP by introducing an active flag
-- Keep legacy values for existing loads, but hide them from UI by default.

ALTER TABLE public.material_types
ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT true;

-- Ensure curated MVP options exist
INSERT INTO public.material_types (name, is_active) VALUES
  ('Agriculture', true),
  ('Construction / Building Materials', true),
  ('FMCG / Consumer Goods', true),
  ('Industrial / Machinery', true),
  ('Other', true)
ON CONFLICT (name) DO UPDATE SET is_active = EXCLUDED.is_active;

-- Deactivate all other values to reduce dropdown size
UPDATE public.material_types
SET is_active = false
WHERE name NOT IN (
  'Agriculture',
  'Construction / Building Materials',
  'FMCG / Consumer Goods',
  'Industrial / Machinery',
  'Other'
);
