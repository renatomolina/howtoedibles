#!/usr/bin/env python3
"""Generate recipe images using Gemini's image generation API."""

import json
import os
import sys
import time
import base64
import urllib.request
import urllib.error

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IMAGES_DIR = os.path.join(ROOT, "images", "recipes")
API_KEY = os.environ.get("GEMINI_API_KEY")
MODEL = "gemini-2.5-flash-image"
API_URL = f"https://generativelanguage.googleapis.com/v1beta/models/{MODEL}:generateContent?key={API_KEY}"


def generate_image(recipe_name, category):
    """Generate a food photo for a recipe using Gemini."""
    prompt = (
        f"Close-up food photography of {recipe_name}, filling most of the frame. "
        f"Shot from a 45-degree angle, tight crop focusing on the dish. "
        f"Soft natural window light from the left, shallow depth of field with creamy bokeh background. "
        f"The food looks fresh, vibrant, and appetizing with visible texture and detail. "
        f"Clean white plate or simple surface, minimal props. "
        f"Professional DSLR photo, 85mm lens, warm color tones. "
        f"No text, no words, no watermarks, no logos, no human hands, no cannabis leaves visible."
    )

    payload = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {
            "responseModalities": ["IMAGE", "TEXT"],
            "responseMimeType": "text/plain"
        }
    }

    data_bytes = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        API_URL,
        data=data_bytes,
        headers={"Content-Type": "application/json"},
        method="POST"
    )

    with urllib.request.urlopen(req, timeout=60) as resp:
        data = json.loads(resp.read().decode("utf-8"))

    # Extract image from response
    for candidate in data.get("candidates", []):
        for part in candidate.get("content", {}).get("parts", []):
            if "inlineData" in part:
                img_data = base64.b64decode(part["inlineData"]["data"])
                return img_data

    return None


def main():
    if not API_KEY:
        print("Error: Set GEMINI_API_KEY environment variable")
        print("  export GEMINI_API_KEY=your_key_here")
        sys.exit(1)

    with open(os.path.join(ROOT, "data", "recipes.json")) as f:
        data = json.load(f)

    # Only generate for new recipes (id >= 141) by default
    # Pass --all to regenerate everything
    min_id = 1 if "--all" in sys.argv else 141
    recipes = [r for r in data["recipes"] if r["id"] >= min_id]

    # Limit number of recipes with --limit=N
    limit = None
    for arg in sys.argv:
        if arg.startswith("--limit="):
            limit = int(arg.split("=", 1)[1])

    # Allow resuming from a specific recipe with --from=slug
    start_slug = None
    for arg in sys.argv:
        if arg.startswith("--from="):
            start_slug = arg.split("=", 1)[1]

    if start_slug:
        slugs = [r["slug"] for r in recipes]
        if start_slug in slugs:
            idx = slugs.index(start_slug)
            recipes = recipes[idx:]
            print(f"Resuming from {start_slug} ({len(recipes)} remaining)")

    if limit:
        recipes = recipes[:limit]

    print(f"Generating images for {len(recipes)} recipes...")
    print(f"Using model: {MODEL}\n")

    success = 0
    errors = 0

    for i, recipe in enumerate(recipes):
        slug = recipe["slug"]
        name = recipe["name"]
        category = recipe["category_name"]
        output_path = os.path.join(IMAGES_DIR, f"{slug}.jpg")

        print(f"[{i+1}/{len(recipes)}] {name}...", end=" ", flush=True)

        try:
            img_data = generate_image(name, category)
            if img_data:
                # Save as JPEG (Gemini returns PNG, convert if needed)
                if img_data[:3] == b'\x89PN':  # PNG header
                    # Convert PNG to JPEG using ImageMagick
                    tmp_png = output_path.replace(".jpg", "_tmp.png")
                    with open(tmp_png, "wb") as f:
                        f.write(img_data)
                    os.system(f'convert "{tmp_png}" -resize 800x500^ -gravity center -extent 800x500 -quality 85 "{output_path}"')
                    os.unlink(tmp_png)
                else:
                    # Already JPEG or other format
                    with open(output_path, "wb") as f:
                        f.write(img_data)
                    # Resize to standard dimensions
                    os.system(f'convert "{output_path}" -resize 800x500^ -gravity center -extent 800x500 -quality 85 "{output_path}"')

                print("OK")
                success += 1
            else:
                print("SKIP (no image in response)")
                errors += 1
        except urllib.error.HTTPError as e:
            body = e.read().decode("utf-8", errors="replace")[:200]
            print(f"ERROR: {e.code} {body}")
            errors += 1
            if e.code == 429:
                print("  Rate limited, waiting 30s...")
                time.sleep(30)
        except Exception as e:
            print(f"ERROR: {e}")
            errors += 1

        # Delay to stay within free tier rate limits (10 req/min)
        time.sleep(8)

    print(f"\nDone! {success} generated, {errors} errors.")


if __name__ == "__main__":
    main()
