// Gate: every recipe H1 (237 × 5 languages) at the narrowest phone, a common phone and the desktop edge.
// Fails when a word sticks out of the title box (titles never break words; only 13+ letter words may hyphenate)
// or the hero buttons leave a 390×664 first screen.
// Usage: python3 -m http.server 8781 (repo root) & node scripts/qa/titles.mjs
import { spawn } from "node:child_process";
import { readFileSync } from "node:fs";
const BASE = process.env.BASE || "http://127.0.0.1:8781", PORT = 9353, sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const slugs = JSON.parse(readFileSync(new URL("../../data/recipes.json", import.meta.url))).recipes.map((r) => r.slug);
const LANGS = ["en", "pt", "es", "de", "zh"], VP = [[344, 780], [390, 664], [1000, 700]];
const chrome = spawn("/Applications/Google Chrome.app/Contents/MacOS/Google Chrome", ["--headless=new", `--remote-debugging-port=${PORT}`, "--user-data-dir=/tmp/hte-qa-titles", "--no-first-run", "--hide-scrollbars"], { stdio: "ignore" });
for (let i = 0; i < 50; i++) { try { await fetch(`http://127.0.0.1:${PORT}/json/version`); break; } catch { await sleep(200); } }
// Every character of the H1 is measured against the title box.
const PROBE = `(async () => { await document.fonts.ready;
  const h = document.querySelector(".hero h1"), b = h.getBoundingClientRect(), r = document.createRange(), out = [];
  const w = document.createTreeWalker(h, NodeFilter.SHOW_TEXT);
  for (let n; (n = w.nextNode()); ) for (let i = 0; i < n.length; i++) { r.setStart(n, i); r.setEnd(n, i + 1); const c = r.getClientRects()[0]; if (!c) continue;
    if (c.right > b.right + 1) out.push("overflow «" + n.textContent.trim().slice(0, 30) + "» +" + Math.round(c.right - b.right) + "px"); }
  const cta = Math.round(document.querySelector(".cta").getBoundingClientRect().bottom + scrollY);
  return JSON.stringify({ bad: [...new Set(out)], cta, wide: document.documentElement.scrollWidth > innerWidth });
})()`;
const target = await (await fetch(`http://127.0.0.1:${PORT}/json/new?about:blank`, { method: "PUT" })).json();
const ws = new WebSocket(target.webSocketDebuggerUrl);
await new Promise((r) => (ws.onopen = r));
let id = 0; const pend = new Map(), evs = [];
ws.onmessage = (e) => { const m = JSON.parse(e.data); if (m.id && pend.has(m.id)) { pend.get(m.id)(m.result); pend.delete(m.id); } else evs.forEach((f) => f(m)); };
const send = (method, params = {}) => new Promise((r) => { pend.set(++id, r); ws.send(JSON.stringify({ id, method, params })); });
await send("Page.enable"); await send("Network.enable"); await send("Network.setCacheDisabled", { cacheDisabled: true });
let fails = 0;
for (const [w, hgt] of VP) {
  await send("Emulation.setDeviceMetricsOverride", { width: w, height: hgt, deviceScaleFactor: 1, mobile: w < 1000 });
  for (const lang of LANGS) for (const s of slugs) {
    const l = new Promise((r) => { const f = (m) => m.method === "Page.loadEventFired" && (evs.splice(evs.indexOf(f), 1), r()); evs.push(f); });
    await send("Page.navigate", { url: `${BASE}${lang === "en" ? "" : "/" + lang}/recipes/${s}/` });
    await Promise.race([l, sleep(8000)]);
    const v = JSON.parse((await send("Runtime.evaluate", { expression: PROBE, awaitPromise: true, returnByValue: true })).result.value);
    const over = w === 390 && v.cta > hgt;
    if (v.bad.length || v.wide || over) { fails++; console.log(`✗ ${w} ${lang} ${s}: ${[...v.bad, v.wide ? "page wider than screen" : "", over ? `buttons at ${v.cta}/${hgt}` : ""].filter(Boolean).join(" | ")}`); }
  }
}
console.log(`${VP.length * LANGS.length * slugs.length} titles checked · ${fails} problems`);
ws.close(); chrome.kill();
process.exit(fails ? 1 : 0);
