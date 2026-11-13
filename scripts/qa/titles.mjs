// Gate: every recipe H1 (237 × 5 languages) at the narrowest phone, a common phone and the desktop edge.
// Fails when a word sticks out of the title box (titles never break words; only 13+ letter words may hyphenate)
// or the hero buttons leave a 390×664 first screen. One tab per viewport × language, all at once.
// Usage: python3 -I scripts/qa/serve.py 8781 (repo root) & node scripts/qa/titles.mjs
import { readFileSync } from "node:fs";
import { chrome, sleep } from "./chrome.mjs";
const BASE = process.env.BASE || "http://127.0.0.1:8781";
const slugs = JSON.parse(readFileSync(new URL("../../data/recipes.json", import.meta.url))).recipes.map((r) => r.slug);
const LANGS = ["en", "pt", "es", "de", "zh"], VP = [[344, 780], [390, 664], [1000, 700]];
const browser = await chrome("titles");
// Every character of the H1 is measured against the title box.
const PROBE = `(async () => { await document.fonts.ready;
  const h = document.querySelector(".hero h1"), b = h.getBoundingClientRect(), r = document.createRange(), out = [];
  const w = document.createTreeWalker(h, NodeFilter.SHOW_TEXT);
  for (let n; (n = w.nextNode()); ) for (let i = 0; i < n.length; i++) { r.setStart(n, i); r.setEnd(n, i + 1); const c = r.getClientRects()[0]; if (!c) continue;
    if (c.right > b.right + 1) out.push("overflow «" + n.textContent.trim().slice(0, 30) + "» +" + Math.round(c.right - b.right) + "px"); }
  const cta = Math.round(document.querySelector(".cta").getBoundingClientRect().bottom + scrollY);
  return JSON.stringify({ bad: [...new Set(out)], cta, wide: document.documentElement.scrollWidth > innerWidth });
})()`;
async function run([w, hgt], lang) {
  const { send, evs, close } = await browser.tab(), fails = [];
  await send("Emulation.setDeviceMetricsOverride", { width: w, height: hgt, deviceScaleFactor: 1, mobile: w < 1000 });
  for (const s of slugs) {
    const l = new Promise((r) => { const f = (m) => m.method === "Page.loadEventFired" && (evs.splice(evs.indexOf(f), 1), r()); evs.push(f); });
    await send("Page.navigate", { url: `${BASE}${lang === "en" ? "" : "/" + lang}/recipes/${s}/` });
    await Promise.race([l, sleep(8000)]);
    const v = JSON.parse((await send("Runtime.evaluate", { expression: PROBE, awaitPromise: true, returnByValue: true })).result.value);
    const over = w === 390 && v.cta > hgt;
    if (v.bad.length || v.wide || over) fails.push(`✗ ${w} ${lang} ${s}: ${[...v.bad, v.wide ? "page wider than screen" : "", over ? `buttons at ${v.cta}/${hgt}` : ""].filter(Boolean).join(" | ")}`);
  }
  await close();
  return fails;
}
const fails = (await Promise.all(VP.flatMap((vp) => LANGS.map((lang) => run(vp, lang))))).flat();
fails.forEach((f) => console.log(f));
console.log(`${VP.length * LANGS.length * slugs.length} titles checked · ${fails.length} problems`);
browser.kill();
process.exit(fails.length ? 1 : 0);
