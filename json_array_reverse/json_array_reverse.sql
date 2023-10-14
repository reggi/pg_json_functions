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
