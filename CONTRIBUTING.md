# Contributing to sdf_fields

## Quick Checklist

- [ ] JSON files are valid (`python3 -m json.tool your_file.json`)
- [ ] New primitives have both GLSL and WGSL shader implementations
- [ ] New entries are added to the appropriate `index.json`
- [ ] Recipes have at least 4 style tags and 2 example prompts
- [ ] Parameter presets have meaningful `style_tags`
- [ ] `art_failure_modes` are documented for any new primitive or operation

## What to Contribute

### High Value
- New SDF primitives (cone, hexagonal prism, link, Möbius strip)
- New operations (domain repetition variants, kaleidoscopic folds)
- New recipes with unique visual aesthetics
- Bug fixes in shader implementations
- Performance-tuned variants of expensive SDFs

### Always Welcome
- Better `art_failure_modes` descriptions
- More `canonical_parameter_sets` on existing primitives
- Example shaders for existing recipes
- Documentation improvements

## Validation

```bash
find sdf_fields -name "*.json" -exec python3 -m json.tool {} \; > /dev/null
```
