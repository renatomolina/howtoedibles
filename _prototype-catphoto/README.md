# Protótipo: fotos nas categorias (descartável)

The real built pages, with the category band and the menu/homepage tiles swapped for each variant. Each variant uses only existing photos: the band shows the recipe with the most impressions in its category, the same one as the og:image in #123. C's trio is the top 3.

- **0 Hoje**: today's page.
- **A Janela**: one round photo cut into the colour, like a window. The colour stays the tile.
- **B Esmaecida**: the photo dissolves into the category colour. The photos were shot on that colour, so it blends with the band.
- **C Trio**: three small round photos stacked. It reads as "a group of recipes".

What sets them apart from a recipe card: the recipe card is a square full photo with the name *below* it and the mg sticker. All three variants keep the colour block with the name *inside* it, and the photo is a detail.

Open (serve the repo root): `/_prototype-catphoto/a/en-desserts.html`. The bottom toolbar switches variant, page (Sobremesas, Internacional, Home, Menu), language and theme. Add `?shot` to hide the toolbar.

- `ruby _prototype-catphoto/gen.rb` regenerates the 48 pages from the current build.
- `node _prototype-catphoto/shoot.mjs` takes the shots at 2x (phone 390×664, tablet 820×1180, desktop 1280×900) and runs `shots/matrix.txt`. The matrix is 36 viewports × en/pt/de/zh × category/home/menu. It checks horizontal overflow and text sitting on a photo (circle geometry; B uses the mask's opacity).
- `sh _prototype-catphoto/sheets.sh` builds `shots/sheets/`, side by side: Hoje | A | B | C.
- `sh _prototype-catphoto/lh.sh` runs Lighthouse. Serve it with gzip (`tmp/wayfinder/gzserve.py`), as Pages does.
