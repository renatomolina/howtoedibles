// Gate: behaviour of the new recipe page and shell in headless Chrome (exit 1 on any failure).
// Steppers, chips, typed locale decimals, reset, ?quantity=&potency=&portion=, the menu/search dialogs
// closing on Back, the dialog switch keeping one history entry, and the theme key (Auto removes it).
// Usage: python3 -m http.server 8781 (repo root) & node scripts/qa/interact.mjs
import { spawn } from "node:child_process";
const BASE = process.env.BASE || "http://127.0.0.1:8781", PORT = 9351, sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const chrome = spawn("/Applications/Google Chrome.app/Contents/MacOS/Google Chrome", ["--headless=new", `--remote-debugging-port=${PORT}`, "--user-data-dir=/tmp/hte-qa-interact", "--no-first-run"], { stdio: "ignore" });
for (let i = 0; i < 50; i++) { try { await fetch(`http://127.0.0.1:${PORT}/json/version`); break; } catch { await sleep(200); } }
const target = await (await fetch(`http://127.0.0.1:${PORT}/json/new?about:blank`, { method: "PUT" })).json();
const ws = new WebSocket(target.webSocketDebuggerUrl);
await new Promise((r) => (ws.onopen = r));
let id = 0; const pend = new Map(), evs = [], errs = [];
ws.onmessage = (e) => { const m = JSON.parse(e.data); if (m.id && pend.has(m.id)) { pend.get(m.id)(m.result); pend.delete(m.id); } else evs.forEach((f) => f(m)); };
const send = (method, params = {}) => new Promise((r) => { pend.set(++id, r); ws.send(JSON.stringify({ id, method, params })); });
await send("Page.enable"); await send("Runtime.enable"); await send("Network.enable"); await send("Network.setCacheDisabled", { cacheDisabled: true });
evs.push((m) => m.method === "Runtime.exceptionThrown" && errs.push(m.params.exceptionDetails.exception?.description?.split("\n")[0]));
await send("Emulation.setDeviceMetricsOverride", { width: 390, height: 664, deviceScaleFactor: 1, mobile: true });
const go = async (path) => { const l = new Promise((r) => { const f = (m) => m.method === "Page.loadEventFired" && (evs.splice(evs.indexOf(f), 1), r()); evs.push(f); }); await send("Page.navigate", { url: BASE + path }); await l; await sleep(300); };
const ev = async (expr) => (await send("Runtime.evaluate", { expression: `(async () => { ${expr} })()`, awaitPromise: true, returnByValue: true })).result?.value;
let fails = 0;
const expect = (name, got, want) => { const ok = JSON.stringify(got) === JSON.stringify(want); if (!ok) fails++; console.log(`${ok ? "✓" : "✗"} ${name}${ok ? "" : ` — got ${JSON.stringify(got)}, want ${JSON.stringify(want)}`}`); };
const read = `const q = (s) => document.querySelector(s).textContent.replace(/\\s+/g, " ").trim(); return { sticker: q("[data-o=mgs]"), batch: q("[data-o=batch]"), n: q("[data-o=n]"), adj: q("[data-o=adj]"), g: document.getElementById("in-g").value, reset: !document.querySelector("[data-reset]").hidden, edited: document.getElementById("sticker").classList.contains("edited") };`;

// pot-brownies: 2.1 g · 14% · 16 servings → 14.7 mg (shows 15), 235 mg batch
await go("/recipes/pot-brownies/");
expect("static defaults", await ev(read), { sticker: "15mg", batch: "235 mg", n: "16", adj: "2.1 g · 14% THC", g: "2.1", reset: false, edited: false });
expect("static panel equals dose.js render", await ev("return window.DOSE.check()"), true);
await ev(`document.querySelector('[data-step=g][data-d="1"]').click()`); // 2.1 → 2.5 (snaps to the 0.5 grid)
expect("+ grams snaps to 0.5", await ev(read), { sticker: "18mg", batch: "280 mg", n: "16", adj: "2.5 g · 14% THC", g: "2.5", reset: true, edited: true });
await ev(`document.querySelector('.chip[data-k=n][data-v="50"]').click()`);
expect("servings chip 50", await ev(read), { sticker: "5.6mg", batch: "280 mg", n: "50", adj: "2.5 g · 14% THC", g: "2.5", reset: true, edited: true });
await ev(`document.querySelector("[data-reset]").click()`);
expect("reset", await ev(read), { sticker: "15mg", batch: "235 mg", n: "16", adj: "2.1 g · 14% THC", g: "2.1", reset: false, edited: false });

// de: typing "3,5" with a decimal comma, live on input (no blur)
await go("/de/recipes/pot-brownies/");
await ev(`const i = document.getElementById("in-g"); i.focus(); i.value = "3,5"; i.dispatchEvent(new Event("input", { bubbles: true }));`);
expect("de typed 3,5 g", await ev(read), { sticker: "25mg", batch: "392 mg", n: "16", adj: "3,5 g · 14 % THC", g: "3,5", reset: true, edited: true });

// URL params still pre-fill the calculator
await go("/recipes/pot-brownies/?quantity=7&potency=20&portion=10");
expect("?quantity=7&potency=20&portion=10", await ev(read), { sticker: "112mg", batch: "1,120 mg", n: "10", adj: "7 g · 20% THC", g: "7", reset: true, edited: true });

// dialogs: Back closes; switching menu → search keeps one history entry
await go("/recipes/pot-brownies/");
const h0 = await ev("return history.length");
await ev(`document.querySelector(".hdr [data-open=menu]").click()`);
expect("menu opens", await ev(`return document.getElementById("menu").open && document.body.classList.contains("locked")`), true);
await ev(`document.querySelector("#menu [data-open=search]").click()`);
expect("menu → search switch", await ev(`return [document.getElementById("menu").open, document.getElementById("search").open, history.length]`), [false, true, h0 + 1]);
await ev("history.back(); await new Promise((r) => setTimeout(r, 300));");
expect("Back closes the dialog", await ev(`return [document.querySelector("dialog[open]") === null, document.body.classList.contains("locked"), location.pathname]`), [true, false, "/recipes/pot-brownies/"]);
await ev(`document.querySelector(".hdr [data-open=search]").click(); await new Promise((r) => setTimeout(r, 200)); document.querySelector("#search [data-close]").click(); await new Promise((r) => setTimeout(r, 300));`);
expect("Cancel closes and pops its history entry", await ev(`return [document.querySelector("dialog[open]") === null, history.state]`), [true, null]);

// theme: Dark persists "dark"; Auto removes the key (never writes "auto")
await ev(`document.querySelector("[data-theme-set=dark]").click()`);
expect("Dark", await ev(`return [document.documentElement.dataset.theme, localStorage.getItem("theme")]`), ["dark", "dark"]);
await ev(`document.querySelector("[data-theme-set=auto]").click()`);
expect("Auto removes the key", await ev(`return localStorage.getItem("theme")`), null);

expect("no JS errors", errs, []);
ws.close(); chrome.kill();
process.exit(fails ? 1 : 0);
