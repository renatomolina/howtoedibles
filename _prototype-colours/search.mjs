// Brute-force the provisional seeds: maximise the closest-pair ΔE (normal vision first, then the worst colour-vision sim),
// subject to every hard check in measure.mjs. Run: node _prototype-colours/search.mjs
import { build } from "./gen.mjs";
import { checks, family } from "./measure.mjs";

const R = (a, b, s) => { const o = []; for (let v = a; v <= b + 1e-9; v += s) o.push(+v.toFixed(3)); return o; };
let best = null;
for (const vH of R(136, 156, 4)) for (const iH of R(180, 200, 4)) for (const kL of [0.7, 0.72, 0.74, 0.77, 0.8]) for (const kH of [286, 294, 302])
  for (const sL of [0.76, 0.78, 0.8]) for (const lL of [0.76, 0.79]) for (const iL of [0.69, 0.715, 0.74]) for (const vL of [0.74, 0.77]) {
    const seeds = { Snacks: [sL, 0.115, 358], Lunch: [lL, 0.085, 68], Keto: [kL, 0.12, kH], Vegan: [vL, 0.15, vH], International: [iL, 0.11, iH] };
    const P = build(seeds);
    if (Object.values(P).some((q) => checks(q).some(([, v, min]) => min != null && v < min))) continue;
    const f = family(P), normal = Math.min(f["light none"][0], f["dark none"][0]);
    const cvd = Math.min(...Object.entries(f).filter(([k]) => !k.endsWith("none")).map(([, [v]]) => v));
    const score = Math.min(normal, 9) * 10 + cvd; // normal vision up to a comfortable 9, then colour-blind separation
    if (!best || score > best.score) best = { score, normal, cvd, seeds, f };
  }
console.log(JSON.stringify(best.seeds), "\nnormal", best.normal.toFixed(1), "cvd", best.cvd.toFixed(1));
for (const [k, [v, a, b]] of Object.entries(best.f)) console.log(" ", k.padEnd(13), v.toFixed(1), a, "↔", b);
