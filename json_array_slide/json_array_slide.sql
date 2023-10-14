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