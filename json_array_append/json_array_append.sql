CREATE OR REPLACE FUNCTION json_array_append(
  arr jsonb,
  item jsonb
)
RETURNS jsonb AS $$
BEGIN
  RETURN arr || item;
END;
$$ LANGUAGE plpgsql;
