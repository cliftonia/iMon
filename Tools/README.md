# Sprite Tooling

Pipeline for authoring the game's 16×16 1-bit sprites with real pixel-art
tools instead of hand-typing hex. Sprites are stored as `[UInt16]` rows in
`SpriteFrame` (MSB = leftmost pixel) — see `imon Watch App/Sprites/SpriteFrame.swift`.

## sprite2swift.py — PNG → SpriteFrame

Converts a PNG (or a sprite-sheet grid of cells) into ready-to-paste Swift
`SpriteFrame(rows: [...])` declarations, complete with ASCII-art comments
matching the codebase style.

```bash
# Single 16×16 sprite
python3 Tools/sprite2swift.py mysprite.png --name sideWalk1

# Animation strip / sheet of 16×16 cells
python3 Tools/sprite2swift.py walk_strip.png --cell 16 --name walk

# Light sprite on a dark cell (e.g. ripped LCD sheets)
python3 Tools/sprite2swift.py cell.png --name idle1 --invert --threshold 100
```

Options: `--cell N` (cell size, default 16), `--threshold 0-255`,
`--invert` (light pixels are "on"), `--name`, `--no-ascii`.

Requires Pillow (`pip3 install Pillow`). Validated by round-trip: rendering a
known `[UInt16]` sprite to PNG and converting back reproduces the exact hex.

## swift2png.py — SpriteFrame → PNG (the reverse)

Exports existing sprites out to editable PNGs so you can trace a clean version
over the current one, completing the round-trip.

```bash
# One named constant
python3 Tools/swift2png.py "imon Watch App/Sprites/SpriteCatalog+Hopkin.swift" \
    --const sideWalk1 --out /tmp/sprites

# Every SpriteFrame in a file (e.g. all projectiles)
python3 Tools/swift2png.py "imon Watch App/Sprites/SpriteCatalog+Projectiles.swift" \
    --all --out /tmp/sprites
```

Rendered black-on-white, scaled up (`--scale`, default 16) for editing.

## Pre-exported working set

`Tools/sprites_png/` holds the current sprites ready to edit:
- `side/<Species>.png` — the 14 battle/training side profiles (`sideWalk1`).
- `projectiles/<name>.png` — the 14 projectile sprites.

## Recommended workflow (round-trip)

1. **Open** the relevant PNG from `Tools/sprites_png/` in a pixel editor —
   Aseprite or the free web tool Piskel.
2. **Trace** a clean 1-bit version, using a reference (below) as a guide.
   Pure black-on-white gives the cleanest result.
3. **Export** as PNG (or a horizontal strip for multi-frame animations).
4. **Convert** with `sprite2swift.py` and paste into the species file under
   `imon Watch App/Sprites/SpriteCatalog+<Species>.swift` (side profiles) or
   `SpriteCatalog+Projectiles.swift` (projectiles).
5. **Build & run** on the Apple Watch Ultra 3 (26.5) sim and eyeball it.

## Source quality matters

The converter only thresholds — it can't invent detail. Feed it **clean 1-bit
(black/white) art**. Shaded/anti-aliased color sprites (e.g. the reference
artbook rips) threshold into noisy, speckled silhouettes — convert those only
after flattening to 1-bit and cleaning up.

## Reference sources (authentic  virtual pet sprites)

- reference — virtual pet Sprites: https://reference.net/Category:virtual pet_Sprites
- With the Will — virtual pet LCD Sprites: https://example.net/threads/virtual pet-lcd-sprites.8803/
- With the Will — Full Color Dot Sprites: https://example.net/threads/full-color-virtualpet-dot-sprites.25843/
- The Sprite Resource — virtual pet reference (color): https://www.example.com/lcd_handhelds/examplever20th/

### reference sheet grid (if slicing it directly)

Page background white; each sprite sits in a black LCD cell. The "virtual pet
Originals" block (our 14 species) starts at y≈44, one species per ~20px row:
Dotkin 44, Hopkin 64, Emberkin 83, Marshkin 103, Rexkin 123, … Color frames
come first in each row, monochrome frames after. The "Attacks" block near the
bottom holds projectile sprites.
