-- Restrict GDPR anonymization to server-side execution only.

DO $$ BEGIN
  IF to_regprocedure('public.anonymize_deleted_user(uuid)') IS NOT NULL THEN
    EXECUTE 'REVOKE EXECUTE ON FUNCTION public.anonymize_deleted_user(UUID) FROM authenticated';
    EXECUTE 'GRANT EXECUTE ON FUNCTION public.anonymize_deleted_user(UUID) TO service_role';
  END IF;
END $$;
