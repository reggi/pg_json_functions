SELECT * FROM jsonschema_find_prop('{
  "type": "object",
  "properties": {
    "name": {
      "type": "string",
      "unique": true
    },
    "age": {
      "type": "integer",
      "unique": true
    },
    "nested": {
      "type": "object",
      "properties": {
        "name": {
          "type": "string",
          "unique": true
        },
        "age": {
          "type": "integer",
          "unique": true
        }
      }
    }
  }
}'::jsonb, 'unique')