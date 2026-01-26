-- Admin App Diagnostic Script
-- Run this in Supabase SQL Editor to verify everything is set up correctly

-- 1. Check if admin_profiles table exists and has data
SELECT 
    'admin_profiles table check' as test,
    COUNT(*) as admin_count,
    COUNT(CASE WHEN role = 'super_admin' THEN 1 END) as super_admin_count
FROM admin_profiles;

-- 2. List all admins with their roles
SELECT 
    id,
    role,
    full_name,
    created_at
FROM admin_profiles
ORDER BY created_at DESC;

-- 3. Check if helper functions exist
SELECT 
    'Helper functions check' as test,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'is_admin') as is_admin_exists,
    EXISTS(SELECT 1 FROM pg_proc WHERE proname = 'is_super_admin') as is_super_admin_exists;

-- 4. Check loads table has super load columns
SELECT 
    'loads table schema check' as test,
    EXISTS(
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'loads' AND column_name = 'is_super_load'
    ) as has_is_super_load,
    EXISTS(
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'loads' AND column_name = 'posted_by_admin_id'
    ) as has_posted_by_admin_id;

-- 5. Check RLS policies on loads table
SELECT 
    policyname,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE tablename = 'loads'
ORDER BY policyname;

-- 6. Count super loads (if any)
SELECT 
    'Super loads count' as test,
    COUNT(*) as total_loads,
    COUNT(CASE WHEN is_super_load = true THEN 1 END) as super_loads_count
FROM loads;

-- 7. Check if you have an admin account
-- Replace 'YOUR_EMAIL@example.com' with your actual email
SELECT 
    u.id,
    u.email,
    ap.role,
    ap.full_name,
    CASE 
        WHEN ap.id IS NULL THEN '❌ NOT AN ADMIN'
        WHEN ap.role = 'super_admin' THEN '✅ SUPER ADMIN'
        ELSE '✅ ADMIN'
    END as status
FROM auth.users u
LEFT JOIN admin_profiles ap ON u.id = ap.id
WHERE u.email = 'YOUR_EMAIL@example.com';  -- CHANGE THIS TO YOUR EMAIL

-- If you don't have an admin account, create one with this:
-- (Uncomment and replace with your user ID and details)
/*
INSERT INTO admin_profiles (id, role, full_name)
VALUES (
    'YOUR_USER_ID_HERE',  -- Get this from auth.users table
    'super_admin',
    'Your Full Name'
);
*/
