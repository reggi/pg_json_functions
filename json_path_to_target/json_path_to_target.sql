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
