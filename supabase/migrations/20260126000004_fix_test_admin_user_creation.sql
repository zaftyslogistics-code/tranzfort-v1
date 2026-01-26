-- Fix test admin user creation - remove placeholder insertion
-- This migration only sets up the auto-creation function and trigger

-- Remove the placeholder insertion that caused the FK violation
-- The admin profile should be created automatically when an admin user signs up

-- Enhanced function to handle admin profile creation
CREATE OR REPLACE FUNCTION public.ensure_admin_profile()
RETURNS TRIGGER AS $$
BEGIN
    -- Create admin profile for users with admin email patterns
    IF NEW.email LIKE '%admin@transfort.app%' OR NEW.email LIKE '%super.admin@%' OR NEW.email LIKE '%admin%' THEN
        INSERT INTO public.admin_profiles (id, role, full_name)
        VALUES (
            NEW.id, 
            CASE 
                WHEN NEW.email LIKE '%super.admin@%' THEN 'super_admin'
                WHEN NEW.email LIKE '%admin@transfort.app%' THEN 'super_admin'
                ELSE 'verification_officer'
            END,
            COALESCE(NEW.raw_user_meta_data->>'name', SPLIT_PART(NEW.email, '@', 1))
        )
        ON CONFLICT (id) DO UPDATE SET
            role = CASE 
                WHEN NEW.email LIKE '%super.admin@%' THEN 'super_admin'
                WHEN NEW.email LIKE '%admin@transfort.app%' THEN 'super_admin'
                ELSE EXCLUDED.role
            END,
            full_name = COALESCE(NEW.raw_user_meta_data->>'name', SPLIT_PART(NEW.email, '@', 1)),
            updated_at = NOW();
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Ensure trigger exists
DROP TRIGGER IF EXISTS ensure_admin_profile_trigger ON auth.users;
CREATE TRIGGER ensure_admin_profile_trigger
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.ensure_admin_profile();

-- Also update existing users with admin emails
DO $$
BEGIN
    UPDATE public.admin_profiles ap
    SET role = CASE 
        WHEN u.email LIKE '%super.admin@%' THEN 'super_admin'
        WHEN u.email LIKE '%admin@transfort.app%' THEN 'super_admin'
        ELSE 'verification_officer'
    END,
    full_name = COALESCE(ap.full_name, SPLIT_PART(u.email, '@', 1)),
    updated_at = NOW()
    FROM auth.users u
    WHERE ap.id = u.id 
    AND (u.email LIKE '%admin%' OR u.email LIKE '%admin@transfort.app%' OR u.email LIKE '%super.admin@%');
END $$;

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.admin_profiles TO authenticated;
