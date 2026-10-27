import sys
from PIL import Image
out, items = sys.argv[1], sys.argv[2:]
cell = 160
cols = 8
rows = (len(items) + cols - 1) // cols
sheet = Image.new("RGBA", (cols * cell, rows * cell), (176, 112, 64, 255))
for i, p in enumerate(items):
    im = Image.open(p).convert("RGBA")
    im.thumbnail((128, 128))
    x = (i % cols) * cell + (cell - im.width) // 2
    y = (i // cols) * cell + (cell - im.height) // 2
    sheet.alpha_composite(im, (x, y))
sheet.save(out)
