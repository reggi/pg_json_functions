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