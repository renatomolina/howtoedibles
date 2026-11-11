// Gate: device-matrix QA on the GENERATED pages (ported from the recipe-final prototype, #59; special pages from #74).
// For 36 device viewports (visible area, browser bars removed) × 5 languages × 3 recipes (short, mid, longest title)
// + the homepage, calculator.html, donate, the articles index, the 404, 4 articles, and about/contact (English only):
//  overflow – the page is wider than the screen, or an element's own text/input value sticks out of its box
//  fold     – phones/tablets in portrait: the hero buttons end inside the first screen (home/calculator: the mg per
//             serving; the other special pages: the H1); desktop: the H1 is visible
//  dose     – while cooking, the dose readout (panel or 56px peek) is on screen
//  rail     – ≥1000px: the whole sticky rail can be reached
//  static   – the build's pre-rendered dose panel equals what js/dose.js renders (window.DOSE.check())
// Usage: python3 -I scripts/qa/serve.py 8781 (repo root) & node scripts/qa/devices.mjs [outdir]   (BASE=… to change the server)
// Needs Google Chrome; no npm deps.
import { spawn } from "node:child_process";
import { mkdirSync, writeFileSync } from "node:fs";
const out = process.argv[2] || "/tmp/hte-devices";
mkdirSync(out, { recursive: true });
const BASE = process.env.BASE || "http://127.0.0.1:8781";
const D = [ // name, width, visible height, mobile?
  ["iPhone SE", 375, 548, 1], ["iPhone 13 mini", 375, 629, 1], ["iPhone 14", 390, 664, 1], ["iPhone 16", 393, 672, 1], ["iPhone 16 Pro", 402, 694, 1],
  ["iPhone 16 Plus", 430, 752, 1], ["iPhone 16 Pro Max", 440, 776, 1], ["Galaxy S24", 360, 652, 1], ["Galaxy S24 Ultra", 384, 740, 1], ["Galaxy A (small)", 360, 560, 1],
  ["Pixel 8", 412, 790, 1], ["Galaxy Z Fold cover", 344, 780, 1], ["Galaxy Z Fold open", 673, 740, 1], ["iPhone 16 landscape", 852, 340, 1], ["Galaxy S24 landscape", 780, 300, 1],
  ["iPad mini", 744, 1059, 1], ["iPad mini landscape", 1133, 670, 1], ["iPad 10th", 820, 1106, 1], ["iPad 10th landscape", 1180, 746, 1],
  ["iPad Pro 11", 834, 1136, 1], ["iPad Pro 11 landscape", 1210, 760, 1], ["iPad Pro 13", 1032, 1302, 1], ["iPad Pro 13 landscape", 1376, 958, 1],
  ["Galaxy Tab S9", 800, 1180, 1], ["Galaxy Tab S9 landscape", 1280, 740, 1],
  ["Desktop 999 (edge)", 999, 700, 0], ["Desktop 1000 (edge)", 1000, 700, 0], ["Laptop 1280×720", 1280, 633, 0], ["Laptop 1366×768", 1366, 657, 0], ["Laptop 1536×864", 1536, 730, 0],
  ["Laptop 1440×900", 1440, 789, 0], ["MacBook Air 13", 1470, 832, 0], ["MacBook Pro 14", 1512, 860, 0], ["MacBook Pro 16", 1728, 990, 0], ["Desktop 1920×1080", 1920, 969, 0], ["Desktop 2560×1440", 2560, 1329, 0],
];
const LANGS = ["en", "pt", "es", "de", "zh"], RECIPES = ["pot-brownies", "cannabis-hot-chocolate", "infused-keto-chocolate-avocado-mousse"];
// the 5th is a missing URL: run with a server that answers with /404.html like GitHub Pages does; then 4 articles (#75)
const PAGES = ["/", "/calculator.html", "/donate.html", "/articles.html", "/recipes/easy-weed-brownies-recipe/",
  "/cannabis-and-sleep.html", "/how-long-do-edibles-take-to-kick-in.html", "/how-to-prevent-a-bad-trip.html", "/how-to-make-cannabis-topicals.html"];
