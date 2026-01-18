-- Security hardening: lock down function search_path
-- This reduces Supabase Studio security warnings about mutable search_path.

ALTER FUNCTION public.update_updated_at_column()
  SET search_path = public, pg_catalog;

ALTER FUNCTION public.handle_new_user()
  SET search_path = public, auth, pg_catalog;

ALTER FUNCTION public.increment_load_view_count(UUID)
  SET search_path = public, pg_catalog;
