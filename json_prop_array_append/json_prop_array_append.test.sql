SELECT * FROM json_prop_array_append('{
  "data": {
    "info": {
      "tags": [
        "web3",
        "decentralization",
        "principles"
      ]
    },
    "other": {
      "notes": [
        "one",
        "two",
        "three"
      ]
    }
  }
}'::jsonb, '$.data.info.tags', '"federation"'::jsonb);