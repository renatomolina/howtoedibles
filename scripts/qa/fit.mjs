// Gate: string fit on the GENERATED pages (ported from the strings prototype, #64).
// Page states × 5 languages × 7 viewports:
//  cut  – an element's own text (or input value) sticks out of its box, or the page is wider than the screen
//  wrap – a one-line control (button, chip, sticker, eyebrow, segmented control, ad label, footer pill…) breaks onto 2+ lines
//  fold – recipe pages, portrait phones: the hero buttons end inside the first screen
//  errs – uncaught JS errors
// Usage: python3 -m http.server 8781 (repo root) & node scripts/qa/fit.mjs [outdir]   (BASE=… to change the server)
import { spawn } from "node:child_process";
import { mkdirSync, writeFileSync } from "node:fs";
const out = process.argv[2] || "/tmp/hte-fit";
mkdirSync(out, { recursive: true });
const BASE = process.env.BASE || "http://127.0.0.1:8781";
const VP = [["Fold cover", 344, 780, 1], ["Galaxy A", 360, 560, 1], ["iPhone SE", 375, 548, 1], ["iPhone 14", 390, 664, 1], ["iPhone Plus", 430, 752, 1], ["iPad", 820, 1106, 1], ["Laptop", 1280, 633, 0]];
const LANGS = ["en", "pt", "es", "de", "zh"];
const search = (q) => `document.querySelector('[data-open=search]').click(); await new Promise((r) => setTimeout(r, 700)); const q = document.getElementById('q'); q.value = ${JSON.stringify(q)}; q.dispatchEvent(new Event('input'));`;
const PAGES = [ // name, path (after the language prefix), setup run in the page before measuring
  ...["pot-brownies", "cannabis-hot-chocolate", "infused-keto-chocolate-avocado-mousse"].map((r) => ["recipe", `/recipes/${r}/`, ""]),
  ["category", "/category/international/", ""], ["category-2", "/category/essentials/", ""],
  ["search", "/recipes/pot-brownies/", "document.querySelector('[data-open=search]').click();"],
  ["search-q", "/recipes/pot-brownies/", search("choc")], ["search-none", "/recipes/pot-brownies/", search("zzzz")],
  ["menu", "/recipes/pot-brownies/", "document.querySelector('[data-open=menu]').click();"],
];
// controls that must stay on one line (each text node inside is checked separately, so a chip's value + label may stack by design)
const ONE_LINE = "button, .btn, .chip, .chips a, .seg > *, .txtbtn, .spill, .dot, .sticker, .eyebrow, .ad small, .cfoot a, .sh > a, .facts b, .facts span, .tiles small, .crumb, .reset, .langs a, .bh > a, .more, .help, .helpbox, .peek small, .peek b, .lvl b, .tot, .u, .back";
const PORT = 9347, sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const chrome = spawn("/Applications/Google Chrome.app/Contents/MacOS/Google Chrome", ["--headless=new", `--remote-debugging-port=${PORT}`, "--user-data-dir=/tmp/hte-qa-fit", "--no-first-run", "--hide-scrollbars"], { stdio: "ignore" });
for (let i = 0; i < 50; i++) { try { await fetch(`http://127.0.0.1:${PORT}/json/version`); break; } catch { await sleep(200); } }

const PROBE = (setup) => `(async () => {
  await document.fonts.ready; ${setup} await new Promise((f) => setTimeout(f, 250));
  const vw = innerWidth, vh = innerHeight, cut = [], wrap = [], lab = (e) => (e.tagName + "." + (e.className.baseVal ?? e.className)).replace(/ +/g, ".");
  const seen = (e) => { for (let p = e; p; p = p.parentElement) { const cs = getComputedStyle(p); if (cs.display === "none" || cs.visibility === "hidden") return false; if (p.tagName === "DIALOG" && !p.open) return false; } return true; };
  const open = document.querySelector("dialog[open]");
  if (document.documentElement.scrollWidth > vw) cut.push("page " + document.documentElement.scrollWidth + "px wide");
  for (const e of document.querySelectorAll(open ? "dialog[open] *" : "header *, main *, footer *, .mini *")) {
    if (e.closest("svg") || !e.clientWidth) continue;
    const cs = getComputedStyle(e);
    if (["auto", "scroll"].includes(cs.overflowX) || cs.display === "none") continue;
    if (e.tagName !== "INPUT" && ![...e.childNodes].some((n) => n.nodeType === 3 && n.textContent.trim())) continue;
    if (e.scrollWidth > e.clientWidth + 1 && seen(e)) cut.push((cs.textOverflow === "ellipsis" ? "…" : "") + lab(e) + " +" + (e.scrollWidth - e.clientWidth) + "px «" + (e.value || e.textContent || "").trim().slice(0, 40) + "»");
  }
  for (const e of (open || document).querySelectorAll(ONE_LINE)) {
    if (e.closest("svg") || !seen(e) || !e.getClientRects().length) continue;
    const w = document.createTreeWalker(e, NodeFilter.SHOW_TEXT);
    for (let n; (n = w.nextNode()); ) {
      if (!n.textContent.trim() || !seen(n.parentElement)) continue;
      const r = document.createRange(); r.selectNodeContents(n);
      const tops = new Set([...r.getClientRects()].filter((b) => b.width > 1).map((b) => Math.round(b.top / 4)));
      if (tops.size > 1) { wrap.push(lab(e) + " «" + e.textContent.trim().replace(/\\s+/g, " ").slice(0, 44) + "» " + tops.size + " lines"); break; }
    }
  }
  const cta = document.querySelector(".cta"), b = cta && Math.round(cta.getBoundingClientRect().bottom + scrollY);
  const fold = !open && cta && vw < 1000 && vh > vw ? (b <= vh ? "ok" : "OVER " + b + "/" + vh) : null;
  return JSON.stringify({ cut: [...new Set(cut)], wrap: [...new Set(wrap)], fold });
})()`.replace("ONE_LINE", JSON.stringify(ONE_LINE));

