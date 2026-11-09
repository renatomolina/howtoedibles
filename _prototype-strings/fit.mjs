// PROTOTYPE helper: string fit check. Every prototype on this branch × 5 langs × phone/tablet/desktop viewports.
//  cut   – an element's own text (or input value) sticks out of its box, or the page is wider than the screen
//  wrap  – a one-line control (button, chip, sticker, eyebrow, segmented control, ad label, footer link…) breaks onto 2+ lines
//  fold  – recipe page, portrait phones: the hero buttons end inside the first screen
// Usage: python3 -m http.server 8777 (worktree root) & node _prototype-strings/fit.mjs [outdir]
import { spawn } from "node:child_process";
import { mkdirSync, writeFileSync } from "node:fs";
const out = process.argv[2] || "/tmp/hte-fit";
mkdirSync(out, { recursive: true });
const VP = [["Fold cover", 344, 780, 1], ["Galaxy A", 360, 560, 1], ["iPhone SE", 375, 548, 1], ["iPhone 14", 390, 664, 1], ["iPhone Plus", 430, 752, 1], ["iPad", 820, 1106, 1], ["Laptop", 1280, 633, 0]];
const LANGS = ["en", "pt", "es", "de", "zh"];
const PAGES = [
  ...["pot-brownies", "cannabis-hot-chocolate", "infused-keto-chocolate-avocado-mousse"].map((r) => ["recipe", `recipes/_prototype-recipe-final/?r=${r}`]),
  ["home", "recipes/_prototype-homepage/?v=hybrid&page=home"], ["category", "recipes/_prototype-homepage/?page=cat&c=International"], ["category-2", "recipes/_prototype-homepage/?page=cat&c=Essentials"],
  ["results", "recipes/_prototype-homepage/?page=q&q=brownie"], ["no-results", "recipes/_prototype-homepage/?page=q&q=zzzz"],
  ...["calc", "articles", "404", "article", "donate"].map((p) => [p, `_prototype-pages/?page=${p}`]),
  ["nav-search", "recipes/_prototype-navigation/?open=search"], ["nav-none", "recipes/_prototype-navigation/?open=search&q=zzzz"], ["nav-menu", "recipes/_prototype-navigation/?open=menu"],
];
// controls that must stay on one line (each text node inside is checked separately, so a chip's value + label may stack by design)
const ONE_LINE = "button, .btn, .chip, .chips a, .seg > *, .txtbtn, .spill, .dot, .sticker, .eyebrow, .ad small, .cfoot a, .sh > a, .facts b, .facts span, .tiles b, .tiles small, .tile b, .tile small, .crumb, .you, .reset, .langs a, .mk, .ftr h4, .bh > a, .more, .help, .peek small, .peek b, .lvl b, .tot, .u, label.q, .q, .meta, .count, th";
const PORT = 9347, sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const chrome = spawn("/Applications/Google Chrome.app/Contents/MacOS/Google Chrome", ["--headless=new", `--remote-debugging-port=${PORT}`, "--user-data-dir=/tmp/hte-fit-chrome", "--no-first-run", "--hide-scrollbars"], { stdio: "ignore" });
for (let i = 0; i < 50; i++) { try { await fetch(`http://127.0.0.1:${PORT}/json/version`); break; } catch { await sleep(200); } }

const PROBE = `async (ONE_LINE) => {
  await document.fonts.ready; await new Promise((f) => setTimeout(f, 60));
  const vw = innerWidth, vh = innerHeight, cut = [], wrap = [], lab = (e) => (e.tagName + "." + (e.className.baseVal ?? e.className)).replace(/ +/g, ".");
  const seen = (e) => { for (let p = e; p; p = p.parentElement) { const cs = getComputedStyle(p); if (cs.display === "none" || cs.visibility === "hidden") return false; if (p.tagName === "DIALOG" && !p.open) return false; } return true; };
  if (document.documentElement.scrollWidth > vw) cut.push("page " + document.documentElement.scrollWidth + "px wide");
  for (const e of document.querySelectorAll("#app *, main *, footer *, dialog[open] *")) {
    if (e.closest("svg, #bar, #fold, .rail-x") || !e.clientWidth) continue;
    const cs = getComputedStyle(e);
    if (["auto", "scroll"].includes(cs.overflowX) || cs.display === "none") continue;
    if (e.tagName !== "INPUT" && ![...e.childNodes].some((n) => n.nodeType === 3 && n.textContent.trim())) continue;
    if (e.scrollWidth > e.clientWidth + 1 && seen(e)) cut.push((cs.textOverflow === "ellipsis" ? "…" : "") + lab(e) + " +" + (e.scrollWidth - e.clientWidth) + "px «" + (e.value || e.textContent || "").trim().slice(0, 40) + "»");
  }
  for (const e of document.querySelectorAll(ONE_LINE)) {
    if (e.closest("#bar, svg") || !seen(e) || !e.getClientRects().length) continue;
    const w = document.createTreeWalker(e, NodeFilter.SHOW_TEXT);
    for (let n; (n = w.nextNode()); ) {
      if (!n.textContent.trim() || !seen(n.parentElement)) continue;
      const r = document.createRange(); r.selectNodeContents(n);
      const tops = new Set([...r.getClientRects()].filter((b) => b.width > 1).map((b) => Math.round(b.top / 4)));
      if (tops.size > 1) { wrap.push(lab(e) + " «" + e.textContent.trim().replace(/\\s+/g, " ").slice(0, 44) + "» " + tops.size + " lines"); break; }
    }
  }
  const M = window.__m || {}, fold = vw < 1000 && vh > vw && M.ctaBottom ? (M.ctaBottom <= vh ? "ok" : "OVER " + M.ctaBottom + "/" + vh) : null;
  return JSON.stringify({ cut: [...new Set(cut)], wrap: [...new Set(wrap)], fold });
}`;

