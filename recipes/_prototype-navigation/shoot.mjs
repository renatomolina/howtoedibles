// PROTOTYPE helper: mobile-emulated screenshots of the prototype (CDP, no deps).
// Usage: node recipes/_prototype-navigation/shoot.mjs <outdir> <query> [<query>...]   (needs a server on :8765 at repo root)
import { spawn } from "node:child_process";
import { mkdirSync, writeFileSync } from "node:fs";
const [out, ...queries] = process.argv.slice(2);
mkdirSync(out, { recursive: true });
const PORT = 9334, sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const chrome = spawn("/Applications/Google Chrome.app/Contents/MacOS/Google Chrome", ["--headless=new", `--remote-debugging-port=${PORT}`, "--user-data-dir=/tmp/hte-proto-chrome", "--no-first-run", "--hide-scrollbars"], { stdio: "ignore" });
for (let i = 0; i < 50; i++) { try { await fetch(`http://127.0.0.1:${PORT}/json/version`); break; } catch { await sleep(200); } }
for (const q of queries) {
  const full = q.includes("full=1");
  const target = await (await fetch(`http://127.0.0.1:${PORT}/json/new?about:blank`, { method: "PUT" })).json();
  const ws = new WebSocket(target.webSocketDebuggerUrl);
  await new Promise((r) => (ws.onopen = r));
  let id = 0; const pend = new Map(), evs = [];
  ws.onmessage = (e) => { const m = JSON.parse(e.data); if (m.id && pend.has(m.id)) { pend.get(m.id)(m.result); pend.delete(m.id); } else evs.forEach((f) => f(m)); };
  const send = (method, params = {}) => new Promise((r) => { pend.set(++id, r); ws.send(JSON.stringify({ id, method, params })); });
  await send("Page.enable");
  await send("Emulation.setDeviceMetricsOverride", { width: 390, height: 844, deviceScaleFactor: 2, mobile: true });
  await send("Emulation.setTouchEmulationEnabled", { enabled: true });
  await send("Emulation.setEmulatedMedia", { features: [{ name: "prefers-reduced-motion", value: "reduce" }] });
  const loaded = new Promise((r) => evs.push((m) => m.method === "Page.loadEventFired" && r()));
  await send("Page.navigate", { url: `http://127.0.0.1:8765/recipes/_prototype-navigation/?${q}` });
  await loaded; await sleep(3500);
  const probe = await send("Runtime.evaluate", { returnByValue: true, expression: `[document.documentElement.scrollWidth, innerWidth, ...[...document.querySelectorAll('main > *, main > section > *, footer, .hdr')].map(e=>{const o=e.style.display;e.style.display='none';const w=document.documentElement.scrollWidth;e.style.display=o;return w<document.documentElement.scrollWidth?e.tagName+'.'+e.className+'→'+w:''}).filter(Boolean)].join(' ')+' || '+[...document.querySelectorAll('body *')].filter(e=>e.getBoundingClientRect().right>391).slice(0,12).map(e=>e.tagName+'.'+e.className+' '+Math.round(e.getBoundingClientRect().right)+' in '+(e.parentElement.className.baseVal??e.parentElement.className)+' «'+(e.textContent||'').trim().slice(0,30)+'» '+e.parentElement.tagName).join(' | ')` });
  if (probe.result.value) console.log("  overflow:", probe.result.value);
  const { cssContentSize } = await send("Page.getLayoutMetrics");
  const h = full ? Math.min(cssContentSize.height, 12000) : 844;
  const shot = await send("Page.captureScreenshot", { format: "jpeg", quality: 70, captureBeyondViewport: full, clip: { x: 0, y: 0, width: 390, height: h, scale: full ? 1 : 2 } });
  writeFileSync(`${out}/${q.replace(/[&=]/g, "_")}.jpg`, Buffer.from(shot.data, "base64"));
  console.log(q, "docWidth", cssContentSize.width, "height", cssContentSize.height);
  ws.close(); await fetch(`http://127.0.0.1:${PORT}/json/close/${target.id}`);
}
chrome.kill();