const EN_ONLY = ["/about.html", "/contact.html"];
const PORT = 9336, sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const chrome = spawn("/Applications/Google Chrome.app/Contents/MacOS/Google Chrome", ["--headless=new", `--remote-debugging-port=${PORT}`, "--user-data-dir=/tmp/hte-qa-devices", "--no-first-run", "--hide-scrollbars"], { stdio: "ignore" });
for (let i = 0; i < 50; i++) { try { await fetch(`http://127.0.0.1:${PORT}/json/version`); break; } catch { await sleep(200); } }

// runs inside the loaded page (setTimeout, not rAF: rAF hangs in background tabs)
const PROBE = `(async () => {
  await document.fonts.ready;
  const frame = () => new Promise((f) => setTimeout(f, 60));
  await frame();
  const vw = innerWidth, vh = innerHeight, bad = [];
  if (document.documentElement.scrollWidth > vw) bad.push("page " + document.documentElement.scrollWidth + "px wide");
  for (const e of document.querySelectorAll("main *, header *")) {
    if (e.closest(".chips, svg, .peek")) continue;
    const cs = getComputedStyle(e);
    if (cs.display === "none" || cs.visibility === "hidden" || !e.clientWidth || ["auto", "scroll"].includes(cs.overflowX)) continue;
    if (e.tagName !== "INPUT" && ![...e.childNodes].some((n) => n.nodeType === 3 && n.textContent.trim())) continue;
    if (e.scrollWidth > e.clientWidth + 1) bad.push((e.tagName + "." + (e.className.baseVal ?? e.className)).replace(/ /g, ".") + " +" + (e.scrollWidth - e.clientWidth) + "px «" + (e.value || e.textContent || "").trim().slice(0, 28) + "»");
  }
  const h1 = document.querySelector("h1"), cta = document.querySelector(".cta");
  const res = { fold: null, dose: null, rail: null, h1: Math.round(h1.getBoundingClientRect().height / parseFloat(getComputedStyle(h1).lineHeight)), static: window.DOSE && window.DOSE.check() ? "ok" : "MISMATCH" };
  const ctaBottom = Math.round(cta.getBoundingClientRect().bottom + scrollY);
  if (vw < 1000 && vh > vw) res.fold = ctaBottom <= vh ? "ok " + ctaBottom + "/" + vh : "OVER " + ctaBottom + "/" + vh;
  if (vw >= 1000) { const hb = Math.round(h1.getBoundingClientRect().bottom); res.fold = hb <= vh ? "ok title " + hb + "/" + vh : "OVER title " + hb + "/" + vh; }
  const card = document.getElementById("calc"), peek = document.getElementById("peek"), live = document.getElementById("live");
  const shown = (el) => { const b = el.getBoundingClientRect(); return b.top >= -1 && b.bottom <= vh + 1 && b.height > 0; };
  const go = async (y) => { scrollTo({ top: y, behavior: "instant" }); await frame(); dispatchEvent(new Event("scroll")); await frame(); };
  if (vw >= 1000) {
    await go(document.getElementById("recipe").getBoundingClientRect().top + scrollY + 700);
    res.dose = shown(live) ? "panel" : card.classList.contains("peeking") && shown(peek) ? "peek" : "MISSING";
    const rail = document.querySelector(".rail").getBoundingClientRect();
    res.rail = rail.bottom <= vh + 1 ? "reachable (" + Math.round(rail.height) + "px)" : "CUT " + Math.round(rail.bottom - vh) + "px";
  } else {
    await go(card.getBoundingClientRect().top + scrollY + 420);
    res.dose = shown(live) ? "panel" : card.classList.contains("peeking") && shown(peek) ? "peek" : "MISSING";
  }
  await go(0);
  return JSON.stringify({ bad: bad.slice(0, 6), nBad: bad.length, ...res });
})()`;

