-- Manual Test Admin User Creation
-- Execute this in Supabase SQL Editor after creating the auth user

-- STEP 1: Create a test admin user via Supabase Dashboard Authentication section
-- Email: admin@transfort.app
-- Password: Admin@123456
-- Make sure to enable email confirmation

-- STEP 2: After creating the auth user, get their UUID and run:
-- Replace 'YOUR_USER_UUID_HERE' with the actual UUID from auth.users table

-- Get the user UUID first:
SELECT id, email, created_at FROM auth.users WHERE email = 'admin@transfort.app';

-- Then insert the admin profile (replace UUID):
INSERT INTO public.admin_profiles (
  id,
  role,
  full_name
) VALUES (
  'YOUR_USER_UUID_HERE', -- Replace with actual UUID from above query
  'super_admin',
  'Test Super Admin'
) ON CONFLICT (id) DO UPDATE SET
  role = EXCLUDED.role,
  full_name = EXCLUDED.full_name,
  updated_at = NOW();

-- Verify admin profile was created:
SELECT ap.*, u.email 
FROM public.admin_profiles ap
JOIN auth.users u ON ap.id = u.id
WHERE u.email = 'admin@transfort.app';
