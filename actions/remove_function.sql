-- SELECT 'DROP FUNCTION ' || oid::regprocedure
-- FROM   pg_proc
-- WHERE  proname = 'jsonschema_find_prop'  -- name without schema-qualification
-- AND    pg_function_is_visible(oid);  -- restrict to current search_path

-- CREATE OR REPLACE FUNCTION remove_function(func_name text)
-- RETURNS void LANGUAGE plpgsql AS $$
-- DECLARE
--   func_record RECORD;
-- BEGIN
--   FOR func_record IN (
--     SELECT oid::regprocedure
--     FROM pg_proc
--     WHERE proname = func_name
--   )
--   LOOP
--     EXECUTE 'DROP FUNCTION IF EXISTS ' || func_record.oid;
--   END LOOP;
-- END;
-- $$;

DROP FUNCTION jsonschema_find_prop(jsonb,text);
DROP FUNCTION jsonschema_find_prop(jsonb,text,text);
-- DROP FUNCTION jsonschema_find_prop(jsonb,text,text[]);