// PROTOTYPE helper: screenshots + overflow check over CDP (no deps). Needs `python3 -m http.server 8769` at repo root.
// Usage: node _prototype-colours/shoot.mjs <outdir> "<name>|<vw>x<vh>|<query>[|full]" ...
import { spawn } from "node:child_process";
import { mkdirSync, writeFileSync } from "node:fs";
const [out, ...jobs] = process.argv.slice(2);
mkdirSync(out, { recursive: true });
const PORT = 9336, sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const chrome = spawn("/Applications/Google Chrome.app/Contents/MacOS/Google Chrome", ["--headless=new", `--remote-debugging-port=${PORT}`, "--user-data-dir=/tmp/hte-proto-colours", "--no-first-run", "--hide-scrollbars"], { stdio: "ignore" });
for (let i = 0; i < 50; i++) { try { await fetch(`http://127.0.0.1:${PORT}/json/version`); break; } catch { await sleep(200); } }
let problems = 0;
for (const job of jobs) {
  const [name, size, q, full] = job.split("|"), [VW, VH] = size.split("x").map(Number);
  const target = await (await fetch(`http://127.0.0.1:${PORT}/json/new?about:blank`, { method: "PUT" })).json();
  const ws = new WebSocket(target.webSocketDebuggerUrl);
  await new Promise((r) => (ws.onopen = r));
  let id = 0; const pend = new Map(), evs = [];
  ws.onmessage = (e) => { const m = JSON.parse(e.data); if (m.id && pend.has(m.id)) { pend.get(m.id)(m.result); pend.delete(m.id); } else evs.forEach((f) => f(m)); };
  const send = (method, params = {}) => new Promise((r) => { pend.set(++id, r); ws.send(JSON.stringify({ id, method, params })); });
  await send("Page.enable"); await send("Runtime.enable");
  await send("Emulation.setDeviceMetricsOverride", { width: VW, height: VH, deviceScaleFactor: 2, mobile: VW < 1000 });
  const loaded = new Promise((r) => evs.push((m) => m.method === "Page.loadEventFired" && r()));
  evs.push((m) => m.method === "Runtime.exceptionThrown" && console.log("  JS error:", m.params.exceptionDetails.exception?.description));
  await send("Page.navigate", { url: `http://127.0.0.1:8769/_prototype-colours/?shot=1&${q}` });
  await loaded;
  await send("Runtime.evaluate", { awaitPromise: true, expression: "document.fonts.ready.then(()=>new Promise(r=>setTimeout(r,800)))" });
  const probe = (await send("Runtime.evaluate", { returnByValue: true, expression: `(()=>{const W=innerWidth,o=[];if(document.documentElement.scrollWidth>W)o.push('page '+document.documentElement.scrollWidth+'>'+W);for(const e of document.querySelectorAll('.tile b,.card .nm,.chips a,.lead b,.band h3,.hero h3,.sw td,.crumb,.back'))if(e.scrollWidth>e.clientWidth+1&&getComputedStyle(e).overflow!=='hidden')o.push(e.className+' «'+e.textContent.trim().slice(0,24)+'»');return o.join(' | ')})()` })).result.value;
  if (probe) { problems++; console.log("  PROBLEM", name, probe); }
  const { cssContentSize } = await send("Page.getLayoutMetrics");
  const h = full ? Math.min(cssContentSize.height, 16000) : VH;
  const shot = await send("Page.captureScreenshot", { format: "jpeg", quality: 72, captureBeyondViewport: !!full, clip: { x: 0, y: 0, width: VW, height: h, scale: full ? 1 : 2 } });
  writeFileSync(`${out}/${name}.jpg`, Buffer.from(shot.data, "base64"));
  console.log(name, `${VW}x${VH}`, "height", Math.round(cssContentSize.height));
  ws.close(); await fetch(`http://127.0.0.1:${PORT}/json/close/${target.id}`);
}
chrome.kill();
console.log(problems ? `${problems} with problems` : "0 problems");