// the special pages (#74): no recipe hero; the calculator card is checked where there is one
const PROBE2 = `(async () => {
  await document.fonts.ready;
  const frame = () => new Promise((f) => setTimeout(f, 60));
  await frame(); await frame();
  const vw = innerWidth, vh = innerHeight, bad = [];
  if (document.documentElement.scrollWidth > vw) bad.push("page " + document.documentElement.scrollWidth + "px wide");
  for (const e of document.querySelectorAll("main *, header *")) {
    if (e.closest(".chips, .topics, .strip, svg, .peek, .mk")) continue;
    const cs = getComputedStyle(e);
    if (cs.display === "none" || cs.visibility === "hidden" || !e.clientWidth || ["auto", "scroll"].includes(cs.overflowX)) continue;
    if (e.tagName !== "INPUT" && ![...e.childNodes].some((n) => n.nodeType === 3 && n.textContent.trim())) continue;
    if (e.scrollWidth > e.clientWidth + 1) bad.push((e.tagName + "." + (e.className.baseVal ?? e.className)).replace(/ /g, ".") + " +" + (e.scrollWidth - e.clientWidth) + "px «" + (e.value || e.textContent || "").trim().slice(0, 28) + "»");
  }
  const h1 = document.querySelector("h1"), mg = document.querySelector(".big .mg"), card = document.getElementById("calc");
  const res = { fold: null, dose: null, rail: null, h1: Math.round(h1.getBoundingClientRect().height / parseFloat(getComputedStyle(h1).lineHeight)), static: !window.DOSE || window.DOSE.check() ? "ok" : "MISMATCH" };
  const mark = vw < 1000 && mg ? mg : h1, b = Math.round(mark.getBoundingClientRect().bottom + scrollY);
  if (vh > vw || vw >= 1000) res.fold = (b <= vh ? "ok " : "OVER ") + (mark === mg ? "mg " : "title ") + b + "/" + vh;
  if (card) {
    const peek = document.getElementById("peek"), live = document.getElementById("live");
    const shown = (el) => { const r = el.getBoundingClientRect(); return r.top >= -1 && r.bottom <= vh + 1 && r.height > 0; };
    const go = async (y) => { scrollTo({ top: y, behavior: "instant" }); await frame(); dispatchEvent(new Event("scroll")); await frame(); };
    const sticky = getComputedStyle(document.querySelector(".rail")).position === "sticky";
    await go(sticky ? document.querySelector("#guide").getBoundingClientRect().top + scrollY + 600 : card.getBoundingClientRect().top + scrollY + 420);
    res.dose = shown(live) ? "panel" : card.classList.contains("peeking") && shown(peek) ? "peek" : "MISSING";
    if (sticky) { const r = document.querySelector(".rail").getBoundingClientRect(); res.rail = r.bottom <= vh + 1 ? "reachable (" + Math.round(r.height) + "px)" : "CUT " + Math.round(r.bottom - vh) + "px"; }
    await go(0);
  }
  return JSON.stringify({ bad: bad.slice(0, 6), nBad: bad.length, ...res });
})()`;

