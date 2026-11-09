// PROTOTYPE helper: device matrix QA. For every device viewport (visible area, browser bars removed) × lang × recipe it checks:
//  overflow  – page wider than the screen, or any element whose content sticks out of its own box (text, inputs, buttons)
//  fold      – phones/tablets in portrait: the hero buttons end inside the first screen
//  dose      – while cooking (scrolled into the steps on ≥1000px, into the calculator on narrower screens) the dose readout is on screen
//  rail      – ≥1000px: the whole rail can be reached (its bottom is inside the viewport when stuck)
// Usage: node recipes/_prototype-recipe-final/devices.mjs <outdir>   (needs `python3 -m http.server 8766` at repo root)
import { spawn } from "node:child_process";
import { mkdirSync, writeFileSync } from "node:fs";
const out = process.argv[2] || "/tmp/hte-devices";
mkdirSync(out, { recursive: true });
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
const LANGS = ["en", "pt", "de", "zh"], RECIPES = ["pot-brownies", "cannabis-hot-chocolate", "infused-keto-chocolate-avocado-mousse"];
const PORT = 9336, sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const chrome = spawn("/Applications/Google Chrome.app/Contents/MacOS/Google Chrome", ["--headless=new", `--remote-debugging-port=${PORT}`, "--user-data-dir=/tmp/hte-proto-chrome-dev", "--no-first-run", "--hide-scrollbars"], { stdio: "ignore" });
for (let i = 0; i < 50; i++) { try { await fetch(`http://127.0.0.1:${PORT}/json/version`); break; } catch { await sleep(200); } }

// runs inside the page for one lang × recipe
const PROBE = `async (lang, r) => {
  S.lang = lang; S.r = r; await render(); await document.fonts.ready;
  const frame = () => new Promise((f) => setTimeout(f, 40));
  await frame(); measure(); await frame();
  const vw = innerWidth, vh = innerHeight, bad = [];
  if (document.documentElement.scrollWidth > vw) bad.push("page " + document.documentElement.scrollWidth + "px wide");
  for (const e of document.querySelectorAll("main *, header *")) {
    if (e.closest(".chips, svg, .cv>svg, .peek")) continue;
    const cs = getComputedStyle(e);
    if (cs.display === "none" || cs.visibility === "hidden" || !e.clientWidth || ["auto", "scroll"].includes(cs.overflowX)) continue;
    // only elements that hold text themselves (or inputs): intended bleed/crop (cover, chip rails) is not a cut
    if (e.tagName !== "INPUT" && ![...e.childNodes].some((n) => n.nodeType === 3 && n.textContent.trim())) continue;
    if (e.scrollWidth > e.clientWidth + 1) bad.push((e.tagName + "." + (e.className.baseVal ?? e.className)).replace(/ /g, ".") + " +" + (e.scrollWidth - e.clientWidth) + "px «" + (e.value || e.textContent || "").trim().slice(0, 28) + "»");
  }
  const M = window.__m, res = { fold: null, dose: null, rail: null };
  if (vw < 1000 && vh > vw) res.fold = M.ctaBottom <= vh ? "ok " + M.ctaBottom + "/" + vh : "OVER " + M.ctaBottom + "/" + vh;
  if (vw >= 1000) { const hb = Math.round(document.querySelector("h1").getBoundingClientRect().bottom); res.fold = hb <= vh ? "ok title " + hb + "/" + vh : "OVER title " + hb + "/" + vh; }
  const card = document.getElementById("calc"), peek = document.getElementById("peek"), live = document.getElementById("live");
  const shown = (el) => { const b = el.getBoundingClientRect(); return b.top >= -1 && b.bottom <= vh + 1 && b.height > 0; };
  const go = async (y) => { scrollTo({ top: y, behavior: "instant" }); await frame(); onScroll(true); await frame(); };
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
  return JSON.stringify({ bad: bad.slice(0, 6), nBad: bad.length, ...res, h1: M.h1Lines });
}`;

