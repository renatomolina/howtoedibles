// Derives the 5 provisional quads in OKLCH from one rule fitted to the 3 approved ones; writes palette.json.
// Run: node _prototype-colours/gen.mjs
import { writeFileSync } from "node:fs";

function toHex(L, C, H) {
  // shrink chroma until in sRGB gamut
  for (let c = C; c >= 0; c -= 0.002) {
    const a = c * Math.cos((H * Math.PI) / 180), b = c * Math.sin((H * Math.PI) / 180);
    const l = (L + 0.3963377774 * a + 0.2158037573 * b) ** 3;
    const m = (L - 0.1055613458 * a - 0.0638541728 * b) ** 3;
    const s = (L - 0.0894841775 * a - 1.291485548 * b) ** 3;
    const rgb = [4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s, -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s, -0.0041960863 * l - 0.7034186147 * m + 1.707614701 * s];
    if (rgb.every((v) => v >= -1e-4 && v <= 1 + 1e-4))
      return "#" + rgb.map((v) => { v = Math.min(1, Math.max(0, v)); v = v <= 0.0031308 ? 12.92 * v : 1.055 * v ** (1 / 2.4) - 0.055; return Math.round(v * 255).toString(16).padStart(2, "0"); }).join("");
  }
}

// Rule (fitted to Drinks, the approved cool anchor): dark cover −0.065 L; glyph −0.145 L / +0.015 C; dark glyph −0.175 L from the dark cover.
export const quad = ([L, C, H]) => [toHex(L, C, H), toHex(L - 0.145, C + 0.015, H), toHex(L - 0.065, C, H), toHex(L - 0.24, C, H)];

export const APPROVED = {
  Desserts: ["#f27242", "#c9532a", "#e0673b", "#a8431f"],
  Essentials: ["#f4c542", "#d89f12", "#dcb03a", "#ad7f0c"],
  Drinks: ["#62b6e8", "#2f86bd", "#4f9fd0", "#24688f"],
};
// [L, C, H] of the light cover
export const SEEDS = {
  // picked by search.mjs: max closest-pair ΔE (normal 9.9, worst colour-blind sim 3.0) under every hard check
  Snacks: [0.76, 0.115, 358],    // pink, a touch richer
  Lunch: [0.76, 0.085, 68],      // kraft sand: was C .068, the one dull tile
  Keto: [0.70, 0.12, 286],       // violet: deeper than Drinks so they don't merge (deuteranopia)
  Vegan: [0.77, 0.15, 156],      // leaf green, lighter
  International: [0.69, 0.11, 180], // deep teal: separated from Vegan by lightness, not hue
};

const ORDER = ["Desserts", "Drinks", "Snacks", "Essentials", "Lunch", "Keto", "Vegan", "International"];
export const build = (seeds) => { const out = { ...APPROVED }; for (const [k, s] of Object.entries(seeds)) out[k] = quad(s); return Object.fromEntries(ORDER.map((k) => [k, out[k]])); };

if (typeof process !== "undefined" && import.meta.url === `file://${process.argv[1]}`) {
  const P = build(SEEDS);
  writeFileSync(new URL("./palette.json", import.meta.url), JSON.stringify(P, null, 2) + "\n");
  console.log(P);
}
