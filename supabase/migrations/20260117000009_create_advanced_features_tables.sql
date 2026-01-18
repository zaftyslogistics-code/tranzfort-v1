-- Migration: Create Advanced Features Tables
-- Purpose: Support saved searches, notifications, and ratings
-- Phase: 6 (Advanced Features)

-- ============================================
-- 1. SAVED SEARCHES (Load Alerts)
-- ============================================

CREATE TABLE IF NOT EXISTS public.saved_searches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    search_name VARCHAR(100),
    from_location VARCHAR(100),
    to_location VARCHAR(100),
    truck_type VARCHAR(50),
    weight_range_min DECIMAL(10, 2),
    weight_range_max DECIMAL(10, 2),
    price_range_min DECIMAL(10, 2),
    price_range_max DECIMAL(10, 2),
    is_alert_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Indexes for saved_searches
CREATE INDEX idx_saved_searches_user_id ON public.saved_searches(user_id);
CREATE INDEX idx_saved_searches_alert_enabled ON public.saved_searches(user_id, is_alert_enabled);

-- Enable RLS
ALTER TABLE public.saved_searches ENABLE ROW LEVEL SECURITY;

-- RLS Policies for saved_searches
CREATE POLICY "Users can manage own saved searches"
    ON public.saved_searches
    FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Trigger for updated_at
CREATE TRIGGER set_saved_searches_updated_at
    BEFORE UPDATE ON public.saved_searches
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================
-- 2. NOTIFICATIONS
-- ============================================

CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    notification_type VARCHAR(50) NOT NULL, -- load_match, chat_message, verification_update, system
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    related_entity_type VARCHAR(50), -- load, chat, verification_request
    related_entity_id UUID,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Indexes for notifications
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_user_unread ON public.notifications(user_id, is_read, created_at DESC);
CREATE INDEX idx_notifications_created_at ON public.notifications(created_at DESC);

-- Enable RLS
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- RLS Policies for notifications
CREATE POLICY "Users can read own notifications"
    ON public.notifications
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications"
    ON public.notifications
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- ============================================
-- 3. RATINGS (User Feedback)
-- ============================================

CREATE TABLE IF NOT EXISTS public.ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rater_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    rated_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    load_id UUID REFERENCES public.loads(id) ON DELETE SET NULL,
    rating_value INT NOT NULL CHECK (rating_value >= 1 AND rating_value <= 5),
    feedback_text TEXT,
    rating_type VARCHAR(50) NOT NULL, -- supplier_rating, trucker_rating
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_rating_per_load UNIQUE (rater_user_id, rated_user_id, load_id)
);

-- Indexes for ratings
CREATE INDEX idx_ratings_rated_user ON public.ratings(rated_user_id);
CREATE INDEX idx_ratings_rater_user ON public.ratings(rater_user_id);
CREATE INDEX idx_ratings_load_id ON public.ratings(load_id);

-- Enable RLS
ALTER TABLE public.ratings ENABLE ROW LEVEL SECURITY;

-- RLS Policies for ratings
CREATE POLICY "Users can create ratings"
    ON public.ratings
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = rater_user_id);

CREATE POLICY "Users can read ratings about them"
    ON public.ratings
    FOR SELECT
    TO authenticated
    USING (auth.uid() = rated_user_id OR auth.uid() = rater_user_id);

CREATE POLICY "Users can update own ratings"
    ON public.ratings
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = rater_user_id)
    WITH CHECK (auth.uid() = rater_user_id);

-- Trigger for updated_at
CREATE TRIGGER set_ratings_updated_at
    BEFORE UPDATE ON public.ratings
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

-- Function: Get average rating for a user
CREATE OR REPLACE FUNCTION public.get_user_average_rating(p_user_id UUID)
RETURNS DECIMAL(3, 2)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_avg_rating DECIMAL(3, 2);
BEGIN
    SELECT ROUND(AVG(rating_value)::NUMERIC, 2) INTO v_avg_rating
    FROM public.ratings
    WHERE rated_user_id = p_user_id;

    RETURN COALESCE(v_avg_rating, 0.00);
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_user_average_rating TO authenticated;

-- Function: Get unread notification count
CREATE OR REPLACE FUNCTION public.get_unread_notification_count(p_user_id UUID)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM public.notifications
    WHERE user_id = p_user_id AND is_read = FALSE;

    RETURN COALESCE(v_count, 0);
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_unread_notification_count TO authenticated;

-- Comments
COMMENT ON TABLE public.saved_searches IS 'User-defined search criteria for load alerts';
COMMENT ON TABLE public.notifications IS 'In-app notifications for users';
COMMENT ON TABLE public.ratings IS 'User ratings and feedback system';
COMMENT ON FUNCTION public.get_user_average_rating IS 'Calculate average rating for a user';
COMMENT ON FUNCTION public.get_unread_notification_count IS 'Get count of unread notifications for a user';
