-- Restrict is_admin() and is_super_admin() execution from anon role
REVOKE EXECUTE ON FUNCTION public.is_admin() FROM anon;
REVOKE EXECUTE ON FUNCTION public.is_super_admin() FROM anon;
