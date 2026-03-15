#!/usr/bin/env python3
"""Generate placeholder images for recipes that don't have real photos."""

import json
import os
import subprocess
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IMAGES_DIR = os.path.join(ROOT, "images", "recipes")

# Category styles: (main_color, bg_gradient_top, bg_gradient_bottom, circle_color, icon_svg)
CATEGORY_STYLES = {
    "Desserts": {
        "color": "#E8725A",
        "bg_top": "#f5d5cd",
        "bg_bottom": "#fdf0ec",
        "circle": "#f5d5cd",
        "icon": """<g transform="translate(370,145) scale(0.9)">
            <rect x="15" y="40" width="90" height="50" rx="6" fill="{color}"/>
            <path d="M20,40 Q60,0 100,40" fill="{color}" opacity="0.7"/>
            <rect x="25" y="30" width="8" height="18" rx="4" fill="{color}"/>
            <rect x="55" y="25" width="8" height="22" rx="4" fill="{color}"/>
            <rect x="85" y="30" width="8" height="18" rx="4" fill="{color}"/>
            <path d="M15,55 Q60,68 105,55" fill="none" stroke="{bg_top}" stroke-width="3"/>
        </g>"""
    },
    "Snacks": {
        "color": "#E8A735",
        "bg_top": "#f5e6c0",
        "bg_bottom": "#fdf6e8",
        "circle": "#f5e6c0",
        "icon": """<g transform="translate(370,150) scale(0.85)">
            <circle cx="55" cy="45" r="45" fill="{color}"/>
            <path d="M75,15 Q100,5 90,35" fill="{bg_bottom}"/>
            <circle cx="35" cy="35" r="7" fill="{bg_bottom}"/>
            <circle cx="55" cy="55" r="7" fill="{bg_bottom}"/>
            <circle cx="70" cy="40" r="6" fill="{bg_bottom}"/>
        </g>"""
    },
    "Drinks": {
        "color": "#4285F4",
        "bg_top": "#c8dbf5",
        "bg_bottom": "#e8f0fc",
        "circle": "#d6e4f7",
        "icon": """<g transform="translate(372,148) scale(0.85)">
            <rect x="15" y="25" width="70" height="55" rx="8" fill="{color}"/>
            <path d="M85,40 Q105,40 100,60 Q95,75 85,70" fill="{color}"/>
            <ellipse cx="50" cy="25" rx="35" ry="5" fill="{color}"/>
            <path d="M30,8 Q35,0 40,10" fill="none" stroke="{color}" stroke-width="5" stroke-linecap="round"/>
            <path d="M50,5 Q55,-3 60,7" fill="none" stroke="{color}" stroke-width="5" stroke-linecap="round"/>
        </g>"""
    },
    "Lunch": {
        "color": "#6C6CE0",
        "bg_top": "#d4d4f5",
        "bg_bottom": "#ececfa",
        "circle": "#dcdcf5",
        "icon": """<g transform="translate(370,145) scale(0.85)">
            <path d="M30,10 L30,80" stroke="{color}" stroke-width="8" stroke-linecap="round"/>
            <path d="M15,10 L15,35 Q15,50 30,50" stroke="{color}" stroke-width="8" fill="none" stroke-linecap="round"/>
            <path d="M45,10 L45,35 Q45,50 30,50" stroke="{color}" stroke-width="8" fill="none" stroke-linecap="round"/>
            <path d="M75,10 Q95,10 95,35 L95,40 Q95,50 85,50 L80,50 L80,80" stroke="{color}" stroke-width="8" fill="{color}" stroke-linecap="round"/>
        </g>"""
    },
    "International": {
        "color": "#3BBFA0",
        "bg_top": "#c0e8de",
        "bg_bottom": "#e5f5f0",
        "circle": "#d0ede5",
        "icon": """<g transform="translate(370,148) scale(0.85)">
            <circle cx="50" cy="45" r="40" fill="none" stroke="{color}" stroke-width="6"/>
            <ellipse cx="50" cy="45" rx="20" ry="40" fill="none" stroke="{color}" stroke-width="4"/>
            <line x1="10" y1="30" x2="90" y2="30" stroke="{color}" stroke-width="4"/>
            <line x1="10" y1="60" x2="90" y2="60" stroke="{color}" stroke-width="4"/>
            <line x1="50" y1="5" x2="50" y2="85" stroke="{color}" stroke-width="4"/>
        </g>"""
    },
    "Keto": {
        "color": "#7C4DFF",
        "bg_top": "#d8c8f5",
        "bg_bottom": "#efe8fc",
        "circle": "#e0d4f7",
        "icon": """<g transform="translate(375,145) scale(0.85)">
            <path d="M45,85 L45,45 Q20,30 35,10 Q45,0 55,15" fill="{color}" stroke="{color}" stroke-width="3"/>
            <path d="M45,45 Q70,30 60,10 Q55,0 45,10" fill="{color}" stroke="{color}" stroke-width="3"/>
        </g>"""
    },
    "Vegan": {
        "color": "#4CAF50",
        "bg_top": "#c8e6c9",
        "bg_bottom": "#e8f5e9",
        "circle": "#d5edd6",
        "icon": """<g transform="translate(372,145) scale(0.85)">
            <path d="M50,85 L50,45" stroke="{color}" stroke-width="8" stroke-linecap="round"/>
            <path d="M50,45 Q30,20 40,5 Q50,-5 55,15 Q60,35 50,45" fill="{color}"/>
            <path d="M50,50 Q70,25 75,10 Q80,-5 65,15 Q55,30 50,50" fill="{color}"/>
        </g>"""
    },
    "Essentials": {
        "color": "#43A047",
        "bg_top": "#c8e6c9",
        "bg_bottom": "#e8f5e9",
        "circle": "#d0e8d1",
        "icon": """<g transform="translate(368,148) scale(0.85)">
            <path d="M20,75 Q20,50 50,50 Q80,50 80,75 Q80,85 50,85 Q20,85 20,75Z" fill="{color}"/>
            <path d="M15,68 Q15,40 50,40 Q85,40 85,68" fill="none" stroke="{color}" stroke-width="5"/>
            <path d="M60,40 L85,15" stroke="{color}" stroke-width="8" stroke-linecap="round"/>
        </g>"""
    }
}

