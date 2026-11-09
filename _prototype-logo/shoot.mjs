// PROTOTYPE helper: mobile-emulated screenshots + the page's own measurements (window.__m). CDP, no deps.
// Usage: node _prototype-logo/shoot.mjs <outdir> <query> [<query>...]   (needs `python3 -m http.server 8768` at repo root)
// Query extras read here: vw=, vh= (viewport), full=1 (whole page). With scroll= the page scrolls itself and the viewport is captured.
import { spawn } from "node:child_process";
import { mkdirSync, writeFileSync } from "node:fs";
const [out, ...queries] = process.argv.slice(2);
mkdirSync(out, { recursive: true });
const PORT = 9337, sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const chrome = spawn("/Applications/Google Chrome.app/Contents/MacOS/Google Chrome", ["--headless=new", `--remote-debugging-port=${PORT}`, "--user-data-dir=/tmp/hte-proto-chrome-logo", "--no-first-run", "--hide-scrollbars"], { stdio: "ignore" });
for (let i = 0; i < 50; i++) { try { await fetch(`http://127.0.0.1:${PORT}/json/version`); break; } catch { await sleep(200); } }
for (const q of queries) {
  const full = q.includes("full=1"), VW = +(/vw=(\d+)/.exec(q)?.[1] || 390), VH = +(/vh=(\d+)/.exec(q)?.[1] || 664);
  const target = await (await fetch(`http://127.0.0.1:${PORT}/json/new?about:blank`, { method: "PUT" })).json();
  const ws = new WebSocket(target.webSocketDebuggerUrl);
  await new Promise((r) => (ws.onopen = r));
  let id = 0; const pend = new Map(), evs = [];
  ws.onmessage = (e) => { const m = JSON.parse(e.data); if (m.id && pend.has(m.id)) { pend.get(m.id)(m.result); pend.delete(m.id); } else evs.forEach((f) => f(m)); };
  const send = (method, params = {}) => new Promise((r) => { pend.set(++id, r); ws.send(JSON.stringify({ id, method, params })); });
  await send("Page.enable"); await send("Network.enable"); await send("Network.setCacheDisabled", { cacheDisabled: true });
  await send("Emulation.setDeviceMetricsOverride", { width: VW, height: VH, deviceScaleFactor: 2, mobile: VW < 640 });
  await send("Emulation.setTouchEmulationEnabled", { enabled: VW < 1000 });
  await send("Emulation.setEmulatedMedia", { features: [{ name: "prefers-reduced-motion", value: "reduce" }] });
  const loaded = new Promise((r) => evs.push((m) => m.method === "Page.loadEventFired" && r()));
  await send("Page.navigate", { url: `http://127.0.0.1:8768/_prototype-logo/?shot=1&${q}` });
  await loaded; await sleep(2500);
  const m = await send("Runtime.evaluate", { returnByValue: true, expression: `JSON.stringify(window.__m)+' docW '+document.documentElement.scrollWidth+' wider: '+[...document.querySelectorAll('body *')].filter(e=>!e.closest('#bar,.chips,.cv,svg')&&e.getBoundingClientRect().right>${VW}+0.5).slice(0,8).map(e=>e.tagName+'.'+(e.className.baseVal??e.className)+' r='+Math.round(e.getBoundingClientRect().right)+' «'+(e.textContent||'').trim().slice(0,24)+'»').join(' | ')` });
  const { cssContentSize } = await send("Page.getLayoutMetrics");
  const h = full ? Math.min(cssContentSize.height, 14000) : VH;
  const shot = await send("Page.captureScreenshot", full ? { format: "jpeg", quality: 70, captureBeyondViewport: true, clip: { x: 0, y: 0, width: VW, height: h, scale: 1 } } : { format: "jpeg", quality: 72 });
  writeFileSync(`${out}/${q.replace(/[&=\/]/g, "_")}.jpg`, Buffer.from(shot.data, "base64"));
  console.log(q, "→", m.result.value);
  ws.close(); await fetch(`http://127.0.0.1:${PORT}/json/close/${target.id}`);
}
chrome.kill();
