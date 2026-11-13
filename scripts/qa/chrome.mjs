// Headless Chrome for the browser gates (#133). Each gate runs its probes in several tabs at once, and the probes wait
// on setTimeout; with background-tab throttling on, every wait took ~1 s and the gates were mostly asleep. So:
// throttling off, AdSense/GA blocked (as lighthouse.sh does), and a 20 s timeout on every CDP call, so a lost reply
// fails the run instead of hanging it. Every run gets its own profile and a free port, so gates running in parallel
// sessions never share a Chrome (a fixed port made a second run talk to the first one's browser). CHROME=… points at
// another binary (Linux CI).
import { spawn } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync } from "node:fs";
export const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const BIN = process.env.CHROME || "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const BLOCK = ["*googlesyndication.com*", "*googletagmanager.com*", "*google-analytics.com*", "*doubleclick.net*"];

export async function chrome(name) {
  const dir = mkdtempSync(`/tmp/hte-qa-${name}-`);
  const proc = spawn(BIN, ["--headless=new", "--remote-debugging-port=0", `--user-data-dir=${dir}`, "--no-first-run", "--hide-scrollbars",
    "--disable-background-timer-throttling", "--disable-renderer-backgrounding", "--disable-backgrounding-occluded-windows"], { stdio: "ignore" });
  // also on a thrown timeout, so no stray Chrome is left behind
  process.on("exit", () => { proc.kill(); try { rmSync(dir, { recursive: true, force: true }); } catch {} });
  let port; // Chrome writes the port it picked into the profile
  for (let i = 0; i < 50 && !port; i++) { try { port = +readFileSync(`${dir}/DevToolsActivePort`, "utf8").split("\n")[0]; } catch { await sleep(200); } }
  if (!port) throw new Error(`Chrome didn't start (${BIN})`);
  return { tab: () => tab(port), kill: () => proc.kill() };
}

// A fresh tab: send(method, params) resolves with the CDP result; evs holds listeners for CDP events.
async function tab(port) {
  const target = await (await fetch(`http://127.0.0.1:${port}/json/new?about:blank`, { method: "PUT" })).json();
  const ws = new WebSocket(target.webSocketDebuggerUrl);
  await new Promise((r) => (ws.onopen = r));
  let id = 0; const pend = new Map(), evs = [];
  ws.onmessage = (e) => { const m = JSON.parse(e.data); if (m.id && pend.has(m.id)) { pend.get(m.id)(m.result); pend.delete(m.id); } else evs.forEach((f) => f(m)); };
  const send = (method, params = {}) => new Promise((r, j) => {
    const i = ++id, t = setTimeout(() => { pend.delete(i); j(new Error(`CDP ${method}: no reply in 20 s`)); }, 20000);
    pend.set(i, (v) => { clearTimeout(t); r(v); });
    ws.send(JSON.stringify({ id: i, method, params }));
  });
  await send("Page.enable"); await send("Runtime.enable"); await send("Network.enable");
  await send("Network.setCacheDisabled", { cacheDisabled: true }); await send("Network.setBlockedURLs", { urls: BLOCK });
  const close = async () => { ws.close(); await fetch(`http://127.0.0.1:${port}/json/close/${target.id}`); };
  return { send, evs, close };
}
