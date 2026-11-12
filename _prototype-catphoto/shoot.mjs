// Throwaway: screenshots + device matrix for the category-photo prototype.
// Usage: serve the repo root (python3 -I scripts/qa/serve.py 8787) & BASE=http://127.0.0.1:8787 node _prototype-catphoto/shoot.mjs
// shots/            phone 390×664, tablet 820×1180, desktop 1280×900 at 2x: category first screen, homepage tiles, menu
// shots/matrix.txt  36 viewports × 4 langs × variants × pages: horizontal overflow, text over a photo, band height
import { spawn } from "node:child_process";
import { mkdirSync, writeFileSync } from "node:fs";
const BASE = process.env.BASE || "http://127.0.0.1:8787", DIR = new URL(".", import.meta.url).pathname, OUT = DIR + "shots";
mkdirSync(OUT, { recursive: true });
const PORT = 9361, sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const chrome = spawn("/Applications/Google Chrome.app/Contents/MacOS/Google Chrome", ["--headless=new", `--remote-debugging-port=${PORT}`, "--user-data-dir=/tmp/hte-proto-catphoto", "--no-first-run", "--hide-scrollbars"], { stdio: "ignore" });
for (let i = 0; i < 50; i++) { try { await fetch(`http://127.0.0.1:${PORT}/json/version`); break; } catch { await sleep(200); } }

async function tab() {
  const t = await (await fetch(`http://127.0.0.1:${PORT}/json/new?about:blank`, { method: "PUT" })).json();
  const ws = new WebSocket(t.webSocketDebuggerUrl); await new Promise((r) => (ws.onopen = r));
  let id = 0; const pend = new Map(), evs = [];
  ws.onmessage = (e) => { const m = JSON.parse(e.data); if (m.id && pend.has(m.id)) { pend.get(m.id)(m.result); pend.delete(m.id); } else evs.forEach((f) => f(m)); };
  const send = (method, params = {}) => new Promise((r) => { pend.set(++id, r); ws.send(JSON.stringify({ id, method, params })); });
  await send("Page.enable");
  await send("Emulation.setEmulatedMedia", { features: [{ name: "prefers-reduced-motion", value: "reduce" }] });
  // fast: geometry only (img boxes come from width/height + CSS), so no image decode wait
  const go = async (url, w, h, dsf = 1, mobile = true, theme = "light", fast = false) => {
    await send("Emulation.setDeviceMetricsOverride", { width: w, height: h, deviceScaleFactor: dsf, mobile });
    if (!fast) await send("Emulation.setEmulatedMedia", { features: [{ name: "prefers-reduced-motion", value: "reduce" }, { name: "prefers-color-scheme", value: theme }] });
    const loaded = new Promise((res) => { const f = (m) => m.method === "Page.loadEventFired" && (evs.splice(evs.indexOf(f), 1), res()); evs.push(f); });
    if (!fast) { await send("Page.navigate", { url: "about:blank" }); await sleep(30); }
    await send("Page.navigate", { url }); await Promise.race([loaded, sleep(10000)]);
    if (fast) { await ev(`document.fonts.ready.then(()=>new Promise(r=>setTimeout(r,50)))`); return; }
    await ev(`document.fonts.ready.then(()=>Promise.race([new Promise(r=>setTimeout(r,3000)),Promise.all([...document.images].filter(i=>i.loading!=="lazy"||i.getBoundingClientRect().top<innerHeight).map(i=>i.decode().catch(()=>0)))]))`);
    await sleep(120);
  };
  const ev = async (expression) => (await send("Runtime.evaluate", { expression, awaitPromise: true, returnByValue: true })).result?.value;
  const shot = async (file) => { const s = await send("Page.captureScreenshot", { format: "jpeg", quality: 72 }); writeFileSync(`${OUT}/${file}.jpg`, Buffer.from(s.data, "base64")); };
  return { go, ev, shot, close: async () => { ws.close(); await fetch(`http://127.0.0.1:${PORT}/json/close/${t.id}`); } };
}

