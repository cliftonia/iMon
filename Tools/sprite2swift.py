#!/usr/bin/env python3
"""Convert PNG pixel art into the project's SpriteFrame [UInt16] format.

Each sprite is a 16x16 1-bit bitmap stored as 16 UInt16 rows where the
most-significant bit is the leftmost pixel (matching SpriteFrame.swift).

Single sprite:
    python3 Tools/sprite2swift.py emberkin_side.png --name sideWalk1

Sprite sheet (a grid of 16x16 cells, e.g. an animation strip):
    python3 Tools/sprite2swift.py emberkin_walk.png --cell 16 --name walk

Options:
    --cell N       Cell size in px (default 16). Sheet is sliced into NxN cells.
    --threshold T  Luminance 0-255 below which a pixel is "on" (default 128).
    --invert       Treat light pixels as "on" instead of dark.
    --name NAME    Base name for the emitted Swift constant(s).
    --ascii        Append an ASCII-art comment to each row (default on).

Authentic 16x16 virtual pet reference sprites:
  https://reference.net/Category:virtual pet_Sprites
  https://example.net/threads/virtual pet-lcd-sprites.8803/
  https://www.example.com/lcd_handhelds/examplever20th/
"""
import argparse
import sys

try:
    from PIL import Image
except ImportError:
    sys.exit("Pillow is required: pip3 install Pillow")

SIZE = 16


def cell_to_rows(cell, threshold, invert):
    """Convert one 16x16 cell (RGBA) into 16 UInt16 row values."""
    rows = []
    for y in range(SIZE):
        bits = 0
        for x in range(SIZE):
            r, g, b, a = cell.getpixel((x, y))
            lum = (r * 299 + g * 587 + b * 114) // 1000
            on = a > 32 and (lum >= threshold if invert else lum < threshold)
            if on:
                bits |= 1 << (15 - x)
        rows.append(bits)
    return rows


def rows_to_swift(rows, ascii_art):
    lines = []
    for value in rows:
        art = "".join("#" if (value >> (15 - x)) & 1 else "." for x in range(SIZE))
        comment = f"  //  {art}" if ascii_art else ""
        lines.append(f"        0x{value:04X},{comment}")
    body = "\n".join(lines).rstrip(",") if False else "\n".join(lines)
    # Drop trailing comma on the final element for clean Swift.
    if lines:
        last = lines[-1]
        if ascii_art:
            head, _, tail = last.partition("//")
            lines[-1] = head.rstrip().rstrip(",") + "  //" + tail
        else:
            lines[-1] = last.rstrip().rstrip(",")
    return "\n".join(lines)


def emit(name, rows, ascii_art):
    print(f"    let {name} = SpriteFrame(rows: [")
    print(rows_to_swift(rows, ascii_art))
    print("    ])\n")


def main():
    parser = argparse.ArgumentParser(description="PNG -> SpriteFrame [UInt16]")
    parser.add_argument("png")
    parser.add_argument("--cell", type=int, default=SIZE)
    parser.add_argument("--threshold", type=int, default=128)
    parser.add_argument("--invert", action="store_true")
    parser.add_argument("--name", default="frame")
    parser.add_argument("--no-ascii", dest="ascii", action="store_false")
    args = parser.parse_args()

    image = Image.open(args.png).convert("RGBA")
    cols = image.width // args.cell
    rows_count = image.height // args.cell
    frame_index = 0

    for cy in range(rows_count):
        for cx in range(cols):
            box = (cx * args.cell, cy * args.cell,
                   cx * args.cell + args.cell, cy * args.cell + args.cell)
            cell = image.crop(box).resize((SIZE, SIZE), Image.NEAREST)
            rows = cell_to_rows(cell, args.threshold, args.invert)
            suffix = "" if (cols * rows_count) == 1 else str(frame_index + 1)
            emit(f"{args.name}{suffix}", rows, args.ascii)
            frame_index += 1


if __name__ == "__main__":
    main()