async function runVP([name, w, h, mobile]) {
  const target = await (await fetch(`http://127.0.0.1:${PORT}/json/new?about:blank`, { method: "PUT" })).json();
  const ws = new WebSocket(target.webSocketDebuggerUrl);
  await new Promise((r) => (ws.onopen = r));
  let id = 0; const pend = new Map(), evs = [];
  ws.onmessage = (e) => { const m = JSON.parse(e.data); if (m.id && pend.has(m.id)) { pend.get(m.id)(m); pend.delete(m.id); } else evs.forEach((f) => f(m)); };
  const send = (method, params = {}) => new Promise((r) => { pend.set(++id, r); ws.send(JSON.stringify({ id, method, params })); });
  await send("Page.enable"); await send("Runtime.enable");
  await send("Emulation.setDeviceMetricsOverride", { width: w, height: h, deviceScaleFactor: 1, mobile: !!mobile });
  await send("Emulation.setTouchEmulationEnabled", { enabled: !!mobile });
  await send("Emulation.setEmulatedMedia", { features: [{ name: "prefers-reduced-motion", value: "reduce" }] });
  const errs = []; evs.push((m) => m.method === "Runtime.exceptionThrown" && errs.push(m.params.exceptionDetails.exception?.description?.split("\n")[0]));
  const rows = [];
  for (const [page, path] of PAGES) for (const lang of LANGS) {
    errs.length = 0;
    const loaded = new Promise((r) => { const f = (m) => m.method === "Page.loadEventFired" && r(); evs.push(f); });
    await send("Page.navigate", { url: `http://127.0.0.1:8777/${path}&lang=${lang}&shot=1&_=${Date.now()}` });
    await Promise.race([loaded, sleep(8000)]); await sleep(900);
    const v = await send("Runtime.evaluate", { expression: `(${PROBE})(${JSON.stringify(ONE_LINE)})`, awaitPromise: true, returnByValue: true });
    const res = JSON.parse(v.result?.result?.value || '{"cut":["probe failed"],"wrap":[]}');
    const row = { vp: `${name} ${w}×${h}`, page, lang, ...res, errs: [...errs] };
    rows.push(row);
    if (row.cut.length || row.wrap.length || row.errs.length || /OVER/.test(row.fold || "")) {
      const s = await send("Page.captureScreenshot", { format: "jpeg", quality: 60, captureBeyondViewport: false });
      writeFileSync(`${out}/${w}_${page}_${lang}.jpg`, Buffer.from(s.result.data, "base64"));
    }
  }
  ws.close(); await fetch(`http://127.0.0.1:${PORT}/json/close/${target.id}`);
  return rows;
}

const all = (await Promise.all(VP.map(runVP))).flat();
writeFileSync(`${out}/report.json`, JSON.stringify(all, null, 1));
const bad = all.filter((x) => x.cut.length || x.wrap.length || x.errs.length || /OVER/.test(x.fold || ""));
console.log(`${all.length} combos (${PAGES.length} pages × ${LANGS.length} langs × ${VP.length} viewports) · ${bad.length} with a problem`);
for (const x of bad) console.log(`✗ ${x.vp.padEnd(22)} ${x.page.padEnd(10)} ${x.lang}  ${x.fold && x.fold !== "ok" ? x.fold + " " : ""}${[...x.errs.map((e) => "ERR " + e), ...x.cut.map((c) => "CUT " + c), ...x.wrap.map((c) => "WRAP " + c)].join(" | ")}`);
chrome.kill();
