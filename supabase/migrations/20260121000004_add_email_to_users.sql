ALTER TABLE public.users
ADD COLUMN IF NOT EXISTS email TEXT;

ALTER TABLE public.users
ALTER COLUMN mobile_number DROP NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email_unique
ON public.users (email)
WHERE email IS NOT NULL;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, mobile_number, country_code, email)
  VALUES (
    NEW.id,
    COALESCE(
      NEW.phone,
      SUBSTRING(REPLACE(NEW.id::text, '-', ''), 1, 15)
    ),
    COALESCE(NEW.raw_user_meta_data->>'country_code', '+91'),
    NEW.email
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

ALTER FUNCTION public.handle_new_user()
  SET search_path = public, auth, pg_catalog;
