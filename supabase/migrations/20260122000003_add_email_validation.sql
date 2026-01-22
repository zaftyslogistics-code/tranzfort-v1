-- Add email validation constraints
-- Date: 2026-01-22
-- Issue: #7 from audit report

-- Add UNIQUE constraint on email
ALTER TABLE public.users 
  ADD CONSTRAINT users_email_unique UNIQUE (email);

-- Add CHECK constraint for email format validation
ALTER TABLE public.users
  ADD CONSTRAINT users_email_format CHECK (
    email IS NULL OR 
    email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
  );

-- Add index for email lookups
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email) WHERE email IS NOT NULL;

COMMENT ON CONSTRAINT users_email_unique ON public.users IS 'Ensures email uniqueness for authentication';
COMMENT ON CONSTRAINT users_email_format ON public.users IS 'Validates email format using regex';
