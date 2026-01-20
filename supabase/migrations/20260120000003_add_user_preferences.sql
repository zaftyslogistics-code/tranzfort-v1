-- Add preferences column to users table
-- Date: 2026-01-20

ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS preferences JSONB DEFAULT '{}'::jsonb;

-- No need to update RLS policies as "Users can update own profile" already covers all columns for the owner.
