# Architecture

## Design Philosophy

`sdf_fields` is the **geometry layer** of the RepoScripter knowledge pack ecosystem. While `noise_fields` handles textures and displacement, `sdf_fields` handles shapes, scenes, and spatial composition.

## Data Flow

```
Natural Language ("melting organic blobs")
  ↓
RepoScripter matches style_tags
  ↓
Selects primitives + operations from recipe
  ↓
Assembles sceneSDF() from shader chunks
  ↓
Wraps in raymarcher + lighting
  ↓
Complete fragment shader
```

## Companion Packs

- **noise_fields**: Provides displacement functions for SDF surfaces (e.g., `sdSphere(p, 1.0) + fbmSimplex(p * 5.0) * 0.1`)
- **color_fields** (planned): Color ramps, palettes, and tonemapping for final output

## Key Concepts

### Exact vs Approximate SDFs

Exact SDFs (sphere, box, torus) return the true distance to the surface. The ray marcher can take full-size steps safely.

Approximate SDFs (gyroid, mandelbulb, twisted/bent shapes) return an *estimate* that may be too large. The ray marcher must use a reduced step multiplier (0.5-0.7) to avoid overshooting the surface.

Each primitive's `complexity_notes` documents this.

### Step Multiplier

When composing scenes, use the most conservative step multiplier from all shapes present. If the scene includes a gyroid (0.7) and a mandelbulb (0.5), use 0.5 for the whole scene.
