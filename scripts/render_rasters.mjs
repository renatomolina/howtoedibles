// Render the og/schema rasters with headless Google Chrome over CDP (no npm deps).
// Decided in "What is the performance budget for the new pages?" (#63 §5).
//
// build_site.rb writes one small HTML per raster (real cover markup, inline sprite,
// /css/site.css, the self-hosted font) plus tmp/rasters/jobs.json:
//   [{ "out": "og/en/pot-brownies.png", "html": "tmp/rasters/og/en/pot-brownies.html", "width": 1200, "height": 630 }, …]
// This script screenshots every job whose inputs changed, in one browser.
// Incremental: data/rasters-manifest.json maps out → sha256(html + every local file it references).
// Outputs are committed (GitHub Pages has no build).
//
// Run: node scripts/render_rasters.mjs [--force]
import { spawn } from "node:child_process";
import { createHash } from "node:crypto";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { createServer } from "node:http";
import { dirname, extname, join, normalize } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const JOBS = join(ROOT, "tmp/rasters/jobs.json");
const MANIFEST = join(ROOT, "data/rasters-manifest.json");
const CHROME = process.env.CHROME || "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const force = process.argv.includes("--force");
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

if (!existsSync(JOBS)) { console.log("render_rasters: no tmp/rasters/jobs.json, nothing to render"); process.exit(0); }
const jobs = JSON.parse(readFileSync(JOBS, "utf8"));
const manifest = existsSync(MANIFEST) ? JSON.parse(readFileSync(MANIFEST, "utf8")) : {};

// Hash the page plus the root-relative files it pulls in (site.css, and the font via its url()).
const refs = (text, re) => [...text.matchAll(re)].map((m) => m[1]).sort();
const hashOf = (job) => {
  const html = readFileSync(join(ROOT, job.html), "utf8");
  const h = createHash("sha256").update(html).update(`${job.width}x${job.height}`);
  const add = (url) => {
    const f = join(ROOT, url);
    if (!existsSync(f)) return;
    const bytes = readFileSync(f);
    h.update(bytes);
    if (f.endsWith(".css")) refs(bytes.toString(), /url\(["']?(\/[^"')#?]+)/g).forEach(add);
  };
  refs(html, /(?:href|src)=["'](\/[^"'#?]+)/g).forEach(add);
  return h.digest("hex");
};

const todo = jobs.map((j) => ({ ...j, hash: hashOf(j) }))
  .filter((j) => force || manifest[j.out] !== j.hash || !existsSync(join(ROOT, j.out)));
const live = new Set(jobs.map((j) => j.out));
for (const out of Object.keys(manifest)) if (!live.has(out)) delete manifest[out];
console.log(`render_rasters: ${todo.length} of ${jobs.length} to render`);

if (todo.length) {
  // Static server over the repo, so pages use the same root-relative URLs as the site.
  const TYPES = { ".html": "text/html", ".css": "text/css", ".woff2": "font/woff2", ".svg": "image/svg+xml", ".png": "image/png", ".jpg": "image/jpeg" };
  const server = createServer((req, res) => {
    const f = join(ROOT, normalize(decodeURIComponent(new URL(req.url, "http://x").pathname)));
    if (!f.startsWith(ROOT) || !existsSync(f)) { res.writeHead(404).end(); return; }
    res.writeHead(200, { "content-type": TYPES[extname(f)] || "application/octet-stream" }).end(readFileSync(f));
  }).listen(0, "127.0.0.1");
  await new Promise((r) => server.once("listening", r));
  const base = `http://127.0.0.1:${server.address().port}`;

  const PORT = 9337, profile = join(ROOT, "tmp/rasters/chrome-profile");
  const chrome = spawn(CHROME, ["--headless=new", `--remote-debugging-port=${PORT}`, `--user-data-dir=${profile}`, "--no-first-run", "--hide-scrollbars", "--force-color-profile=srgb"], { stdio: "ignore" });
  let up = false;
  for (let i = 0; i < 50 && !up; i++) { try { await fetch(`http://127.0.0.1:${PORT}/json/version`); up = true; } catch { await sleep(200); } }
  if (!up) throw new Error(`Chrome didn't start (${CHROME}); set CHROME=/path/to/chrome`);

  const target = await (await fetch(`http://127.0.0.1:${PORT}/json/new?about:blank`, { method: "PUT" })).json();
  const ws = new WebSocket(target.webSocketDebuggerUrl);
  await new Promise((r) => (ws.onopen = r));
  let id = 0; const pend = new Map(), listeners = new Set();
  ws.onmessage = (e) => {
    const m = JSON.parse(e.data);
    if (m.id && pend.has(m.id)) { const [ok, ko] = pend.get(m.id); pend.delete(m.id); m.error ? ko(new Error(m.error.message)) : ok(m.result); }
    else listeners.forEach((f) => f(m));
  };
  const send = (method, params = {}) => new Promise((ok, ko) => { pend.set(++id, [ok, ko]); ws.send(JSON.stringify({ id, method, params })); });
  await send("Page.enable"); await send("Runtime.enable");
  listeners.add((m) => m.method === "Runtime.exceptionThrown" && console.log("  JS error:", m.params.exceptionDetails.exception?.description));

  try {
    for (const job of todo) {
      await send("Emulation.setDeviceMetricsOverride", { width: job.width, height: job.height, deviceScaleFactor: 1, mobile: false });
      const loaded = new Promise((r) => { const f = (m) => m.method === "Page.loadEventFired" && (listeners.delete(f), r()); listeners.add(f); });
      await send("Page.navigate", { url: `${base}/${job.html}` });
      await loaded;
      const fontsOk = (await send("Runtime.evaluate", { awaitPromise: true, returnByValue: true,
        expression: "document.fonts.ready.then(() => [...document.fonts].every((f) => f.status !== 'error'))" })).result.value;
      if (!fontsOk) throw new Error(`${job.html}: a font failed to load`);
      const shot = await send("Page.captureScreenshot", { format: "png", clip: { x: 0, y: 0, width: job.width, height: job.height, scale: 1 } });
      mkdirSync(dirname(join(ROOT, job.out)), { recursive: true });
      writeFileSync(join(ROOT, job.out), Buffer.from(shot.data, "base64"));
      manifest[job.out] = job.hash;
    }
  } finally {
    saveManifest(); // even on failure, so a re-run picks up where it stopped
    ws.close(); chrome.kill(); server.close(); // the profile stays in tmp/ (gitignored) and is reused
  }
}
saveManifest();
console.log("render_rasters: done");

function saveManifest() {
  writeFileSync(MANIFEST, JSON.stringify(Object.fromEntries(Object.entries(manifest).sort()), null, 2) + "\n");
}
