# Adding Recipes

## Recipe Schema

```json
{
  "id": "your_recipe_id",
  "description": "One-line visual description.",
  "sdf_graph": {
    "primitives": [
      { "type": "primitive_id", "preset": "canonical_preset_id" }
    ],
    "operations": [
      { "type": "operation_id", "preset": "operation_preset_id" }
    ]
  },
  "style_tags": ["tag1", "tag2", "tag3", "tag4"],
  "example_prompts": ["natural language instruction 1", "another way to say it"],
  "screenshot_metadata": { "camera": {}, "lighting": "", "notes": "" }
}
```

## Tips

- Reference noise_fields presets for displacement: `"source": "noise_fields/simplex"`
- Specify step multiplier in notes if using approximate SDFs
- Include at least one "how to light this" hint in screenshot_metadata
