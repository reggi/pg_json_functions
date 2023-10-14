CREATE OR REPLACE FUNCTION json_array_append(
  arr jsonb,
  item jsonb
)
RETURNS jsonb AS $$
BEGIN
  RETURN arr || item;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION json_array_prepend(
  arr jsonb,
  item jsonb
)
RETURNS jsonb AS $$
BEGIN
  RETURN item || arr;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION json_array_reorder(
  arr jsonb,
  source int,
  dest int
) RETURNS jsonb AS $$
DECLARE 
    item_to_move jsonb;
BEGIN
    -- Extract the item to be moved
    item_to_move := arr -> source;

    -- Remove the item from its original position
    arr := arr - source;

    -- Split the array into parts before and after the target position
    WITH parts AS (
        SELECT 
            jsonb_agg(value) FILTER (WHERE rn < dest) as before_target,
            jsonb_agg(value) FILTER (WHERE rn >= dest) as after_target
        FROM (
            SELECT value, row_number() OVER () - 1 as rn
            FROM jsonb_array_elements(arr)
        ) s
    )
    SELECT 
        COALESCE(before_target, '[]'::jsonb) || item_to_move || COALESCE(after_target, '[]'::jsonb)
    INTO arr
    FROM parts;

    RETURN arr;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION json_array_reverse(
  arr jsonb
)
RETURNS jsonb AS $$
DECLARE
  reversed jsonb := '[]';
  len int;
  i int;
BEGIN
  len := jsonb_array_length(arr);
  FOR i IN 0..(len - 1) LOOP
    reversed := jsonb_set(reversed, array_append('{}', i)::text[], arr->(len - i - 1));
  END LOOP;
  RETURN reversed;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION json_array_slide(
  arr jsonb,
  source int,
  direction varchar
) RETURNS jsonb AS $$
DECLARE 
   item_to_move jsonb;
   target_position int;
BEGIN
   -- Extract the item to be moved
   item_to_move := arr -> source;

   -- Decide target position based on direction
   IF direction = 'forward' THEN
       target_position := source - 1;
   ELSIF direction = 'backward' THEN
       target_position := source + 1;
   ELSE
       RAISE EXCEPTION 'Invalid direction';
   END IF;

   -- Remove the item from its original position
   arr := arr - source;

   -- Split the array into parts before and after the target position
   WITH parts AS (
       SELECT 
           jsonb_agg(value) FILTER (WHERE rn < target_position) as before_target,
           jsonb_agg(value) FILTER (WHERE rn >= target_position) as after_target
       FROM (
           SELECT value, row_number() OVER () - 1 as rn
           FROM jsonb_array_elements(arr)
       ) s
   )
   SELECT 
       COALESCE(before_target, '[]'::jsonb) || item_to_move || COALESCE(after_target, '[]'::jsonb)
   INTO arr
   FROM parts;

   RETURN arr;
END;
$$ LANGUAGE plpgsql;

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


CREATE OR REPLACE FUNCTION json_path_set(
  obj jsonb,
  selector text,
  val jsonb
) RETURNS jsonb LANGUAGE plpgsql AS $$
BEGIN
  RETURN jsonb_set(obj, json_path_to_target(selector)::text[], val);
END;
$$;


-- converts a rough json path to a target string for use with json_set which is
-- in the format {key1,key2,key3}

CREATE OR REPLACE FUNCTION json_path_to_target(
  selector text
)
RETURNS text LANGUAGE plpgsql AS $$
DECLARE
  result text := '';
  element text;
BEGIN
  FOR element IN (SELECT unnest(string_to_array(ltrim(selector, '$.'), '.')))
  LOOP
    element := regexp_replace(element, '\[(\d+)\]', ',\1', 'g');
    result := result || ',' || element;
  END LOOP;

  RETURN '{' || ltrim(result, ',') || '}';
END;
$$;


-- depends: json_array_append,json_path_set
  
CREATE OR REPLACE FUNCTION json_prop_array_append(
    obj jsonb,
    selector text,
    item jsonb
) RETURNS jsonb AS $$
DECLARE
    target_array jsonb;
    modified_array jsonb;
BEGIN
    -- Extract the target array from the input JSONB using the given property path
    target_array := jsonb_path_query(obj, selector::JSONPATH);

    -- Use the provided function to reorder the target array
    modified_array := json_array_append(target_array, item);

    -- Replace the original array with the reordered one in the input JSONB
    RETURN json_path_set(obj, selector, modified_array);
END;
$$ LANGUAGE plpgsql;


-- depends: json_array_prepend,json_path_set
  
CREATE OR REPLACE FUNCTION json_prop_array_prepend(
    obj jsonb,
    selector text,
    item jsonb
) RETURNS jsonb AS $$
DECLARE
    target_array jsonb;
    modified_array jsonb;
BEGIN
    -- Extract the target array from the input JSONB using the given property path
    target_array := jsonb_path_query(obj, selector::JSONPATH);

    -- Use the provided function to reorder the target array
    modified_array := json_array_prepend(target_array, item);

    -- Replace the original array with the reordered one in the input JSONB
    RETURN json_path_set(obj, selector, modified_array);
END;
$$ LANGUAGE plpgsql;


-- depends: json_array_reorder,json_path_set

CREATE OR REPLACE FUNCTION json_prop_array_reorder(
    obj jsonb,
    selector text,
    source int,
    dest int
) RETURNS jsonb AS $$
DECLARE
    target_array jsonb;
    modified_array jsonb;
BEGIN
    -- Extract the target array from the input JSONB using the given property path
    target_array := jsonb_path_query(obj, selector::JSONPATH);

    -- Use the provided function to reorder the target array
    modified_array := json_array_reorder(target_array, source, dest);

    -- Replace the original array with the reordered one in the input JSONB
    RETURN json_path_set(obj, selector, modified_array);
END;
$$ LANGUAGE plpgsql;


-- depends: json_array_reverse,json_path_set

CREATE OR REPLACE FUNCTION json_prop_array_reverse(
    obj jsonb,
    selector text
) RETURNS jsonb AS $$
DECLARE
    target_array jsonb;
    modified_array jsonb;
BEGIN
    -- Extract the target array from the input JSONB using the given property path
    target_array := jsonb_path_query(obj, selector::JSONPATH);

    -- Use the provided function to reorder the target array
    modified_array := json_array_reverse(target_array);

    -- Replace the original array with the reordered one in the input JSONB
    RETURN json_path_set(obj, selector, modified_array);
END;
$$ LANGUAGE plpgsql;


-- depends: json_prop_array_slide,json_path_set

CREATE OR REPLACE FUNCTION json_prop_array_slide(
    obj jsonb,
    selector text,
    source int,
    direction varchar
) RETURNS jsonb AS $$
DECLARE
    target_array jsonb;
    modified_array jsonb;
BEGIN
    -- Extract the target array from the input JSONB using the given property path
    target_array := jsonb_path_query(obj, selector::JSONPATH);

    -- Use the provided function to reorder the target array
    modified_array := json_array_slide(target_array, source, direction);

    -- Replace the original array with the reordered one in the input JSONB
    RETURN json_path_set(obj, selector, modified_array);
END;
$$ LANGUAGE plpgsql;


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
