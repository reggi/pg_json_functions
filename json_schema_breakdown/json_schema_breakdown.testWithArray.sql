SELECT * FROM json_schema_breakdown('{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    "title": {
      "type": "string",
      "minLength": 1,
      "maxLength": 4096
    },
    "url": {
      "type": "string",
      "format": "uri"
    },
    "summary": {
      "type": "string",
      "minLength": 1,
      "maxLength": 4096
    },
    "tags": {
      "type": "array",
      "items": [
        {"type": "string"},
        {"type": "number"}
      ],
      "maxItems": 10
    },
    "screenshot": {
      "type": "string",
      "pattern": "^/.*\\.(jpeg|jpg|png|gif|webp)$"
    }
  },
  "required": ["title", "url"]
}
');