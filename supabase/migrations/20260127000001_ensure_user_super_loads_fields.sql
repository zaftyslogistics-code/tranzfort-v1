-- Migration: Ensure User Super Loads fields exist
-- Date: 2026-01-27
-- Description: Re-apply user Super Loads fields in case previous migration failed

-- Add Super Loads approval field to users table
ALTER TABLE public.users
ADD COLUMN IF NOT EXISTS super_loads_approved BOOLEAN DEFAULT FALSE;

-- Add bank details fields (encrypted at application level)
ALTER TABLE public.users
ADD COLUMN IF NOT EXISTS bank_account_holder VARCHAR(100),
ADD COLUMN IF NOT EXISTS bank_name VARCHAR(100),
ADD COLUMN IF NOT EXISTS bank_account_number VARCHAR(50),
ADD COLUMN IF NOT EXISTS bank_ifsc VARCHAR(20),
ADD COLUMN IF NOT EXISTS bank_upi_id VARCHAR(100);

-- Create index for super_loads_approved
CREATE INDEX IF NOT EXISTS idx_users_super_loads_approved 
ON public.users(super_loads_approved) 
WHERE super_loads_approved = TRUE;

-- Add comments
COMMENT ON COLUMN public.users.super_loads_approved IS 'Whether user is approved to access Super Loads';
COMMENT ON COLUMN public.users.bank_account_holder IS 'Bank account holder name (encrypted at app level)';
COMMENT ON COLUMN public.users.bank_name IS 'Bank name';
COMMENT ON COLUMN public.users.bank_account_number IS 'Bank account number (encrypted at app level)';
COMMENT ON COLUMN public.users.bank_ifsc IS 'Bank IFSC code';
COMMENT ON COLUMN public.users.bank_upi_id IS 'UPI ID for payments';
