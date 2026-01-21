-- Create admin user for testing
-- This script should be run in Supabase SQL Editor

-- First, create a user in auth.users (you need to do this via Supabase Dashboard or API)
-- Then create the admin profile

-- Insert admin profile for testing
-- Replace 'USER_ID_HERE' with the actual UUID from auth.users table
INSERT INTO public.admin_profiles (
  id,
  role,
  full_name
) VALUES (
  'USER_ID_HERE', -- Replace with actual user UUID
  'super_admin',
  'Test Admin'
) ON CONFLICT (id) DO UPDATE SET
  role = EXCLUDED.role,
  full_name = EXCLUDED.full_name,
  updated_at = NOW();

-- Create a trigger function to automatically create admin profile for admin users
CREATE OR REPLACE FUNCTION public.handle_new_admin_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if user email contains 'admin' to auto-create admin profile
  IF NEW.email LIKE '%admin%' THEN
    INSERT INTO public.admin_profiles (id, role, full_name)
    VALUES (NEW.id, 'super_admin', COALESCE(NEW.raw_user_meta_data->>'name', 'Admin User'))
    ON CONFLICT (id) DO NOTHING;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to automatically create admin profile
DROP TRIGGER IF EXISTS on_auth_admin_user_created ON auth.users;
CREATE TRIGGER on_auth_admin_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_admin_user();