// Text that sits on a photo. Circles (A, C) use real circle geometry; B's photo fades out, so a text box only
// counts when the mask is ≥ 25 % opaque under it (mask stops mirrored from the CSS, per breakpoint).
const PROBE = `(() => {
  const vw = innerWidth, bad = [], v = location.pathname.split("/").at(-2);
  if (document.documentElement.scrollWidth > vw) bad.push("page " + document.documentElement.scrollWidth + "px wide");
  const scopes = [...document.querySelectorAll("main .band, main .tiles .cv, #menu .tiles .cv")];
  const lines = (el) => { const r = document.createRange(); r.selectNodeContents(el); return [...r.getClientRects()].filter((b) => b.width > 1); };
  const alphaB = (img, x, y, tile) => {
    const b = img.getBoundingClientRect(), fx = (x - b.left) / b.width, fy = (b.bottom - y) / b.height;
    const ax = Math.min(1, Math.max(0, fx / (tile ? 0.7 : vw >= 720 ? 0.6 : 0.5)));
    const ay = tile ? Math.min(1, Math.max(0, ((y - b.top) / b.height - 0.12) / 0.38)) : vw >= 720 ? 1 : Math.min(1, Math.max(0, fy / 0.45));
    return ax * ay;
  };
  for (const s of scopes) {
    const photos = [...s.querySelectorAll(":scope > .pv, :scope > .trio > img")];
    if (!photos.length) continue;
    const isMenu = !!s.closest("#menu"); if (isMenu && !document.querySelector("#menu[open]")) continue;
    for (const t of s.querySelectorAll(":scope > h1, :scope > p, :scope > .back, :scope > b, :scope > small")) for (const L of (t.matches(".back") ? [t.getBoundingClientRect()] : lines(t))) for (const p of photos) {
      const P = p.getBoundingClientRect();
      if (L.right <= P.left || L.left >= P.right || L.bottom <= P.top || L.top >= P.bottom) continue;
      let hit;
      if (v === "b") { hit = Math.max(alphaB(p, L.right, L.top, !t.closest(".band")), alphaB(p, L.right, (L.top + L.bottom) / 2, !t.closest(".band"))) >= 0.25; }
      else { const cx = (P.left + P.right) / 2, cy = (P.top + P.bottom) / 2, r = P.width / 2 + (v === "c" ? 3 : 5);
             const nx = Math.max(L.left, Math.min(cx, L.right)), ny = Math.max(L.top, Math.min(cy, L.bottom)); hit = (nx - cx) ** 2 + (ny - cy) ** 2 < r * r; }
      if (hit) bad.push((t.tagName + "." + t.className).replace(/\\.$/, "") + " on photo «" + t.textContent.trim().slice(0, 24) + "»");
    }
  }
  const band = document.querySelector(".band");
  return JSON.stringify({ bad: [...new Set(bad)], band: band ? Math.round(band.getBoundingClientRect().height) : null, grid: document.querySelector(".grid") ? Math.round(document.querySelector(".grid").getBoundingClientRect().top + scrollY) : null });
})()`;

const V = ["0", "a", "b", "c"], LANGS = ["en", "pt", "de", "zh"];
const VIEW = [["phone", 390, 664, 1], ["tablet", 820, 1180, 1], ["desktop", 1280, 900, 0]];
const t = await tab();
// wait 400 ms, then for the matching images to decode (at most 3 s), then 200 ms
const WAIT = (sel) => `new Promise((r) => setTimeout(r, 400)).then(() => Promise.race([new Promise((r) => setTimeout(r, 3000)), Promise.all([...document.querySelectorAll(${JSON.stringify(sel)})].map((i) => i.decode().catch(() => 0)))])).then(() => new Promise((r) => setTimeout(r, 200)))`;

// 1) screenshots
if (!process.env.MATRIX_ONLY) for (const v of V) for (const [vn, w, h, m] of VIEW) {
  await t.go(`${BASE}/_prototype-catphoto/${v}/en-desserts.html?shot`, w, h, 2, !!m); await t.shot(`${v}_${vn}_cat-desserts`);
  await t.go(`${BASE}/_prototype-catphoto/${v}/de-international.html?shot`, w, h, 2, !!m); await t.shot(`${v}_${vn}_cat-de-international`);
  await t.go(`${BASE}/_prototype-catphoto/${v}/en-home.html?shot`, w, h, 2, !!m);
  await t.ev(`scrollTo(0, document.querySelector("main .tiles").getBoundingClientRect().top + scrollY - 70); ${WAIT("main .tiles img")}`);
  await t.shot(`${v}_${vn}_home-tiles`);
  if (vn === "phone") {
    await t.go(`${BASE}/_prototype-catphoto/${v}/pt-home.html?shot`, w, h, 2, true);
    await t.ev(`document.querySelector('[data-open="menu"]').click(); ${WAIT("#menu img")}`);
    await t.shot(`${v}_${vn}_menu-pt`);
    await t.go(`${BASE}/_prototype-catphoto/${v}/en-desserts.html?shot`, w, h, 2, true, "dark"); await t.shot(`${v}_${vn}_cat-desserts-dark`);
    await t.go(`${BASE}/_prototype-catphoto/${v}/zh-international.html?shot`, w, h, 2, true); await t.shot(`${v}_${vn}_cat-zh-international`);
  }
}
console.log("shots done");
if (process.env.SHOTS_ONLY) { await t.close(); chrome.kill(); process.exit(0); }

