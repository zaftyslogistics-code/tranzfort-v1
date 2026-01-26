-- Migration: Add Super Loads approval fields to users table
-- Date: 2026-01-26
-- Description: Add fields to track trucker approval for Super Loads access and bank details

-- Add Super Loads approval and bank details fields to users table
ALTER TABLE public.users
ADD COLUMN IF NOT EXISTS super_loads_approved BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS bank_account_holder VARCHAR(255),
ADD COLUMN IF NOT EXISTS bank_name VARCHAR(255),
ADD COLUMN IF NOT EXISTS bank_account_number VARCHAR(50),
ADD COLUMN IF NOT EXISTS bank_ifsc VARCHAR(20),
ADD COLUMN IF NOT EXISTS bank_upi_id VARCHAR(100);

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_users_super_loads_approved ON public.users(super_loads_approved) WHERE super_loads_approved = TRUE;

-- Add comments
COMMENT ON COLUMN public.users.super_loads_approved IS 'True if trucker is approved to access Super Loads';
COMMENT ON COLUMN public.users.bank_account_holder IS 'Bank account holder name (for Super Loads/Truckers)';
COMMENT ON COLUMN public.users.bank_name IS 'Bank name';
COMMENT ON COLUMN public.users.bank_account_number IS 'Bank account number (encrypted)';
COMMENT ON COLUMN public.users.bank_ifsc IS 'Bank IFSC code';
COMMENT ON COLUMN public.users.bank_upi_id IS 'UPI ID (optional)';

-- Note: Bank details should be encrypted at application level before storage
-- This is for verification purposes only, not for payment processing