SVG_TEMPLATE = """<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="800" height="500" viewBox="0 0 800 500">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="{bg_top}"/>
      <stop offset="100%" stop-color="{bg_bottom}"/>
    </linearGradient>
  </defs>

  <!-- Background -->
  <rect width="800" height="500" fill="url(#bg)"/>

  <!-- Circle behind icon -->
  <circle cx="400" cy="195" r="55" fill="{circle}" opacity="0.6"/>

  <!-- Category icon -->
  {icon}

  <!-- Category badge -->
  <g transform="translate(28, 22)">
    <rect width="{badge_width}" height="28" rx="14" fill="{color}" opacity="0.9"/>
    <text x="{badge_text_x}" y="19" font-family="Arial, Helvetica, sans-serif" font-size="12" font-weight="bold" fill="white" text-anchor="middle">{category}</text>
  </g>

  <!-- Recipe name -->
  <text x="400" y="300" font-family="Arial, Helvetica, sans-serif" font-size="26" font-weight="bold" fill="#3d3d3d" text-anchor="middle">{name}</text>

  <!-- Watermark -->
  <text x="775" y="485" font-family="Arial, Helvetica, sans-serif" font-size="11" fill="#999" text-anchor="end" opacity="0.6">howtoedibles.com</text>
</svg>"""


def generate_placeholder(name, category, output_path):
    style = CATEGORY_STYLES.get(category, CATEGORY_STYLES["Lunch"])

    badge_width = max(len(category) * 9 + 24, 70)
    badge_text_x = badge_width / 2

    icon_svg = style["icon"].format(
        color=style["color"],
        bg_top=style["bg_top"],
        bg_bottom=style["bg_bottom"]
    )

    svg = SVG_TEMPLATE.format(
        bg_top=style["bg_top"],
        bg_bottom=style["bg_bottom"],
        circle=style["circle"],
        color=style["color"],
        icon=icon_svg,
        badge_width=badge_width,
        badge_text_x=badge_text_x,
        category=category.upper(),
        name=name
    )

    with tempfile.NamedTemporaryFile(suffix=".svg", mode="w", delete=False) as f:
        f.write(svg)
        svg_path = f.name

    try:
        subprocess.run(
            ["rsvg-convert", "-w", "800", "-h", "500", "-f", "png", "-o", output_path.replace(".jpg", ".png"), svg_path],
            check=True, capture_output=True
        )
        subprocess.run(
            ["convert", output_path.replace(".jpg", ".png"), "-quality", "90", output_path],
            check=True, capture_output=True
        )
        os.unlink(output_path.replace(".jpg", ".png"))
    finally:
        os.unlink(svg_path)


def main():
    with open(os.path.join(ROOT, "data", "recipes.json")) as f:
        data = json.load(f)

    new_recipes = [r for r in data["recipes"] if r["id"] >= 141]
    print(f"Generating {len(new_recipes)} placeholder images...")

    for i, recipe in enumerate(new_recipes):
        photo = recipe.get("photo_file_name", f"{recipe['slug']}.jpg")
        output_path = os.path.join(IMAGES_DIR, photo)
        generate_placeholder(recipe["name"], recipe["category_name"], output_path)
        if (i + 1) % 10 == 0:
            print(f"  {i + 1}/{len(new_recipes)} done")

    print(f"Done! Generated {len(new_recipes)} images.")


if __name__ == "__main__":
    main()
