// Mobile UI audit: screenshots + DOM metrics of the live site via headless Chrome (CDP, no deps).
// Ads/analytics are blocked on purpose: automated impressions would be invalid traffic on our own AdSense account.
// Usage: node audit/mobile/audit.mjs [--ads]   (writes shots/*.jpg and metrics.json next to this file)
import { spawn } from "node:child_process";
import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const OUT = dirname(fileURLToPath(import.meta.url));
const SHOTS = join(OUT, "shots");
mkdirSync(SHOTS, { recursive: true });

const BASE = "https://www.howtoedibles.com";
const PAGES = {
  home: "/",
  "recipe-photo": "/recipes/cannabutter/",
  "recipe-placeholder": "/recipes/pot-brownies/",
  calculator: "/calculator.html",
  article: "/how-long-do-edibles-take-to-kick-in.html",
};
// --ads: a single ads-on pass (en home + one recipe, 390 light) to see what Auto ads inject. Keep it to a handful of loads.
const ADS = process.argv.includes("--ads");
if (ADS) for (const k of ["recipe-photo", "calculator", "article"]) delete PAGES[k];
const LANGS = ADS ? ["en"] : ["en", "de", "zh"];
const WIDTHS = ADS ? [390] : [360, 390, 430];
const THEMES = ADS ? ["light"] : ["light", "dark"];
const UA = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1";
const ANALYTICS = ["*googletagmanager.com*", "*google-analytics.com*"];
const BLOCK = ADS ? ANALYTICS : [...ANALYTICS, "*googlesyndication.com*", "*doubleclick.net*", "*adservice.google*", "*fundingchoicesmessages*"];
const SUFFIX = ADS ? "-ads" : "";

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const PORT = 9333;
const chrome = spawn("/Applications/Google Chrome.app/Contents/MacOS/Google Chrome", [
  "--headless=new", `--remote-debugging-port=${PORT}`, `--user-data-dir=/tmp/hte-audit-chrome`, "--no-first-run", "--hide-scrollbars",
], { stdio: "ignore" });

async function waitForChrome() {
  for (let i = 0; i < 50; i++) {
    try { return await (await fetch(`http://127.0.0.1:${PORT}/json/version`)).json(); } catch { await sleep(200); }
  }
  throw new Error("chrome did not start");
}

function connect(wsUrl) {
  const ws = new WebSocket(wsUrl);
  let id = 0;
  const pending = new Map();
  const listeners = [];
  ws.onmessage = (e) => {
    const msg = JSON.parse(e.data);
    if (msg.id && pending.has(msg.id)) {
      const { resolve, reject } = pending.get(msg.id);
      pending.delete(msg.id);
      msg.error ? reject(new Error(msg.error.message)) : resolve(msg.result);
    } else listeners.forEach((l) => l(msg));
  };
  const send = (method, params = {}) => new Promise((resolve, reject) => {
    pending.set(++id, { resolve, reject });
    ws.send(JSON.stringify({ id, method, params }));
  });
  const once = (method) => new Promise((resolve) => listeners.push((m) => m.method === method && resolve(m.params)));
  return new Promise((r) => (ws.onopen = () => r({ send, once, close: () => ws.close() })));
}

