-- Add explicit search_path to all SECURITY DEFINER functions for security hardening

-- Notification RPCs
DO $$ BEGIN
  IF to_regprocedure('public.notify_chat_message(uuid,text)') IS NOT NULL THEN
    EXECUTE 'ALTER FUNCTION public.notify_chat_message(uuid, text) SET search_path = public, pg_catalog';
  END IF;
  IF to_regprocedure('public.notify_offer_created(uuid)') IS NOT NULL THEN
    EXECUTE 'ALTER FUNCTION public.notify_offer_created(uuid) SET search_path = public, pg_catalog';
  END IF;
  IF to_regprocedure('public.notify_offer_accepted(uuid)') IS NOT NULL THEN
    EXECUTE 'ALTER FUNCTION public.notify_offer_accepted(uuid) SET search_path = public, pg_catalog';
  END IF;
  IF to_regprocedure('public.notify_rc_requested(uuid)') IS NOT NULL THEN
    EXECUTE 'ALTER FUNCTION public.notify_rc_requested(uuid) SET search_path = public, pg_catalog';
  END IF;
  IF to_regprocedure('public.notify_rc_approved(uuid)') IS NOT NULL THEN
    EXECUTE 'ALTER FUNCTION public.notify_rc_approved(uuid) SET search_path = public, pg_catalog';
  END IF;
END $$;

-- Analytics functions
DO $$ BEGIN
  IF to_regprocedure('public.get_daily_active_users()') IS NOT NULL THEN
    EXECUTE 'ALTER FUNCTION public.get_daily_active_users() SET search_path = public, pg_catalog';
  END IF;
  IF to_regprocedure('public.get_new_loads_today()') IS NOT NULL THEN
    EXECUTE 'ALTER FUNCTION public.get_new_loads_today() SET search_path = public, pg_catalog';
  END IF;
  IF to_regprocedure('public.get_load_conversion_rate()') IS NOT NULL THEN
    EXECUTE 'ALTER FUNCTION public.get_load_conversion_rate() SET search_path = public, pg_catalog';
  END IF;
  IF to_regprocedure('public.get_user_growth_last_7_days()') IS NOT NULL THEN
    EXECUTE 'ALTER FUNCTION public.get_user_growth_last_7_days() SET search_path = public, pg_catalog';
  END IF;
END $$;

-- Data retention functions
DO $$ BEGIN
  IF to_regprocedure('public.anonymize_deleted_user(uuid)') IS NOT NULL THEN
    EXECUTE 'ALTER FUNCTION public.anonymize_deleted_user(uuid) SET search_path = public, pg_catalog';
  END IF;
  IF to_regprocedure('public.delete_expired_loads()') IS NOT NULL THEN
    EXECUTE 'ALTER FUNCTION public.delete_expired_loads() SET search_path = public, pg_catalog';
  END IF;
  IF to_regprocedure('public.archive_old_analytics()') IS NOT NULL THEN
    EXECUTE 'ALTER FUNCTION public.archive_old_analytics() SET search_path = public, pg_catalog';
  END IF;
  IF to_regprocedure('public.cleanup_old_notifications()') IS NOT NULL THEN
    EXECUTE 'ALTER FUNCTION public.cleanup_old_notifications() SET search_path = public, pg_catalog';
  END IF;
  IF to_regprocedure('public.cleanup_inactive_chats()') IS NOT NULL THEN
    EXECUTE 'ALTER FUNCTION public.cleanup_inactive_chats() SET search_path = public, pg_catalog';
  END IF;
END $$;

-- Maintenance/helper functions
DO $$ BEGIN
  IF to_regprocedure('public.expire_old_loads()') IS NOT NULL THEN
    EXECUTE 'ALTER FUNCTION public.expire_old_loads() SET search_path = public, pg_catalog';
  END IF;
  IF to_regprocedure('public.get_user_average_rating(uuid)') IS NOT NULL THEN
    EXECUTE 'ALTER FUNCTION public.get_user_average_rating(uuid) SET search_path = public, pg_catalog';
  END IF;
  IF to_regprocedure('public.get_unread_notification_count(uuid)') IS NOT NULL THEN
    EXECUTE 'ALTER FUNCTION public.get_unread_notification_count(uuid) SET search_path = public, pg_catalog';
  END IF;
  IF to_regprocedure('public.increment_load_view_count(uuid)') IS NOT NULL THEN
    EXECUTE 'ALTER FUNCTION public.increment_load_view_count(uuid) SET search_path = public, pg_catalog';
  END IF;
  IF to_regprocedure('public.should_show_ad(uuid)') IS NOT NULL THEN
    EXECUTE 'ALTER FUNCTION public.should_show_ad(uuid) SET search_path = public, pg_catalog';
  END IF;
END $$;

-- Admin RBAC functions
DO $$ BEGIN
  IF to_regprocedure('public.is_admin()') IS NOT NULL THEN
    EXECUTE 'ALTER FUNCTION public.is_admin() SET search_path = public, pg_catalog';
  END IF;
  IF to_regprocedure('public.is_super_admin()') IS NOT NULL THEN
    EXECUTE 'ALTER FUNCTION public.is_super_admin() SET search_path = public, pg_catalog';
  END IF;
END $$;

-- Verification trigger function
DO $$ BEGIN
  IF to_regprocedure('public.update_user_verification_status()') IS NOT NULL THEN
    EXECUTE 'ALTER FUNCTION public.update_user_verification_status() SET search_path = public, pg_catalog';
  END IF;
END $$;

-- Auth trigger function
DO $$ BEGIN
  IF to_regprocedure('public.handle_new_user()') IS NOT NULL THEN
    EXECUTE 'ALTER FUNCTION public.handle_new_user() SET search_path = public, pg_catalog';
  END IF;
END $$;
