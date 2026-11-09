#!/usr/bin/env python3
"""PROTOTYPE: generate the 6 art-direction sample photos with Gemini.
Usage: python3 gen_photos.py <path-to-key-file> [--model=NAME] [--only=slug,slug] [--list-models]
Masters go to photos/<slug>.jpg; each is checked against the gate (>=1600 wide, ratio 1.25-1.40)."""
import base64, json, os, subprocess, sys, urllib.request, urllib.error

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "photos")
API = "https://generativelanguage.googleapis.com/v1beta"

# Category surface colours = the cover colours, so photo and cover sit in one system.
SURFACE = {
    "Desserts": ("warm tangerine orange", "#F27242"),
    "Essentials": ("sunflower yellow", "#F4C542"),
    "Drinks": ("clear sky blue", "#62B6E8"),
}
SAMPLES = [  # slug, category, dish, angle, props
    ("pot-brownies", "Desserts", "a stack of three fudgy chocolate brownies with crackly shiny tops, one cut edge showing the dense moist crumb", "45-degree angle", "a small folded linen napkin"),
    ("pot-cookies", "Desserts", "five golden chocolate chip cookies with melted chocolate pools, one broken in half", "straight overhead flat lay", "a small ceramic bowl of chocolate chips"),
    ("cannabutter", "Essentials", "a block of pale golden-green homemade butter on a small white ceramic butter dish, a butter knife resting with a smooth curl of butter on it", "45-degree angle", "the butter knife"),
    ("infused-coconut-oil", "Essentials", "a clear glass jar of solid creamy white coconut oil with a wooden spoon scooping some out", "45-degree angle", "half a fresh coconut"),
    ("infused-lemonade", "Drinks", "a tall glass of cloudy lemonade with ice cubes, a lemon wheel on the rim and condensation drops on the glass", "45-degree angle", "half a lemon"),
    ("cannabis-hot-chocolate", "Drinks", "a white ceramic mug of thick hot chocolate topped with toasted marshmallows and a dusting of cocoa", "45-degree angle", "a few loose marshmallows"),
]


def prompt(dish, cat, angle, props):
    name, hexv = SURFACE[cat]
    return (
        f"Editorial food photograph of {dish}. "
        f"The dish sits on a plain, seamless, matte surface that curves up into the backdrop, all one flat {name} colour (exactly {hexv}), filling the whole frame edge to edge. "
        f"Shot at a {angle}. Soft natural daylight from the upper left with a gentle soft shadow falling to the lower right, like a consistent studio still-life series. "
        f"The food is centred with generous empty colour around it, so a square centre crop still shows the whole dish. "
        f"At most one or two simple props: {props}. "
        f"Photorealistic, appetising, sharp focus on the food, natural colours. "
        f"No text, no labels, no logos, no hands, no people, no cannabis leaves or plant material. Landscape 4:3."
    )


def call(key, path, payload=None):
    req = urllib.request.Request(f"{API}/{path}", data=json.dumps(payload).encode() if payload else None,
                                 headers={"Content-Type": "application/json", "x-goog-api-key": key})
    with urllib.request.urlopen(req, timeout=180) as r:
        return json.loads(r.read())


def size(path):
    out = subprocess.run(["sips", "-g", "pixelWidth", "-g", "pixelHeight", path], capture_output=True, text=True).stdout
    vals = [int(l.split()[-1]) for l in out.splitlines() if "pixel" in l]
    return vals[0], vals[1]


def main():
    key = open(sys.argv[1]).read().strip()
    opts = dict(a[2:].split("=", 1) if "=" in a else (a[2:], "1") for a in sys.argv[2:] if a.startswith("--"))
    if "list-models" in opts:
        for m in call(key, "models?pageSize=200")["models"]:
            if "image" in m["name"]:
                print(m["name"], m.get("supportedGenerationMethods"))
        return
    model = opts.get("model", "gemini-3-pro-image-preview")
    only = set(opts["only"].split(",")) if "only" in opts else None
    os.makedirs(OUT, exist_ok=True)
    for slug, cat, dish, angle, props in SAMPLES:
        if only and slug not in only:
            continue
        p = prompt(dish, cat, angle, props)
        payload = {"contents": [{"parts": [{"text": p}]}],
                   "generationConfig": {"responseModalities": ["IMAGE"], "imageConfig": {"aspectRatio": "4:3", "imageSize": "2K"}}}
        print(f"{slug} ({model})...", end=" ", flush=True)
        try:
            data = call(key, f"models/{model}:generateContent", payload)
        except urllib.error.HTTPError as e:
            print("ERROR", e.code, e.read().decode()[:300]); continue
        parts = [pt for c in data.get("candidates", []) for pt in c.get("content", {}).get("parts", []) if "inlineData" in pt]
        if not parts:
            print("no image:", json.dumps(data)[:300]); continue
        raw = os.path.join(OUT, f"{slug}.raw")
        open(raw, "wb").write(base64.b64decode(parts[0]["inlineData"]["data"]))
        dst = os.path.join(OUT, f"{slug}.jpg")
        subprocess.run(["sips", "-s", "format", "jpeg", "-s", "formatOptions", "90", raw, "--out", dst], capture_output=True)
        os.unlink(raw)
        w, h = size(dst)
        ok = w >= 1600 and 1.25 <= w / h <= 1.40
        print(f"{w}x{h} gate={'PASS' if ok else 'FAIL'}")
        open(os.path.join(OUT, f"{slug}.prompt.txt"), "w").write(f"model: {model}\n\n{p}\n")


if __name__ == "__main__":
    main()
