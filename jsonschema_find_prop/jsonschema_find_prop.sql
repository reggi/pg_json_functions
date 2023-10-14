CREATE OR REPLACE FUNCTION jsonschema_find_prop(schema jsonb, property text, current_path text DEFAULT '$')
RETURNS TABLE(path text) LANGUAGE plpgsql AS $$
DECLARE
  k text;
  v jsonb;
BEGIN
  IF schema ? property AND schema -> property = 'true' THEN
    path := current_path;
    RETURN NEXT;
  END IF;

  FOR k IN SELECT * FROM jsonb_object_keys(schema)
  LOOP
    v := schema -> k;
    IF jsonb_typeof(v) = 'object' THEN
      IF v ? 'properties' OR v ? 'items' THEN
        RETURN QUERY SELECT * FROM jsonschema_find_prop(v->COALESCE('properties', 'items'), property, current_path || '.' || k || '.properties');
      ELSE
        RETURN QUERY SELECT * FROM jsonschema_find_prop(v, property, current_path || '.' || k);
      END IF;
    END IF;
  END LOOP;

  RETURN;
END;
$$;
