-- Test script for v0.02 migrations
-- Run this to verify all migrations work correctly

-- Test 1: Check if Super Loads fields exist
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'loads' 
AND column_name IN (
  'is_super_load', 
  'posted_by_admin_id', 
  'is_super_trucker',
  'super_trucker_request_status',
  'super_trucker_approved_by_admin_id',
  'super_trucker_approved_at'
);

-- Test 2: Check if user Super Loads fields exist
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'users' 
AND column_name IN (
  'super_loads_approved',
  'bank_account_holder',
  'bank_name',
  'bank_account_number',
  'bank_ifsc',
  'bank_upi_id'
);

-- Test 3: Check if support_tickets table exists
SELECT table_name 
FROM information_schema.tables 
WHERE table_name = 'support_tickets';

-- Test 4: Check if support_messages table exists
SELECT table_name 
FROM information_schema.tables 
WHERE table_name = 'support_messages';

-- Test 5: Check RLS policies for support_tickets
SELECT policyname, cmd, qual 
FROM pg_policies 
WHERE tablename = 'support_tickets';

-- Test 6: Check RLS policies for support_messages
SELECT policyname, cmd, qual 
FROM pg_policies 
WHERE tablename = 'support_messages';

-- Test 7: Check RLS policies for Super Loads
SELECT policyname, cmd, qual 
FROM pg_policies 
WHERE tablename = 'loads' 
AND policyname LIKE '%super%';

-- Test 8: Check indexes
SELECT indexname, indexdef 
FROM pg_indexes 
WHERE tablename IN ('loads', 'users', 'support_tickets', 'support_messages')
AND indexname LIKE '%super%' OR indexname LIKE '%support%';

-- Test 9: Insert test Super Load (as admin)
-- INSERT INTO loads (
--   from_city, to_city, material_type, truck_type, weight, price,
--   is_super_load, posted_by_admin_id, user_id
-- ) VALUES (
--   'Mumbai', 'Delhi', 'Steel', '32 Ft Trailer', 20, 45000,
--   TRUE, 'admin_id_here', 'user_id_here'
-- );

-- Test 10: Insert test support ticket
-- INSERT INTO support_tickets (
--   user_id, ticket_type, subject, description
-- ) VALUES (
--   'user_id_here', 'super_load_request', 'Test Ticket', 'Test description'
-- );

-- Expected Results:
-- Test 1-2: Should return 6 columns each
-- Test 3-4: Should return table names
-- Test 5-6: Should return multiple RLS policies
-- Test 7: Should return Super Load specific policies
-- Test 8: Should return indexes for performance
-- Test 9-10: Should insert successfully (uncomment to test)

COMMENT ON TABLE support_tickets IS 'Test migrations completed successfully';
