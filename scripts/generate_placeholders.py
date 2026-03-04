#!/usr/bin/env python3
"""
Regenerate styled placeholder images for recipes,
replacing the circle with a Font Awesome category icon.
Requires: rsvg-convert (brew install librsvg)
"""

import json
import os
import subprocess
import urllib.request
import tempfile

IMAGES_DIR = os.path.join(os.path.dirname(__file__), '..', 'static-site', 'images', 'recipes')
DATA_FILE  = os.path.join(os.path.dirname(__file__), '..', 'static-site', 'data', 'recipes.json')

# Category config: background colors, accent color, icon name
CATEGORY_CONFIG = {
    'desserts':  {'bg': '#FFF5EE', 'accent': '#E8623A', 'icon': 'cake-candles'},
    'drinks':    {'bg': '#EEF5FF', 'accent': '#3A7AE8', 'icon': 'mug-hot'},
    'snacks':    {'bg': '#FFFBEE', 'accent': '#E8A83A', 'icon': 'cookie-bite'},
    'essentials':{'bg': '#F0FFF4', 'accent': '#3AAD6E', 'icon': 'mortar-pestle'},
    'lunch':     {'bg': '#EEF0FF', 'accent': '#5B5EE8', 'icon': 'utensils'},
    'keto':      {'bg': '#F5EEFF', 'accent': '#8B3AE8', 'icon': 'leaf'},
    'vegan':     {'bg': '#EEFFEE', 'accent': '#2EAD2E', 'icon': 'seedling'},
    'mocktails': {'bg': '#FFEEF5', 'accent': '#E83A8B', 'icon': 'martini-glass-citrus'},
}

FA_BASE = 'https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@6.4.0/svgs/solid/{}.svg'

# Cache fetched icon paths
_icon_cache = {}

def fetch_icon_path(icon_name):
    if icon_name in _icon_cache:
        return _icon_cache[icon_name]
    url = FA_BASE.format(icon_name)
    print(f'  Fetching FA icon: {icon_name}...')
    with urllib.request.urlopen(url, timeout=10) as r:
        svg_content = r.read().decode('utf-8')
    # Extract viewBox and path(s)
    import re
    vb = re.search(r'viewBox="([^"]+)"', svg_content)
    viewbox = vb.group(1) if vb else '0 0 512 512'
    paths = re.findall(r'<path[^>]+d="([^"]+)"', svg_content)
    combined_path = ' '.join(paths)
    _icon_cache[icon_name] = (viewbox, combined_path)
    return viewbox, combined_path


def make_svg(recipe_name, category_slug, viewbox, icon_path):
    cfg = CATEGORY_CONFIG.get(category_slug, CATEGORY_CONFIG['desserts'])
    bg      = cfg['bg']
    accent  = cfg['accent']
    cat_label = category_slug.upper()

    # Lighten the top gradient strip
    accent_light = accent + '33'  # 20% alpha hex

    # Icon bounding box: scale the FA viewBox to fit in a ~120x120 circle area
    vb_parts = [float(x) for x in viewbox.split()]
    vb_w = vb_parts[2]
    vb_h = vb_parts[3]

    # Target icon size on canvas (800x500)
    icon_size = 110
    icon_cx = 400  # center x
    icon_cy = 210  # center y

    # Scale so largest dimension = icon_size
    scale = icon_size / max(vb_w, vb_h)
    tx = icon_cx - (vb_w * scale) / 2
    ty = icon_cy - (vb_h * scale) / 2

    # Sanitize recipe name for XML
    safe_name = recipe_name.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')

    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="800" height="500" viewBox="0 0 800 500">
  <defs>
    <linearGradient id="topGrad" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="{accent}" stop-opacity="0.25"/>
      <stop offset="100%" stop-color="{accent}" stop-opacity="0"/>
    </linearGradient>
    <!-- drop shadow filter for icon -->
    <filter id="iconShadow" x="-20%" y="-20%" width="140%" height="140%">
      <feDropShadow dx="0" dy="3" stdDeviation="6" flood-color="{accent}" flood-opacity="0.25"/>
    </filter>
  </defs>

  <!-- Background -->
  <rect width="800" height="500" fill="{bg}"/>

  <!-- Top gradient strip -->
  <rect width="800" height="160" fill="url(#topGrad)"/>

  <!-- Category badge -->
  <rect x="20" y="20" width="{len(cat_label)*9 + 24}" height="28" rx="14" fill="{accent}"/>
  <text x="{20 + len(cat_label)*4.5 + 12}" y="39" text-anchor="middle"
        font-family="Arial, Helvetica, sans-serif" font-size="12" font-weight="700"
        fill="white" letter-spacing="1">{cat_label}</text>

  <!-- FA Icon (circle bg + icon) -->
  <circle cx="{icon_cx}" cy="{icon_cy}" r="70" fill="{accent}" fill-opacity="0.12"/>
  <g transform="translate({tx:.2f},{ty:.2f}) scale({scale:.4f})" fill="{accent}" filter="url(#iconShadow)">
    <path d="{icon_path}"/>
  </g>

  <!-- Recipe name -->
  <text x="400" y="335" text-anchor="middle"
        font-family="Arial, Helvetica, sans-serif" font-size="28" font-weight="600"
        fill="#222222">{safe_name}</text>

  <!-- Watermark -->
  <text x="785" y="490" text-anchor="end"
        font-family="Arial, Helvetica, sans-serif" font-size="11"
        fill="#aaaaaa">howtoedibles.com</text>
