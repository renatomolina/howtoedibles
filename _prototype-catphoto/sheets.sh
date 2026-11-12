#!/bin/sh
# Throwaway: side-by-side sheets (Hoje | A | B | C) from shots/. Usage: sh _prototype-catphoto/sheets.sh
D=$(dirname "$0")/shots
mkdir -p "$D/sheets"
for k in phone_cat-desserts phone_cat-de-international phone_cat-zh-international phone_home-tiles phone_menu-pt phone_cat-desserts-dark; do
  magick montage "$D/0_$k.jpg" "$D/a_$k.jpg" "$D/b_$k.jpg" "$D/c_$k.jpg" -tile 4x1 -geometry 390x+8+0 -background "#888" "$D/sheets/$k.jpg"
done
for k in tablet_cat-desserts tablet_cat-de-international tablet_home-tiles desktop_cat-desserts desktop_cat-de-international desktop_home-tiles; do
  magick montage "$D/0_$k.jpg" "$D/a_$k.jpg" "$D/b_$k.jpg" "$D/c_$k.jpg" -tile 2x2 -geometry 820x+8+8 -background "#888" "$D/sheets/$k.jpg"
done
