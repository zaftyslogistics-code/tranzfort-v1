-- Migration: Add Load Pricing Fields
-- Date: 2026-01-26
-- Description: Adds pricing structure fields to loads table for MVP 2.0
--              Includes price_type, rate_per_ton, advance payment fields

-- Create price type enum
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'price_type_enum') THEN
        CREATE TYPE price_type_enum AS ENUM ('per_ton', 'fixed', 'negotiable');
    END IF;
END $$;

-- Add new pricing columns to loads table
ALTER TABLE loads
ADD COLUMN IF NOT EXISTS price_type price_type_enum DEFAULT 'negotiable',
ADD COLUMN IF NOT EXISTS rate_per_ton DECIMAL(10, 2),
ADD COLUMN IF NOT EXISTS advance_required BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS advance_percent INTEGER DEFAULT 70,
ADD COLUMN IF NOT EXISTS chat_count INTEGER DEFAULT 0;

-- Add constraint for advance_percent range (10-90%)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'loads_advance_percent_range'
    ) THEN
        ALTER TABLE loads
        ADD CONSTRAINT loads_advance_percent_range 
        CHECK (advance_percent IS NULL OR (advance_percent >= 10 AND advance_percent <= 90));
    END IF;
END $$;

-- Add constraint: rate_per_ton required when price_type is 'per_ton'
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'loads_rate_per_ton_required'
    ) THEN
        ALTER TABLE loads
        ADD CONSTRAINT loads_rate_per_ton_required 
        CHECK (price_type != 'per_ton' OR rate_per_ton IS NOT NULL);
    END IF;
END $$;

-- Add index for high demand query (view_count + chat_count)
CREATE INDEX IF NOT EXISTS idx_loads_demand 
ON loads (view_count, chat_count) 
WHERE status = 'active';

-- Add index for price_type filtering
CREATE INDEX IF NOT EXISTS idx_loads_price_type 
ON loads (price_type) 
WHERE status = 'active';

-- Function to increment chat_count when a new chat is created for a load
CREATE OR REPLACE FUNCTION increment_load_chat_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE loads 
    SET chat_count = chat_count + 1 
    WHERE id = NEW.load_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public;

-- Trigger to auto-increment chat_count
DROP TRIGGER IF EXISTS trigger_increment_load_chat_count ON chats;
CREATE TRIGGER trigger_increment_load_chat_count
AFTER INSERT ON chats
FOR EACH ROW
EXECUTE FUNCTION increment_load_chat_count();

-- Comment on new columns
COMMENT ON COLUMN loads.price_type IS 'Pricing model: per_ton (rate × weight), fixed (total price), negotiable (price on call)';
COMMENT ON COLUMN loads.rate_per_ton IS 'Rate per ton in INR, used when price_type = per_ton';
COMMENT ON COLUMN loads.advance_required IS 'Whether advance payment is required';
COMMENT ON COLUMN loads.advance_percent IS 'Percentage of total to be paid as advance (10-90%)';
COMMENT ON COLUMN loads.chat_count IS 'Number of chat conversations initiated for this load';
