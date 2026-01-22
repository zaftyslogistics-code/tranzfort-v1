-- Implement automated load expiration
-- Date: 2026-01-22
-- Issue: #8 from audit report

-- Create function to expire old loads
CREATE OR REPLACE FUNCTION public.expire_old_loads()
RETURNS INTEGER AS $$
DECLARE
  expired_count INTEGER;
BEGIN
  -- Update loads that have passed their expiration date
  UPDATE public.loads
  SET 
    status = 'expired',
    updated_at = NOW()
  WHERE 
    status = 'active'
    AND expires_at < NOW();
  
  GET DIAGNOSTICS expired_count = ROW_COUNT;
  
  RETURN expired_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.expire_old_loads() TO authenticated;

-- Create a view to easily check expired loads
CREATE OR REPLACE VIEW public.expired_loads_summary AS
SELECT 
  COUNT(*) as total_expired,
  COUNT(DISTINCT supplier_id) as affected_suppliers,
  MAX(expires_at) as last_expiration_date
FROM public.loads
WHERE status = 'active' AND expires_at < NOW();

GRANT SELECT ON public.expired_loads_summary TO authenticated;

-- Add comment explaining usage
COMMENT ON FUNCTION public.expire_old_loads() IS 
  'Automatically expires loads past their expiration date. 
   Should be called periodically (e.g., via cron job or scheduled task).
   Returns the number of loads expired.
   Usage: SELECT public.expire_old_loads();';

-- Note: To automate this, you can:
-- 1. Use pg_cron extension (if available): 
--    SELECT cron.schedule('expire-loads', '0 * * * *', 'SELECT public.expire_old_loads()');
-- 2. Use external scheduler (recommended for Supabase free tier):
--    Call via Supabase Edge Function or external cron service
-- 3. Call from application on app startup or periodic background task
