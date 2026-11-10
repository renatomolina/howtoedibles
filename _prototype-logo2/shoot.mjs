// Local QA helper: screenshots of generated pages. node tmp/p2/shoot.mjs <outdir> "<path>|vw|vh|full|theme" ...
import { spawn } from "node:child_process";
import { mkdirSync, writeFileSync } from "node:fs";
const [out, ...jobs] = process.argv.slice(2);
mkdirSync(out, { recursive: true });
const PORT = 9361, sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const chrome = spawn("/Applications/Google Chrome.app/Contents/MacOS/Google Chrome", ["--headless=new", `--remote-debugging-port=${PORT}`, "--user-data-dir=/tmp/hte-logo2-shoot", "--no-first-run", "--hide-scrollbars"], { stdio: "ignore" });
for (let i = 0; i < 50; i++) { try { await fetch(`http://127.0.0.1:${PORT}/json/version`); break; } catch { await sleep(200); } }
for (const j of jobs) {
  const [path, vw = "390", vh = "664", full = "0", theme = "light"] = j.split("|"), VW = +vw, VH = +vh;
  const target = await (await fetch(`http://127.0.0.1:${PORT}/json/new?about:blank`, { method: "PUT" })).json();
  const ws = new WebSocket(target.webSocketDebuggerUrl);
  await new Promise((r) => (ws.onopen = r));
  let id = 0; const pend = new Map(), evs = [], errs = [];
  ws.onmessage = (e) => { const m = JSON.parse(e.data); if (m.id && pend.has(m.id)) { pend.get(m.id)(m.result); pend.delete(m.id); } else evs.forEach((f) => f(m)); };
  const send = (method, params = {}) => new Promise((r) => { pend.set(++id, r); ws.send(JSON.stringify({ id, method, params })); });
  await send("Page.enable"); await send("Runtime.enable"); await send("Network.enable"); await send("Network.setCacheDisabled", { cacheDisabled: true });
  evs.push((m) => m.method === "Runtime.exceptionThrown" && errs.push(m.params.exceptionDetails.exception?.description?.split("\n")[0]));
  await send("Emulation.setDeviceMetricsOverride", { width: VW, height: VH, deviceScaleFactor: 1, mobile: VW < 1000 });
  await send("Emulation.setEmulatedMedia", { features: [{ name: "prefers-color-scheme", value: theme }] });
  const loaded = new Promise((r) => evs.push((m) => m.method === "Page.loadEventFired" && r()));
  await send("Page.navigate", { url: `http://127.0.0.1:${process.env.PORT || 8781}${path}` });
  await loaded; await sleep(1200);
  const { cssContentSize } = await send("Page.getLayoutMetrics");
  const h = full === "1" ? Math.min(cssContentSize.height, 16000) : VH;
  const shot = await send("Page.captureScreenshot", full === "1" ? { format: "jpeg", quality: 60, captureBeyondViewport: true, clip: { x: 0, y: 0, width: VW, height: h, scale: 1 } } : { format: "jpeg", quality: 70 });
  const name = `${path.replace(/[^a-z0-9]+/gi, "_")}_${VW}${full === "1" ? "_full" : ""}_${theme}.jpg`;
  writeFileSync(`${out}/${name}`, Buffer.from(shot.data, "base64"));
  const w = await send("Runtime.evaluate", { returnByValue: true, expression: "document.documentElement.scrollWidth" });
  console.log(name, "docW", w.result.value, errs.length ? "ERR " + errs.join(" | ") : "");
  ws.close(); await fetch(`http://127.0.0.1:${PORT}/json/close/${target.id}`);
}
chrome.kill();
