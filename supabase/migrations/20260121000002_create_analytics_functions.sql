-- Migration: Create Admin Analytics Functions
-- Purpose: Provide real-time metrics for the Admin Dashboard
-- Phase: 7 (Admin Panel & Moderation)

-- 1. Daily Active Users (DAU)
-- Counts users who have logged in within the last 24 hours
CREATE OR REPLACE FUNCTION public.get_daily_active_users()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    dau_count INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO dau_count
    FROM auth.users
    WHERE last_sign_in_at >= NOW() - INTERVAL '24 hours';
    
    RETURN COALESCE(dau_count, 0);
END;
$$;

-- 2. New Loads Today
-- Counts loads created since the start of the current day
CREATE OR REPLACE FUNCTION public.get_new_loads_today()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    load_count INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO load_count
    FROM public.loads
    WHERE created_at >= CURRENT_DATE;
    
    RETURN COALESCE(load_count, 0);
END;
$$;

-- 3. Load Conversion Rate (Mock Logic for MVP)
-- For now, we'll define "conversion" as the percentage of loads that have at least one chat started.
-- In a real scenario, this might check for a "completed" status or specific transaction marker.
CREATE OR REPLACE FUNCTION public.get_load_conversion_rate()
RETURNS DECIMAL(5, 2)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    total_loads INTEGER;
    loads_with_chats INTEGER;
    conversion_rate DECIMAL(5, 2);
BEGIN
    -- Get total active loads from the last 30 days to keep it relevant
    SELECT COUNT(*)
    INTO total_loads
    FROM public.loads
    WHERE created_at >= NOW() - INTERVAL '30 days';

    IF total_loads = 0 THEN
        RETURN 0.00;
    END IF;

    -- Count loads that have at least one associated chat
    SELECT COUNT(DISTINCT load_id)
    INTO loads_with_chats
    FROM public.chats
    WHERE created_at >= NOW() - INTERVAL '30 days';

    -- Calculate percentage
    conversion_rate := (loads_with_chats::DECIMAL / total_loads::DECIMAL) * 100;
    
    RETURN ROUND(conversion_rate, 1);
END;
$$;

-- 4. User Growth (Last 7 Days)
-- Returns an array of user counts for each of the last 7 days
CREATE OR REPLACE FUNCTION public.get_user_growth_last_7_days()
RETURNS INTEGER[]
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    growth_data INTEGER[];
    day_offset INTEGER;
    daily_count INTEGER;
    cumulative_count INTEGER;
BEGIN
    -- Initialize array
    growth_data := ARRAY[]::INTEGER[];

    -- Loop from 6 days ago to today (7 data points)
    FOR day_offset IN REVERSE 6..0 LOOP
        -- Calculate cumulative users up to that day
        SELECT COUNT(*)
        INTO cumulative_count
        FROM auth.users
        WHERE created_at < (CURRENT_DATE - day_offset * INTERVAL '1 day') + INTERVAL '1 day';
        
        growth_data := array_append(growth_data, cumulative_count);
    END LOOP;

    RETURN growth_data;
END;
$$;

-- Grant execute permissions to authenticated users (or restrict to admins only in production)
-- For now, authenticated is fine as the app logic checks for admin role
GRANT EXECUTE ON FUNCTION public.get_daily_active_users TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_new_loads_today TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_load_conversion_rate TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_growth_last_7_days TO authenticated;