async function runDevice([name, w, h, mobile]) {
  const target = await (await fetch(`http://127.0.0.1:${PORT}/json/new?about:blank`, { method: "PUT" })).json();
  const ws = new WebSocket(target.webSocketDebuggerUrl);
  await new Promise((r) => (ws.onopen = r));
  let id = 0; const pend = new Map(), evs = [];
  ws.onmessage = (e) => { const m = JSON.parse(e.data); if (m.id && pend.has(m.id)) { pend.get(m.id)(m.result); pend.delete(m.id); } else evs.forEach((f) => f(m)); };
  const send = (method, params = {}) => new Promise((r) => { pend.set(++id, r); ws.send(JSON.stringify({ id, method, params })); });
  await send("Page.enable"); 
  await send("Emulation.setDeviceMetricsOverride", { width: w, height: h, deviceScaleFactor: 1, mobile: !!mobile });
  await send("Emulation.setTouchEmulationEnabled", { enabled: !!mobile });
  await send("Emulation.setEmulatedMedia", { features: [{ name: "prefers-reduced-motion", value: "reduce" }] });
  const loaded = new Promise((r) => evs.push((m) => m.method === "Page.loadEventFired" && r()));
  await send("Page.navigate", { url: `http://127.0.0.1:8766/recipes/_prototype-recipe-final/?shot=1&_=${Date.now()}` });
  await loaded; await sleep(1500);
  const rows = [];
  const slug = (s) => s.replace(/[^a-z0-9]+/gi, "_");
  for (const lang of LANGS) for (const r of RECIPES) {
    const v = await Promise.race([send("Runtime.evaluate", { expression: `(${PROBE})(${JSON.stringify(lang)}, ${JSON.stringify(r)})`, awaitPromise: true, returnByValue: true }), sleep(20000).then(() => ({ result: { value: JSON.stringify({ bad: ["TIMEOUT"], nBad: 1 }) } }))]);
    const row = { device: name, vp: `${w}×${h}`, lang, r, ...JSON.parse(v.result?.value || `{"bad":["eval failed: ${(v.exceptionDetails?.exception?.description || "").slice(0, 80)}"]}`) };
    rows.push(row);
    if ((lang === "en" && r === "pot-brownies") || (lang === "de" && r === "infused-keto-chocolate-avocado-mousse") || row.nBad || /OVER|MISSING|CUT/.test(JSON.stringify(row))) {
      const s = await send("Page.captureScreenshot", { format: "jpeg", quality: 60 });
      writeFileSync(`${out}/${slug(name)}__${lang}_${r.split("-").pop()}.jpg`, Buffer.from(s.data, "base64"));
    }
  }
  ws.close(); await fetch(`http://127.0.0.1:${PORT}/json/close/${target.id}`);
  return rows;
}

const all = [];
for (let i = 0; i < D.length; i += 6) (await Promise.all(D.slice(i, i + 6).map(runDevice))).forEach((rs) => all.push(...rs));
writeFileSync(`${out}/report.json`, JSON.stringify(all, null, 1));
const fails = all.filter((x) => x.nBad || /OVER|MISSING|CUT/.test([x.fold, x.dose, x.rail].join(" ")));
console.log(`${all.length} combos on ${D.length} devices · ${fails.length} with a problem`);
for (const d of D) {
  const rs = all.filter((x) => x.device === d[0]);
  const f = rs.filter((x) => fails.includes(x));
  console.log(`${f.length ? "✗" : "✓"} ${d[0].padEnd(24)} ${(d[1] + "×" + d[2]).padEnd(10)} fold ${rs.map((x) => x.fold?.split(" ")[0] ?? "-").filter((s) => s !== "ok").join(",") || "ok"} · dose ${[...new Set(rs.map((x) => x.dose))].join("/")}${rs[0].rail ? " · rail " + [...new Set(rs.map((x) => x.rail?.split(" ")[0]))].join("/") : ""}`);
  for (const x of f) console.log(`    ${x.lang} ${x.r}: ${[x.fold, x.dose, x.rail].filter((s) => /OVER|MISSING|CUT/.test(s || "")).join(" ")} ${x.bad.join(" | ")}`);
}
chrome.kill();