// Runs inside the page; returns the facts the design tickets need.
const PROBE = `(() => {
  const vw = window.innerWidth;
  const css = (el) => el.tagName.toLowerCase() + (el.id ? '#' + el.id : '') + (el.classList.length ? '.' + [...el.classList].slice(0, 3).join('.') : '');
  const path = (el) => { const p = []; for (let e = el; e && e !== document.body && p.length < 4; e = e.parentElement) p.unshift(css(e)); return p.join(' > '); };
  const visible = (el) => { const r = el.getBoundingClientRect(); const s = getComputedStyle(el); return r.width > 0 && r.height > 0 && s.visibility !== 'hidden' && s.display !== 'none'; };
  const all = [...document.body.querySelectorAll('*')];

  // Elements that stick out past the viewport while their parent does not: the root of horizontal overflow.
  const overflowRoots = all.filter((el) => {
    if (!visible(el)) return false;
    const r = el.getBoundingClientRect();
    if (r.right <= vw + 1) return false;
    const p = el.parentElement && el.parentElement.getBoundingClientRect();
    return !p || p.right <= vw + 1;
  }).slice(0, 12).map((el) => { const s = getComputedStyle(el); const r = el.getBoundingClientRect();
    return { el: path(el), right: Math.round(r.right), width: Math.round(r.width), cssWidth: s.width, minWidth: s.minWidth, whiteSpace: s.whiteSpace, position: s.position }; });

  const taps = [...document.querySelectorAll('a, button, input, select, textarea, [role=button], summary')].filter(visible);
  const smallTaps = taps.filter((el) => { const r = el.getBoundingClientRect(); return r.height < 44 || r.width < 44; });
  const textEls = all.filter((el) => visible(el) && [...el.childNodes].some((n) => n.nodeType === 3 && n.textContent.trim().length > 1));
  const tiny = textEls.filter((el) => parseFloat(getComputedStyle(el).fontSize) < 12);
  const small = textEls.filter((el) => parseFloat(getComputedStyle(el).fontSize) < 16);
  const imgs = [...document.images].filter(visible).map((img) => { const r = img.getBoundingClientRect();
    return { src: img.currentSrc.replace(location.origin, ''), natural: img.naturalWidth + 'x' + img.naturalHeight, rendered: Math.round(r.width) + 'x' + Math.round(r.height), broken: img.complete && img.naturalWidth === 0, lazy: img.loading, top: Math.round(r.top + scrollY) }; });
  const fold = window.innerHeight;
  const firstContent = document.querySelector('h1');
  return {
    viewport: vw, docWidth: document.documentElement.scrollWidth, overflowPx: document.documentElement.scrollWidth - vw,
    pageHeight: document.documentElement.scrollHeight, screens: +(document.documentElement.scrollHeight / fold).toFixed(1),
    h1Top: firstContent ? Math.round(firstContent.getBoundingClientRect().top + scrollY) : null,
    h1Text: firstContent ? firstContent.textContent.trim().slice(0, 80) : null,
    navLinks: document.querySelectorAll('nav a, .navbar a').length,
    paginationButtons: document.querySelectorAll('.pagination a, .pagination button, .page-link').length,
    adSlots: [...document.querySelectorAll('ins.adsbygoogle')].map((a) => ({ slot: a.dataset.adSlot, format: a.dataset.adFormat, top: Math.round(a.getBoundingClientRect().top + scrollY), reservedHeight: Math.round(a.getBoundingClientRect().height) })),
    bodyFont: getComputedStyle(document.body).fontSize + ' ' + getComputedStyle(document.body).fontFamily.slice(0, 60),
    tapTargets: taps.length, smallTapTargets: smallTaps.length,
    smallTapSamples: [...new Set(smallTaps.map((el) => { const r = el.getBoundingClientRect(); return path(el) + ' [' + Math.round(r.width) + 'x' + Math.round(r.height) + ']'; }))].slice(0, 15),
    textElements: textEls.length, under12px: tiny.length, under16px: small.length,
    tinySamples: [...new Set(tiny.map((el) => path(el) + ' ' + getComputedStyle(el).fontSize))].slice(0, 10),
    images: imgs.slice(0, 20), brokenImages: imgs.filter((i) => i.broken).length,
    overflowRoots,
  };
})()`;

async function audit(browserWs, url, width, theme) {
  const target = await (await fetch(`http://127.0.0.1:${PORT}/json/new?about:blank`, { method: "PUT" })).json();
  const t = await connect(target.webSocketDebuggerUrl);
  await t.send("Page.enable");
  await t.send("Network.enable");
  await t.send("Network.setBlockedURLs", { urls: BLOCK });
  await t.send("Network.setUserAgentOverride", { userAgent: UA, platform: "iPhone" });
  await t.send("Emulation.setDeviceMetricsOverride", { width, height: 800, deviceScaleFactor: 2, mobile: true });
  await t.send("Emulation.setTouchEmulationEnabled", { enabled: true, maxTouchPoints: 5 });
  await t.send("Page.addScriptToEvaluateOnNewDocument", { source: `try{localStorage.setItem('theme','${theme}')}catch(e){}` });
  const loaded = t.once("Page.loadEventFired");
  await t.send("Page.navigate", { url });
  await Promise.race([loaded, sleep(20000)]);
  await sleep(ADS ? 10000 : 1500); // fonts, lazy images, client-side pagination (+ Auto ads injection)
  const { result } = await t.send("Runtime.evaluate", { expression: PROBE, returnByValue: true });
  // Full-page capture at the layout width the page actually produced (shows overflow instead of hiding it).
  const { cssContentSize } = await t.send("Page.getLayoutMetrics");
  const shot = await t.send("Page.captureScreenshot", {
    format: "jpeg", quality: 55, captureBeyondViewport: true,
    clip: { x: 0, y: 0, width: Math.max(width, cssContentSize.width), height: Math.min(cssContentSize.height, 16000), scale: 1 },
  });
  t.close();
  await fetch(`http://127.0.0.1:${PORT}/json/close/${target.id}`);
  return { metrics: result.value, jpeg: Buffer.from(shot.data, "base64") };
}

const version = await waitForChrome();
const results = [];
for (const lang of LANGS) {
  for (const [page, path] of Object.entries(PAGES)) {
    const url = BASE + (lang === "en" ? "" : "/" + lang) + path;
    for (const width of WIDTHS) {
      for (const theme of THEMES) {
        const name = `${lang}-${page}-${width}-${theme}${SUFFIX}`;
        try {
          const { metrics, jpeg } = await audit(version.webSocketDebuggerUrl, url, width, theme);
          writeFileSync(join(SHOTS, name + ".jpg"), jpeg);
          results.push({ name, lang, page, width, theme, url, ...metrics });
          console.log(name, "overflow", metrics.overflowPx, "smallTaps", metrics.smallTapTargets, "screens", metrics.screens);
        } catch (e) {
          console.log(name, "FAILED", e.message);
          results.push({ name, url, error: e.message });
        }
      }
    }
  }
}
writeFileSync(join(OUT, `metrics${SUFFIX}.json`), JSON.stringify(results, null, 2));
chrome.kill();
