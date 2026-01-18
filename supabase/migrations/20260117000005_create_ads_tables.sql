-- Migration: Create Ads & Monetization Tables
-- Purpose: Track ad impressions and support frequency capping
-- Phase: 5 (Ads & Monetization)

-- Create ads_impressions table
CREATE TABLE IF NOT EXISTS public.ads_impressions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    screen_name VARCHAR(100) NOT NULL,
    ad_unit_id VARCHAR(100) NOT NULL,
    ad_type VARCHAR(50) NOT NULL DEFAULT 'banner', -- banner, native, interstitial
    shown_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    is_verified_user BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Create indexes for ads_impressions
CREATE INDEX idx_ads_impressions_user_id ON public.ads_impressions(user_id);
CREATE INDEX idx_ads_impressions_shown_at ON public.ads_impressions(shown_at);
CREATE INDEX idx_ads_impressions_screen_name ON public.ads_impressions(screen_name);
CREATE INDEX idx_ads_impressions_user_screen ON public.ads_impressions(user_id, screen_name, shown_at);

-- Enable RLS on ads_impressions
ALTER TABLE public.ads_impressions ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can insert their own ad impressions
CREATE POLICY "Users can insert own ad impressions"
    ON public.ads_impressions
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can read their own ad impressions
CREATE POLICY "Users can read own ad impressions"
    ON public.ads_impressions
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

-- Helper function: Check if user should see ads (frequency capping)
CREATE OR REPLACE FUNCTION public.should_show_ad(
    p_user_id UUID,
    p_screen_name VARCHAR,
    p_min_interval_minutes INT DEFAULT 5
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_last_shown TIMESTAMP WITH TIME ZONE;
BEGIN
    -- Get last ad shown time for this user on this screen
    SELECT MAX(shown_at) INTO v_last_shown
    FROM public.ads_impressions
    WHERE user_id = p_user_id
      AND screen_name = p_screen_name;

    -- If no ad shown yet, or interval passed, show ad
    IF v_last_shown IS NULL THEN
        RETURN TRUE;
    END IF;

    RETURN (NOW() - v_last_shown) > (p_min_interval_minutes || ' minutes')::INTERVAL;
END;
$$;

-- Grant execute permission on helper function
GRANT EXECUTE ON FUNCTION public.should_show_ad TO authenticated;

-- Comments
COMMENT ON TABLE public.ads_impressions IS 'Tracks ad impressions for analytics and frequency capping';
COMMENT ON COLUMN public.ads_impressions.user_id IS 'User who saw the ad (nullable for anonymous)';
COMMENT ON COLUMN public.ads_impressions.screen_name IS 'Screen where ad was shown (e.g., load_feed, profile)';
COMMENT ON COLUMN public.ads_impressions.ad_unit_id IS 'AdMob ad unit ID';
COMMENT ON COLUMN public.ads_impressions.is_verified_user IS 'Whether user was verified when ad was shown';
COMMENT ON FUNCTION public.should_show_ad IS 'Helper to check if ad should be shown based on frequency cap';