async function runVP([name, w, h, mobile]) {
  const target = await (await fetch(`http://127.0.0.1:${PORT}/json/new?about:blank`, { method: "PUT" })).json();
  const ws = new WebSocket(target.webSocketDebuggerUrl);
  await new Promise((r) => (ws.onopen = r));
  let id = 0; const pend = new Map(), evs = [];
  ws.onmessage = (e) => { const m = JSON.parse(e.data); if (m.id && pend.has(m.id)) { pend.get(m.id)(m); pend.delete(m.id); } else evs.forEach((f) => f(m)); };
  const send = (method, params = {}) => new Promise((r) => { pend.set(++id, r); ws.send(JSON.stringify({ id, method, params })); });
  await send("Page.enable"); await send("Runtime.enable"); await send("Network.enable"); await send("Network.setCacheDisabled", { cacheDisabled: true });
  await send("Emulation.setDeviceMetricsOverride", { width: w, height: h, deviceScaleFactor: 1, mobile: !!mobile });
  await send("Emulation.setTouchEmulationEnabled", { enabled: !!mobile });
  await send("Emulation.setEmulatedMedia", { features: [{ name: "prefers-reduced-motion", value: "reduce" }] });
  const errs = []; evs.push((m) => m.method === "Runtime.exceptionThrown" && errs.push(m.params.exceptionDetails.exception?.description?.split("\n")[0]));
  const rows = [];
  for (const [page, path, setup] of PAGES) for (const lang of LANGS) {
    errs.length = 0;
    const loaded = new Promise((r) => { const f = (m) => m.method === "Page.loadEventFired" && (evs.splice(evs.indexOf(f), 1), r()); evs.push(f); });
    await send("Page.navigate", { url: `${BASE}${lang === "en" ? "" : "/" + lang}${path}` });
    await Promise.race([loaded, sleep(8000)]);
    const v = await send("Runtime.evaluate", { expression: PROBE(setup), awaitPromise: true, returnByValue: true });
    const res = JSON.parse(v.result?.result?.value || `{"cut":["probe failed: ${(v.result?.exceptionDetails?.exception?.description || "").split("\n")[0].replace(/"/g, "'")}"],"wrap":[]}`);
    const row = { vp: `${name} ${w}×${h}`, page, path, lang, ...res, errs: [...errs] };
    rows.push(row);
    if (row.cut.length || row.wrap.length || row.errs.length || /OVER/.test(row.fold || "")) {
      const s = await send("Page.captureScreenshot", { format: "jpeg", quality: 60 });
      writeFileSync(`${out}/${w}_${page}_${lang}.jpg`, Buffer.from(s.result.data, "base64"));
    }
  }
  ws.close(); await fetch(`http://127.0.0.1:${PORT}/json/close/${target.id}`);
  return rows;
}

const all = (await Promise.all(VP.map(runVP))).flat();
writeFileSync(`${out}/report.json`, JSON.stringify(all, null, 1));
const bad = all.filter((x) => x.cut.length || x.wrap.length || x.errs.length || /OVER/.test(x.fold || ""));
console.log(`${all.length} combos (${PAGES.length} page states × ${LANGS.length} langs × ${VP.length} viewports) · ${bad.length} with a problem`);
for (const x of bad) console.log(`✗ ${x.vp.padEnd(22)} ${x.page.padEnd(11)} ${x.lang}  ${x.fold && x.fold !== "ok" ? x.fold + " " : ""}${[...x.errs.map((e) => "ERR " + e), ...x.cut.map((c) => "CUT " + c), ...x.wrap.map((c) => "WRAP " + c)].join(" | ")}`);
chrome.kill();
process.exit(bad.length ? 1 : 0);
