SELECT * FROM jsonschema_find_prop('{
  "type": "object",
  "properties": {
    "name": {
      "type": "string"
    },
    "age": {
      "type": "integer"
    },
    "nested": {
      "type": "object",
      "properties": {
        "name": {
          "type": "string"
        },
        "age": {
          "type": "integer",
          "unique": true
        }
      }
    }
  }
}'::jsonb, 'unique')