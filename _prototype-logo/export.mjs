// Pull the laid-out logo SVGs (window.__export) out of headless Chrome into a JSON file. CDP, no deps.
// Usage: node _prototype-logo/export.mjs <out.json>   (needs `python3 -m http.server 8768` at repo root)
import { spawn } from "node:child_process";
import { writeFileSync } from "node:fs";
const PORT = 9338, sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const chrome = spawn("/Applications/Google Chrome.app/Contents/MacOS/Google Chrome", ["--headless=new", `--remote-debugging-port=${PORT}`, "--user-data-dir=/tmp/hte-proto-chrome-logo-export", "--no-first-run"], { stdio: "ignore" });
for (let i = 0; i < 50; i++) { try { await fetch(`http://127.0.0.1:${PORT}/json/version`); break; } catch { await sleep(200); } }
const target = await (await fetch(`http://127.0.0.1:${PORT}/json/new?about:blank`, { method: "PUT" })).json();
const ws = new WebSocket(target.webSocketDebuggerUrl);
await new Promise((r) => (ws.onopen = r));
let id = 0; const pend = new Map();
ws.onmessage = (e) => { const m = JSON.parse(e.data); if (m.id && pend.has(m.id)) { pend.get(m.id)(m.result); pend.delete(m.id); } };
const send = (method, params = {}) => new Promise((r) => { pend.set(++id, r); ws.send(JSON.stringify({ id, method, params })); });
await send("Page.enable");
await send("Page.navigate", { url: "http://127.0.0.1:8768/_prototype-logo/?export=1" });
let out;
for (let i = 0; i < 60 && !out; i++) { await sleep(250); out = (await send("Runtime.evaluate", { returnByValue: true, expression: "window.__export && JSON.stringify(window.__export)" })).result.value; }
if (!out) throw new Error("window.__export never appeared");
writeFileSync(process.argv[2], out);
console.log(Object.keys(JSON.parse(out)).join(", "));
ws.close(); chrome.kill();
