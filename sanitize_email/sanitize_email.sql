-- DROP FUNCTION IF EXISTS sanitize_email(TEXT);

CREATE OR REPLACE FUNCTION sanitize_email(
  email text
) RETURNS TEXT AS $$
DECLARE
    email_local_part TEXT;
    email_domain_part TEXT;
    sanitized_email TEXT;
BEGIN
    -- Split email into local and domain parts
    email_local_part := SPLIT_PART(email, '@', 1);
    email_domain_part := SPLIT_PART(email, '@', 2);

    -- Remove periods and lowercase the local part
    email_local_part := REPLACE(email_local_part, '.', '');
    email_local_part := LOWER(email_local_part);

    -- Combine to get the sanitized email
    sanitized_email := email_local_part || '@' || LOWER(email_domain_part);

    RETURN sanitized_email;
END;
$$ LANGUAGE plpgsql;
