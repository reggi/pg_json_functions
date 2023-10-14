CREATE OR REPLACE FUNCTION json_create(
  selector text,
  val jsonb
)
RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE
    keys text[];
    obj jsonb := '{}'::jsonb;
    k text;
    array_index int;
    temp jsonb := '{}'::jsonb;
    path text[] := ARRAY[]::text[];
BEGIN
    IF selector ~ '^\$' THEN
        keys := string_to_array(substr(selector, 2), '.');
    ELSE
        RAISE EXCEPTION 'Path must start with $';
    END IF;

    FOR i IN 1..array_length(keys, 1)
    LOOP
        k := keys[i];
        
        IF k ~ '\[\d+\]$' THEN
            array_index := substring(k from '\[(\d+)\]')::int;
            k := substring(k from '^[^\[]+');
            path := array_append(path, k);
            temp := jsonb_set(temp, path, '[]'::jsonb, true);
            path := array_append(path, array_index::text);
        ELSE
            path := array_append(path, k);
        END IF;

        IF i = array_length(keys, 1) THEN
            temp := jsonb_set(temp, path, val, true);
        ELSE
            temp := jsonb_set(temp, path, '{}'::jsonb, true);
        END IF;

    END LOOP;

    RETURN temp->'';
END;
$$;
