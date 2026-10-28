#!/usr/bin/env python3
"""Measure every exported PNG and check the artwork is not clipped.

The exports cannot be inspected by eye, so this is how the geometry is verified rather than
trusted. For each file it finds the bounding box of everything that differs from the background and
reports the margin on each edge. A margin of zero means something is touching the edge, which means
the artwork overflows the canvas or the background colour is wrong.

Two additional checks matter for this brand specifically:

  * a mark rendered on an ink ground must NOT be the ink variant, or it disappears. Low ink coverage
    on a dark background is the symptom, which is exactly how that defect was caught in the parent
    kit.
  * a lockup whose wordmark failed to load the webfont renders in a fallback face, which changes its
    width. The right hand margin is the tell.

  python3 brand/tools/verify-pngs.py
"""

import os
import sys

try:
    from PIL import Image
except ImportError:
    print("  Pillow is not installed. Run: python3 -m pip install --user pillow")
    sys.exit(1)

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PNG_DIR = os.path.join(ROOT, "png")

# A file whose ink covers less than this fraction of the canvas is probably blank. More than the
# upper bound is probably a solid block, which means the render failed while still writing a file.
MIN_COVERAGE = 0.004
MAX_COVERAGE = 0.85

# Small marks are drawn to fill their frame at these sizes, so a zero margin is correct there.
ZERO_MARGIN_OK = {"mark-16.png", "mark-32.png", "mark-48.png"}

# Exports that must show a healthy amount of ink. A mono mark drawn in ink on an ink background
# would render almost nothing, which is the defect this catches.
MIN_INK_ON_DARK = {"lockup-horizontal-mono-light-1600.png": 0.03}

results = []
problems = []

for name in sorted(os.listdir(PNG_DIR)):
    if not name.endswith(".png"):
        continue

    path = os.path.join(PNG_DIR, name)
    image = Image.open(path).convert("RGBA")
    width, height = image.size

    if width < 8 or height < 8:
        problems.append(f"{name}: suspicious size {width}x{height}")
        continue

    pixels = image.load()

    # The background is whatever the corners are, so a transparent export is handled the same way as
    # a light one, without assuming a colour.
    corners = [pixels[0, 0], pixels[width - 1, 0], pixels[0, height - 1], pixels[width - 1, height - 1]]

    def is_background(pixel):
        for corner in corners:
            if abs(pixel[0] - corner[0]) <= 8 and abs(pixel[1] - corner[1]) <= 8 and abs(pixel[2] - corner[2]) <= 8:
                return True
        return False

    min_x, min_y, max_x, max_y = width, height, -1, -1
    ink = 0
    for y in range(height):
        for x in range(width):
            if not is_background(pixels[x, y]):
                ink += 1
                if x < min_x:
                    min_x = x
                if y < min_y:
                    min_y = y
                if x > max_x:
                    max_x = x
                if y > max_y:
                    max_y = y

    if max_x < 0:
        problems.append(f"{name}: no ink at all, the export is blank")
        continue

    coverage = ink / float(width * height)
    margin_left, margin_right = min_x, width - 1 - max_x
    margin_top, margin_bottom = min_y, height - 1 - max_y

    results.append(
        {
            "name": name,
            "size": f"{width}x{height}",
            "coverage": coverage,
            "margins": (margin_left, margin_top, margin_right, margin_bottom),
        }
    )

    if name not in ZERO_MARGIN_OK and min(margin_left, margin_top, margin_right, margin_bottom) < 1:
        problems.append(f"{name}: content reaches the edge, so it is clipped")

    if coverage < MIN_COVERAGE:
        problems.append(f"{name}: only {coverage:.2%} ink, the symbol probably did not render")

    if coverage > MAX_COVERAGE:
        problems.append(f"{name}: {coverage:.2%} ink, which looks like a solid block")

    floor = MIN_INK_ON_DARK.get(name)
    if floor is not None and coverage < floor:
        problems.append(
            f"{name}: only {coverage:.2%} ink. The wrong variant was used on this background, "
            f"so the artwork is invisible."
        )

print("\n  file                                   size          ink     margins l/t/r/b")
for row in results:
    left, top, right, bottom = row["margins"]
    print(
        f"  {row['name']:<38} {row['size']:<13} {row['coverage']:>6.1%}   {left}/{top}/{right}/{bottom}"
    )

print("")
if problems:
    print("  PROBLEMS")
    for problem in problems:
        print(f"    {problem}")
    print("")
    sys.exit(1)

print(f"  {len(results)} files measured, no clipping and nothing blank\n")
