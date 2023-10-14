SELECT * FROM json_schema_breakdown('{
  "type": "object",
  "properties": {
    "name": {
      "type": "object",
      "properties": {
        "name": {
          "type": "string"
        }
      }
    }
  }
}');