"""Bake colours into a finished icon (for images that can't be tinted in Roblox, or need 2 colours).
Usage: py -I colour.py <in.png> <out.png> R,G,B [R,G,B ...]
The white parts are split into separate pieces (biggest first); piece 1 gets the 1st colour, piece 2
the 2nd, and so on (the last colour repeats). The dark-brown outline and the shading stay as they are.
Single colour = the same as setting ImageColor3 in Roblox.
Optional y=<row>: everything from that row down gets the LAST colour (e.g. a mushroom's stem).
"""
import sys
from PIL import Image, ImageChops, ImageDraw

src, dst = sys.argv[1], sys.argv[2]
split_y = None
cols = []
for c in sys.argv[3:]:
    if c.startswith("y="):
        split_y = int(c[2:])
    else:
        cols.append(tuple(int(v) for v in c.split(",")))
im = Image.open(src).convert("RGBA")
w, h = im.size
px = im.load()
mask = Image.new("L", (w, h), 0)
mp = mask.load()
for y in range(h):
    for x in range(w):
        r, g, b, a = px[x, y]
        if a > 100 and r > 150 and g > 150 and b > 150:
            mp[x, y] = 255
# label white pieces by flood fill (piece n painted with value n)
pieces = []
lab = mask.copy()
lp = lab.load()
n = 0
for y in range(h):
    for x in range(w):
        if lp[x, y] == 255:
            n += 1
            ImageDraw.floodfill(lab, (x, y), n)
            pieces.append(n)
sizes = {k: 0 for k in pieces}
for y in range(h):
    for x in range(w):
        v = lp[x, y]
        if v and v < 255:
            sizes[v] += 1
order = sorted([k for k in pieces if sizes[k] > 30], key=lambda k: -sizes[k])
print("pieces:", [sizes[k] for k in order])
colour_of = {k: cols[min(i, len(cols) - 1)] for i, k in enumerate(order)}
tintmap = Image.new("RGB", (w, h), cols[0])
tp = tintmap.load()
# every pixel takes the colour of the nearest labelled piece (simple: label value, else 1st colour)
for y in range(h):
    for x in range(w):
        v = lp[x, y]
        if split_y is not None and y >= split_y:
            tp[x, y] = cols[-1]
        elif v in colour_of:
            tp[x, y] = colour_of[v]
r, g, b, a = im.split()
rgb = ImageChops.multiply(Image.merge("RGB", (r, g, b)), tintmap)
Image.merge("RGBA", (*rgb.split(), a)).save(dst)
