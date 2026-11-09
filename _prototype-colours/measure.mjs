// Contrast + family audit for the 8 category colour quads [cover, deep, cover dark, deep dark].
// Run: node _prototype-colours/measure.mjs [palette.json]   (exit 1 on any hard failure)


const hex = (h) => [1, 3, 5].map((i) => parseInt(h.slice(i, i + 2), 16) / 255);
const lin = (c) => (c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4);
const Yl = ([r, g, b]) => 0.2126 * r + 0.7152 * g + 0.0722 * b;
export const Y = (h) => Yl(hex(h).map(lin));
export const cr = (a, b) => { const [x, y] = [Y(a), Y(b)].sort((p, q) => q - p); return (x + 0.05) / (y + 0.05); };
function labLin([r, g, b]) {
  const l = Math.cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b);
  const m = Math.cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b);
  const s = Math.cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b);
  return [0.2104542553 * l + 0.793617785 * m - 0.0040720468 * s, 1.9779984951 * l - 2.428592205 * m + 0.4505937099 * s, 0.0259040371 * l + 0.7827717662 * m - 0.808675766 * s];
}
export const oklch = (h) => { const [L, A, B] = labLin(hex(h).map(lin)); return [L, Math.hypot(A, B), ((Math.atan2(B, A) * 180) / Math.PI + 360) % 360]; };
// Machado et al. 2009, severity 1.0 (linear RGB)
const CVD = {
  none: null,
  deutan: [[0.367322, 0.860646, -0.227968], [0.280085, 0.672501, 0.047413], [-0.01182, 0.04294, 0.968881]],
  protan: [[0.152286, 1.052583, -0.204868], [0.114503, 0.786281, 0.099216], [-0.003882, -0.048116, 1.051998]],
  tritan: [[1.255528, -0.076749, -0.178779], [-0.078411, 0.930809, 0.147602], [0.004733, 0.691367, 0.3039]],
};
const sim = (h, k) => { const c = hex(h).map(lin); const M = CVD[k]; return M ? M.map((r) => Math.min(1, Math.max(0, r[0] * c[0] + r[1] * c[1] + r[2] * c[2]))) : c; };
const dE = (a, b, k) => { const p = labLin(sim(a, k)), q = labLin(sim(b, k)); return Math.hypot(p[0] - q[0], p[1] - q[1], p[2] - q[2]) * 100; };

export const T = { ink: "#1f1410", paper: "#ffffff", inkDk: "#f7ede6", paperDk: "#191210" };
export const MIN = { text: 4.5, edge: 3, glyph: 1.45, dE: 7 }; // glyph floor = the lowest approved (Essentials light)

// [label, value, floor or null (= info only)]
export function checks([c, d, cd, dd]) {
  return [
    ["light · ink text on cover (crumb, tile, band H1, lead card)", cr(T.ink, c), MIN.text],
    ["dark  · ink text on cover", cr(T.ink, cd), MIN.text],
    ["light · glyph / band mark (deep on cover)", cr(d, c), MIN.glyph],
    ["dark  · glyph / band mark", cr(dd, cd), MIN.glyph],
    ["dark  · cover edge vs page", cr(cd, T.paperDk), MIN.edge],
    ["info  · light deep icon on paper (decorative)", cr(d, T.paper), null],
    ["info  · dark deep icon on paper (decorative)", cr(dd, T.paperDk), null],
    ["info  · dark cream sticker straight on cover (ring = --cat)", cr(T.inkDk, cd), null],
  ];
}
export function family(P) {
  const names = Object.keys(P), out = {};
  for (const [idx, theme] of [[0, "light"], [2, "dark"]]) for (const k of Object.keys(CVD)) {
    let best = [Infinity];
    for (let i = 0; i < names.length; i++) for (let j = i + 1; j < names.length; j++) {
      const v = dE(P[names[i]][idx], P[names[j]][idx], k); if (v < best[0]) best = [v, names[i], names[j]];
    }
    out[`${theme} ${k}`] = best;
  }
  return out;
}

if (typeof process !== "undefined" && import.meta.url === `file://${process.argv[1]}`) {
  const { readFileSync } = await import("node:fs");
  const P = JSON.parse(readFileSync(process.argv[2] || new URL("./palette.json", import.meta.url), "utf8"));
  let fails = 0;
  for (const [name, q] of Object.entries(P)) {
    const ok = q.map(oklch).map(([L, C, H]) => `L${L.toFixed(3)} C${C.toFixed(3)} H${H.toFixed(0)}`);
    console.log(`\n${name}  ${q.join(" ")}\n  ${ok.join(" | ")}`);
    for (const [label, v, min] of checks(q)) {
      const tag = min == null ? "    " : v >= min ? "ok  " : (fails++, "FAIL");
      console.log(`  ${tag} ${v.toFixed(2).padStart(5)}${min == null ? "     " : ` ≥ ${min}`}  ${label}`);
    }
  }
  console.log("\nClosest pair of covers (OKLab ΔE×100; colour-vision simulations are severity 1.0):");
  for (const [k, [v, a, b]] of Object.entries(family(P))) {
    const hard = k.endsWith("none"), bad = hard && v < MIN.dE; if (bad) fails++;
    console.log(`  ${hard ? (bad ? "FAIL" : "ok  ") : "    "} ${v.toFixed(1).padStart(5)}  ${k.padEnd(13)} ${a} ↔ ${b}`);
  }
  console.log(`\n${fails} hard failures`);
  process.exitCode = fails ? 1 : 0;
}
