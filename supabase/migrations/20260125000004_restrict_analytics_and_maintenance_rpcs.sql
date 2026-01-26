-- Restrict admin analytics RPCs to admin-only execution
DO $$ BEGIN
  IF to_regprocedure('public.get_daily_active_users()') IS NOT NULL THEN
    EXECUTE 'REVOKE EXECUTE ON FUNCTION public.get_daily_active_users() FROM authenticated';
  END IF;
  IF to_regprocedure('public.get_new_loads_today()') IS NOT NULL THEN
    EXECUTE 'REVOKE EXECUTE ON FUNCTION public.get_new_loads_today() FROM authenticated';
  END IF;
  IF to_regprocedure('public.get_load_conversion_rate()') IS NOT NULL THEN
    EXECUTE 'REVOKE EXECUTE ON FUNCTION public.get_load_conversion_rate() FROM authenticated';
  END IF;
  IF to_regprocedure('public.get_user_growth_last_7_days()') IS NOT NULL THEN
    EXECUTE 'REVOKE EXECUTE ON FUNCTION public.get_user_growth_last_7_days() FROM authenticated';
  END IF;
END $$;

-- Restrict maintenance RPCs to service_role only
DO $$ BEGIN
  IF to_regprocedure('public.expire_old_loads()') IS NOT NULL THEN
    EXECUTE 'REVOKE EXECUTE ON FUNCTION public.expire_old_loads() FROM authenticated';
    EXECUTE 'GRANT EXECUTE ON FUNCTION public.expire_old_loads() TO service_role';
  END IF;
END $$;

-- Tighten analytics_events grants (remove anon access)
DO $$ BEGIN
  IF to_regclass('public.analytics_events') IS NOT NULL THEN
    EXECUTE 'REVOKE ALL ON public.analytics_events FROM anon';
    EXECUTE 'REVOKE SELECT, INSERT ON public.analytics_events FROM anon';
  END IF;
END $$;

-- Restrict analytics_summary view to admins only
DO $$ BEGIN
  IF to_regclass('public.analytics_summary') IS NOT NULL THEN
    EXECUTE 'REVOKE SELECT ON public.analytics_summary FROM authenticated';
  END IF;
END $$;
