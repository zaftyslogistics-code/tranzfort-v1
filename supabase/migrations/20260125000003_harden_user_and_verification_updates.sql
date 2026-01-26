CREATE OR REPLACE FUNCTION public.prevent_non_admin_user_sensitive_profile_updates()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF auth.uid() IS NULL OR public.is_admin() THEN
    RETURN NEW;
  END IF;

  IF NEW.id <> OLD.id THEN
    RAISE EXCEPTION 'Not allowed';
  END IF;

  IF NEW.mobile_number IS DISTINCT FROM OLD.mobile_number THEN
    RAISE EXCEPTION 'Not allowed';
  END IF;

  IF NEW.country_code IS DISTINCT FROM OLD.country_code THEN
    RAISE EXCEPTION 'Not allowed';
  END IF;

  IF NEW.is_supplier_enabled IS DISTINCT FROM OLD.is_supplier_enabled THEN
    RAISE EXCEPTION 'Not allowed';
  END IF;

  IF NEW.is_trucker_enabled IS DISTINCT FROM OLD.is_trucker_enabled THEN
    RAISE EXCEPTION 'Not allowed';
  END IF;

  IF NEW.supplier_verification_status IS DISTINCT FROM OLD.supplier_verification_status THEN
    RAISE EXCEPTION 'Not allowed';
  END IF;

  IF NEW.trucker_verification_status IS DISTINCT FROM OLD.trucker_verification_status THEN
    RAISE EXCEPTION 'Not allowed';
  END IF;

  IF NEW.created_at IS DISTINCT FROM OLD.created_at THEN
    RAISE EXCEPTION 'Not allowed';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS prevent_non_admin_user_sensitive_profile_updates_trigger ON public.users;
CREATE TRIGGER prevent_non_admin_user_sensitive_profile_updates_trigger
BEFORE UPDATE ON public.users
FOR EACH ROW
EXECUTE FUNCTION public.prevent_non_admin_user_sensitive_profile_updates();


CREATE OR REPLACE FUNCTION public.prevent_non_admin_verification_request_tampering()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF auth.uid() IS NULL OR public.is_admin() THEN
    RETURN NEW;
  END IF;

  IF auth.uid() <> OLD.user_id THEN
    RAISE EXCEPTION 'Not allowed';
  END IF;

  IF OLD.status NOT IN ('pending', 'needs_more_info') THEN
    RAISE EXCEPTION 'Not allowed';
  END IF;

  IF NEW.user_id IS DISTINCT FROM OLD.user_id THEN
    RAISE EXCEPTION 'Not allowed';
  END IF;

  IF NEW.role_type IS DISTINCT FROM OLD.role_type THEN
    RAISE EXCEPTION 'Not allowed';
  END IF;

  IF NEW.document_type IS DISTINCT FROM OLD.document_type THEN
    RAISE EXCEPTION 'Not allowed';
  END IF;

  IF NEW.status IS DISTINCT FROM OLD.status THEN
    RAISE EXCEPTION 'Not allowed';
  END IF;

  IF NEW.rejection_reason IS DISTINCT FROM OLD.rejection_reason THEN
    RAISE EXCEPTION 'Not allowed';
  END IF;

  IF NEW.reviewed_at IS DISTINCT FROM OLD.reviewed_at THEN
    RAISE EXCEPTION 'Not allowed';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS prevent_non_admin_verification_request_tampering_trigger ON public.verification_requests;
CREATE TRIGGER prevent_non_admin_verification_request_tampering_trigger
BEFORE UPDATE ON public.verification_requests
FOR EACH ROW
EXECUTE FUNCTION public.prevent_non_admin_verification_request_tampering();
