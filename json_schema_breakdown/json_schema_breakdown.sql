-- DROP FUNCTION IF EXISTS json_schema_breakdown(jsonb, text);

CREATE OR REPLACE FUNCTION json_schema_breakdown(
  schema jsonb,
  current_path text DEFAULT '$'
)
RETURNS TABLE(path text, stub jsonb) AS $$
DECLARE
    keys text[];
    key text;
    value jsonb;
    i int;
BEGIN
    -- If it's an object with properties, break it down
    IF schema ? 'type' AND (schema ->> 'type') = 'object' AND schema ? 'properties' THEN
        keys := ARRAY(SELECT jsonb_object_keys(schema -> 'properties'));
        FOREACH key IN ARRAY keys LOOP
            RETURN QUERY EXECUTE 'SELECT * FROM json_schema_breakdown($1, $2);'
                USING (schema -> 'properties' -> key), (current_path || '.properties.' || key);
        END LOOP;

    -- If it's an array, break it down
    ELSIF schema ? 'type' AND (schema ->> 'type') = 'array' THEN
        IF jsonb_typeof(schema -> 'items') = 'array' THEN
            i := 1;
            FOR value IN (SELECT * FROM jsonb_array_elements(schema -> 'items')) LOOP
                RETURN QUERY EXECUTE 'SELECT * FROM json_schema_breakdown($1::jsonb, $2);'
                    USING value, (current_path || '.items[' || i::text || ']'); -- Wrapping index with [ ]
                i := i + 1;
            END LOOP;
        ELSE
            RETURN QUERY EXECUTE 'SELECT * FROM json_schema_breakdown($1, $2);'
                USING (schema -> 'items'), (current_path || '.items');
        END IF;
    END IF;  -- <--- This was missing

    path := current_path; -- Assign the current_path value to the path column
    stub := schema; -- Assign the current schema value to the stub column
    RETURN NEXT;
    RETURN;
END;
$$ LANGUAGE plpgsql;
