SELECT * FROM json_path_set('{"a": {"b": {"c": 1}}}', '$.a.b.d', '2'::jsonb);
