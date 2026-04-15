# sdf_fields

**Signed Distance Functions & Geometry Pack for [RepoScripter](https://github.com/merrypranxter/reposcripter2)**

A structured, machine-readable knowledge pack that captures SDF primitives, boolean operations, space manipulation, and ray marching as JSON descriptors + working GLSL/WGSL shader implementations. The geometry counterpart to [noise_fields](https://github.com/merrypranxter/noise) — noise handles texture, SDFs handle shape.

## What This Is

A **knowledge base** encoding:

- **Primitives** — what each shape's SDF equation is, what it looks like, when it breaks
- **Operations** — how to combine, repeat, deform, and fold shapes
- **Recipes** — complete scene compositions mapping "melting blobs" or "fractal cathedral" to concrete shader code
- **Ray marching** — configurable march loop, normals, shadows, AO, lighting

## Quick Start

```bash
git clone https://github.com/merrypranxter/sdf_fields.git
```

Browse the descriptors:
```bash
cat sdf_fields/primitives/gyroid.json     # What is a gyroid?
cat sdf_fields/operations/smooth_boolean.json  # How do shapes melt together?
cat sdf_fields/recipes/melting_blobs.json      # Complete metaball recipe
```

Try an example:
```bash
# Copy examples/smooth_blobs.glsl → paste into shadertoy.com
```

## Primitives

| Primitive | Visual Keywords | Cost |
|-----------|----------------|------|
| **Sphere** | round, organic, blob, orb | trivial |
| **Box** | cubic, angular, monolith | trivial |
| **Torus** | ring, donut, portal, band | trivial |
| **Cylinder** | tube, pillar, pipe, trunk | trivial |
| **Capsule** | pill, bone, limb, connector | trivial |
| **Plane** | ground, floor, wall, infinite | trivial |
| **Octahedron** | diamond, crystal, gem, faceted | low |
| **Gyroid** | lattice, porous, coral, scaffold | low (approx SDF) |
| **Mandelbulb** | fractal, alien, cosmic, eldritch | very high |

## Operations

| Operation | What It Does | Key Parameter |
|-----------|-------------|---------------|
| **Union** | Combine shapes | — |
| **Intersection** | Only overlap region | — |
| **Subtraction** | Carve one from another | — |
| **Smooth Union** | Melt shapes together | `k` (blend radius) |
| **Smooth Subtraction** | Soft carving | `k` |
| **Infinite Repetition** | Tile space forever | `period` |
| **Limited Repetition** | Finite grid of copies | `period`, `limit` |
| **Polar Repetition** | Radial array | `count` |
| **Mirror** | Bilateral symmetry | axis |
| **Twist** | Spiral around axis | `twist_rate` |
| **Bend** | Curve like a banana | `bend_amount` |
| **Displacement** | Add noise to surface | `amplitude` |
| **Onion** | Hollow into a shell | `thickness` |
| **Round** | Soften all edges | `radius` |
| **Elongate** | Stretch without distortion | `amount` |

## Recipes

| Recipe | Description | Key Technique |
|--------|-------------|---------------|
| **Melting Blobs** | Animated metaballs | Smooth union of moving spheres |
| **Infinite Columns** | Brutalist fog architecture | Repetition + twist + fog |
| **Fractal Cathedral** | Recursive gothic interior | Space folding + subtraction |
| **Alien Eggs** | Biological horror pods | Smooth union + noise displacement |
| **Gyroid Sculpture** | Porous minimal surface | Gyroid ∩ sphere + AO |
| **Mirror Room** | Non-Euclidean infinite space | Modular repetition |
| **Boolean Creature** | Digital organism | Multi-primitive smooth union |
| **Terrain March** | Procedural landscape | Plane + FBM displacement |

## Repository Layout

```
sdf_fields/
  pack.json                          # Pack metadata (v0.1.0)
  primitives/
    index.json + 9 primitive descriptors
  operations/
    index.json + 5 operation descriptors
  shaders/
    glsl/
      primitives.glsl                # All SDF primitive functions
      operations.glsl                # Boolean, repetition, deformation
      raymarcher.glsl                # Configurable ray march loop
      lighting.glsl                  # Diffuse, specular, AO, fog, glow
    wgsl/
      (matching WGSL implementations)
  recipes/
    index.json + 8 scene recipes
docs/
  architecture.md
  adding-recipes.md
examples/
  smooth_blobs.glsl                  # ShaderToy metaball demo
  gyroid_sculpture.glsl              # ShaderToy gyroid demo
```

## Companion Packs

- **[noise_fields](https://github.com/merrypranxter/noise)** — Procedural noise for displacement, texture, and terrain generation
- **color_fields** (coming soon) — Color science, palettes, gradients, and tonemapping

## How RepoScripter Uses This

1. **Parse** primitive and operation descriptors for available shapes and composition tools
2. **Match** style descriptions to recipes via `style_tags` and `example_prompts`
3. **Assemble** `sceneSDF()` function from shader chunks (primitives + operations)
4. **Wrap** in ray marcher + lighting from the framework shaders
5. **Displace** surfaces using noise_fields for organic detail
6. **Respect** `art_failure_modes` and `complexity_notes` for reliable output

## License

MIT — see [LICENSE](LICENSE).