// 2) matrix (same 36 visible-area viewports as scripts/qa/devices.mjs)
const D = [["iPhone SE", 375, 548, 1], ["iPhone 13 mini", 375, 629, 1], ["iPhone 14", 390, 664, 1], ["iPhone 16", 393, 672, 1], ["iPhone 16 Pro", 402, 694, 1],
  ["iPhone 16 Plus", 430, 752, 1], ["iPhone 16 Pro Max", 440, 776, 1], ["Galaxy S24", 360, 652, 1], ["Galaxy S24 Ultra", 384, 740, 1], ["Galaxy A (small)", 360, 560, 1],
  ["Pixel 8", 412, 790, 1], ["Galaxy Z Fold cover", 344, 780, 1], ["Galaxy Z Fold open", 673, 740, 1], ["iPhone 16 landscape", 852, 340, 1], ["Galaxy S24 landscape", 780, 300, 1],
  ["iPad mini", 744, 1059, 1], ["iPad mini landscape", 1133, 670, 1], ["iPad 10th", 820, 1106, 1], ["iPad 10th landscape", 1180, 746, 1],
  ["iPad Pro 11", 834, 1136, 1], ["iPad Pro 11 landscape", 1210, 760, 1], ["iPad Pro 13", 1032, 1302, 1], ["iPad Pro 13 landscape", 1376, 958, 1],
  ["Galaxy Tab S9", 800, 1180, 1], ["Galaxy Tab S9 landscape", 1280, 740, 1],
  ["Desktop 999 (edge)", 999, 700, 0], ["Desktop 1000 (edge)", 1000, 700, 0], ["Laptop 1280×720", 1280, 633, 0], ["Laptop 1366×768", 1366, 657, 0], ["Laptop 1536×864", 1536, 730, 0],
  ["Laptop 1440×900", 1440, 789, 0], ["MacBook Air 13", 1470, 832, 0], ["MacBook Pro 14", 1512, 860, 0], ["MacBook Pro 16", 1728, 990, 0], ["Desktop 1920×1080", 1920, 969, 0], ["Desktop 2560×1440", 2560, 1329, 0]];
const lines = [], fails = [];
// one tab per variant, in parallel; menu pages only where the menu differs (phones + one tablet + one desktop)
await Promise.all(V.map(async (v) => {
  const tv = await tab();
  for (const [dn, w, h, m] of D) for (const lang of LANGS) for (const page of ["desserts", "international", "home", "menu"]) {
    if (page === "menu" && w > 440 && ![820, 1280].includes(w)) continue;
    await tv.go(`${BASE}/_prototype-catphoto/${v}/${lang}-${page === "menu" ? "home" : page}.html?shot`, w, h, 1, !!m, "light", true);
    if (page === "menu") await tv.ev(`document.querySelector('[data-open="menu"]').click(); new Promise(r=>setTimeout(r,250))`);
    const r = JSON.parse(await tv.ev(PROBE));
    const line = `${v} ${dn.padEnd(24)} ${(w + "×" + h).padEnd(10)} ${lang} ${page.padEnd(13)} band ${r.band ?? "-"} grid@${r.grid ?? "-"} ${r.bad.length ? "✗ " + r.bad.join(" | ") : "✓"}`;
    lines.push(line); if (r.bad.length) fails.push(line);
  }
  await tv.close();
}));
lines.sort();
writeFileSync(`${OUT}/matrix.txt`, lines.join("\n") + "\n");
console.log(`${lines.length} combos · ${fails.length} with a problem`); fails.slice(0, 60).forEach((l) => console.log(l));
await t.close(); chrome.kill();