async function runDevice([name, w, h, mobile]) {
  const target = await (await fetch(`http://127.0.0.1:${PORT}/json/new?about:blank`, { method: "PUT" })).json();
  const ws = new WebSocket(target.webSocketDebuggerUrl);
  await new Promise((r) => (ws.onopen = r));
  let id = 0; const pend = new Map(), evs = [];
  ws.onmessage = (e) => { const m = JSON.parse(e.data); if (m.id && pend.has(m.id)) { pend.get(m.id)(m.result); pend.delete(m.id); } else evs.forEach((f) => f(m)); };
  const send = (method, params = {}) => new Promise((r) => { pend.set(++id, r); ws.send(JSON.stringify({ id, method, params })); });
  await send("Page.enable"); await send("Network.enable"); await send("Network.setCacheDisabled", { cacheDisabled: true });
  await send("Emulation.setDeviceMetricsOverride", { width: w, height: h, deviceScaleFactor: 1, mobile: !!mobile });
  await send("Emulation.setTouchEmulationEnabled", { enabled: !!mobile });
  await send("Emulation.setEmulatedMedia", { features: [{ name: "prefers-reduced-motion", value: "reduce" }] });
  const rows = [], slug = (s) => s.replace(/[^a-z0-9]+/gi, "_");
  for (const lang of LANGS) for (const r of [...RECIPES, ...PAGES, ...(lang === "en" ? EN_ONLY : [])]) {
    const page = r.startsWith("/");
    const loaded = new Promise((res) => { const f = (m) => m.method === "Page.loadEventFired" && (evs.splice(evs.indexOf(f), 1), res()); evs.push(f); });
    await send("Page.navigate", { url: `${BASE}${lang === "en" ? "" : "/" + lang}${page ? (lang === "en" && r === "/calculator.html" ? "/edible-dosage-calculator/" : r) : `/recipes/${r}/`}` });
    await Promise.race([loaded, sleep(10000)]);
    const v = await Promise.race([send("Runtime.evaluate", { expression: page ? PROBE2 : PROBE, awaitPromise: true, returnByValue: true }), sleep(20000).then(() => ({ result: { value: JSON.stringify({ bad: ["TIMEOUT"], nBad: 1 }) } }))]);
    const row = { device: name, vp: `${w}×${h}`, lang, r, ...JSON.parse(v.result?.value || `{"bad":["eval failed: ${(v.exceptionDetails?.exception?.description || "").slice(0, 80)}"],"nBad":1}`) };
    rows.push(row);
    if ((lang === "en" && (r === "pot-brownies" || page)) || (lang === "de" && r === "infused-keto-chocolate-avocado-mousse") || row.nBad || /OVER|MISSING|CUT|MISMATCH/.test(JSON.stringify(row))) {
      const s = await send("Page.captureScreenshot", { format: "jpeg", quality: 60 });
      writeFileSync(`${out}/${slug(name)}__${lang}_${slug(page ? r : r.split("-").pop())}.jpg`, Buffer.from(s.data, "base64"));
    }
  }
  ws.close(); await fetch(`http://127.0.0.1:${PORT}/json/close/${target.id}`);
  return rows;
}

const all = [];
for (let i = 0; i < D.length; i += 6) (await Promise.all(D.slice(i, i + 6).map(runDevice))).forEach((rs) => all.push(...rs));
writeFileSync(`${out}/report.json`, JSON.stringify(all, null, 1));
const isBad = (x) => x.nBad || /OVER|MISSING|CUT|MISMATCH/.test([x.fold, x.dose, x.rail, x.static].join(" "));
const fails = all.filter(isBad);
console.log(`${all.length} combos on ${D.length} devices · ${fails.length} with a problem`);
for (const d of D) {
  const rs = all.filter((x) => x.device === d[0]), f = rs.filter(isBad);
  console.log(`${f.length ? "✗" : "✓"} ${d[0].padEnd(24)} ${(d[1] + "×" + d[2]).padEnd(10)} fold ${rs.map((x) => x.fold?.split(" ")[0] ?? "-").filter((s) => s !== "ok").join(",") || "ok"} · dose ${[...new Set(rs.map((x) => x.dose))].join("/")}${rs[0].rail ? " · rail " + [...new Set(rs.map((x) => x.rail?.split(" ")[0]))].join("/") : ""}`);
  for (const x of f) console.log(`    ${x.lang} ${x.r}: ${[x.fold, x.dose, x.rail, x.static].filter((s) => /OVER|MISSING|CUT|MISMATCH/.test(s || "")).join(" ")} ${(x.bad || []).join(" | ")}`);
}
chrome.kill();
process.exit(fails.length ? 1 : 0);
