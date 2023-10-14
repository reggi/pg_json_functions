SELECT * FROM json_prop_array_reverse('{
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
}'::jsonb, '$.data.info.tags');