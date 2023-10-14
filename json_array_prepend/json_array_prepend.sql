CREATE OR REPLACE FUNCTION json_array_prepend(
  arr jsonb,
  item jsonb
)
RETURNS jsonb AS $$
BEGIN
  RETURN item || arr;
END;
$$ LANGUAGE plpgsql;
