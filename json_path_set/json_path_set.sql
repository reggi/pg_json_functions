CREATE OR REPLACE FUNCTION json_path_set(
  obj jsonb,
  selector text,
  val jsonb
) RETURNS jsonb LANGUAGE plpgsql AS $$
BEGIN
  RETURN jsonb_set(obj, json_path_to_target(selector)::text[], val);
END;
$$;