</svg>'''
    return svg


def main():
    os.makedirs(IMAGES_DIR, exist_ok=True)

    with open(DATA_FILE) as f:
        data = json.load(f)

    # Build slug → {name, category_slug} map
    recipe_map = {}
    for cat in data['categories']:
        cat_slug = cat['slug']
        for r in cat['recipes']:
            recipe_map[r['slug']] = {
                'name': r['name'],
                'category': cat_slug,
            }

    # Pre-fetch all icons
    print('Fetching Font Awesome icons...')
    icon_data = {}
    for cat_slug, cfg in CATEGORY_CONFIG.items():
        icon_name = cfg['icon']
        try:
            icon_data[cat_slug] = fetch_icon_path(icon_name)
        except Exception as e:
            print(f'  ERROR fetching {icon_name}: {e}')
            icon_data[cat_slug] = ('0 0 512 512', '')

    print(f'\nGenerating placeholder images...')
    count = 0
    for slug, info in recipe_map.items():
        cat_slug = info['category']
        name     = info['name']
        out_path = os.path.join(IMAGES_DIR, f'{slug}.jpg')

        if cat_slug not in icon_data:
            print(f'  SKIP (unknown category): {slug}')
            continue

        viewbox, icon_path = icon_data[cat_slug]
        svg_content = make_svg(name, cat_slug, viewbox, icon_path)

        # Write SVG to temp file, convert to JPEG via rsvg-convert
        with tempfile.NamedTemporaryFile(suffix='.svg', delete=False, mode='w') as tmp:
            tmp.write(svg_content)
            tmp_path = tmp.name

        try:
            result = subprocess.run(
                ['rsvg-convert', '-w', '800', '-h', '500', '-f', 'png', '-o', tmp_path + '.png', tmp_path],
                capture_output=True, text=True
            )
            if result.returncode != 0:
                print(f'  ERROR rsvg-convert {slug}: {result.stderr}')
                continue

            # Convert PNG → JPEG via ImageMagick
            result2 = subprocess.run(
                ['convert', tmp_path + '.png', '-quality', '85', out_path],
                capture_output=True, text=True
            )
            if result2.returncode != 0:
                print(f'  ERROR convert {slug}: {result2.stderr}')
                continue

            count += 1
            print(f'  OK: {slug}.jpg ({cat_slug})')
        finally:
            os.unlink(tmp_path)
            if os.path.exists(tmp_path + '.png'):
                os.unlink(tmp_path + '.png')

    print(f'\nDone! Generated {count} placeholder images.')


if __name__ == '__main__':
    main()
