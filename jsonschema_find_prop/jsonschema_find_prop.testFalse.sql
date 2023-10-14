SELECT * FROM jsonschema_find_prop('{
  "type": "object",
  "properties": {
    "name": {
      "type": "string"
    },
    "age": {
      "type": "integer",
      "unique": false
    }
  }
}'::jsonb, 'unique')