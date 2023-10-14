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
