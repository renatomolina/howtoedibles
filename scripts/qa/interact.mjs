// Gate: behaviour of the new recipe page and shell in headless Chrome (exit 1 on any failure).
// Steppers, chips, typed locale decimals, reset, ?quantity=&potency=&portion=, the menu/search dialogs
// closing on Back, the dialog switch keeping one history entry, and the theme key (Auto removes it).
// Usage: python3 -I scripts/qa/serve.py 8781 (repo root) & node scripts/qa/interact.mjs
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

// ---- special pages (#74) ----
// calculator.html: 3.5 g · 14% · 50 = 7.8 mg (casual); the dose table row and the "with your numbers" line follow the card
const calcRead = `return { mg: document.querySelector("#live .mg").textContent.trim(), row: document.querySelector(".dt tr[aria-current]")?.dataset.lvl, you: document.querySelectorAll(".dt .you").length, eq: document.querySelector("[data-o=eq]").textContent, reset: !document.querySelector("[data-reset]").hidden };`;
await go("/calculator.html");
expect("calculator static defaults", await ev(calcRead), { mg: "7.8 mg", row: "2", you: 1, eq: "10 × 3.5 × 14 × 0.8 ÷ 50 = 7.8 mg", reset: false });
expect("calculator static panel equals dose.js render", await ev("return window.DOSE.check()"), true);
await ev(`document.querySelector('.chip[data-k=g][data-v="28"]').click()`);
expect("calculator 28 g → extreme row", await ev(calcRead), { mg: "63 mg", row: "5", you: 1, eq: "10 × 28 × 14 × 0.8 ÷ 50 = 63 mg", reset: true });
await go("/de/calculator.html");
expect("de calculator decimals", await ev(`return document.querySelector("[data-o=eq]").textContent`), "10 × 3,5 × 14 × 0,8 ÷ 50 = 7,8 mg");

// homepage: the hero card is live; ?q= and the legacy ?search= show results instead of the shelves
await go("/");
expect("home static panel equals dose.js render", await ev("return window.DOSE.check()"), true);
await ev(`document.querySelector('.chip[data-k=n][data-v="12"]').click()`);
expect("home card is live", await ev(`return document.querySelector("#live .mg").textContent.trim()`), "33 mg");
expect("home shelves: Essentials first, 8 shelves, ad after the 2nd", await ev(`return [document.querySelector(".shelf .sh h2").textContent.startsWith("Start with a base"), document.querySelectorAll(".shelf").length, document.querySelector(".shelf + .shelf + .ad") !== null]`), [true, 8, true]);
const results = `await new Promise((r) => setTimeout(r, 500)); return { q: document.documentElement.classList.contains("q"), home: getComputedStyle(document.getElementById("home")).display, title: document.querySelector("#results h2").textContent, n: document.querySelectorAll("#qgrid .card").length, none: !document.getElementById("qnone").hidden, field: document.querySelector("#results input[name=q]").value };`;
await go("/?q=brownie");
const r1 = await ev(results);
expect("?q=brownie", { ...r1, n: r1.n > 0 }, { q: true, home: "none", title: "Results for “brownie”", n: true, none: false, field: "brownie" });
await go("/pt/?search=zzzz");
expect("legacy ?search= with no match", await ev(results), { q: true, home: "none", title: "Resultados para “zzzz”", n: 0, none: true, field: "zzzz" });
await go("/");
await ev(`const i = document.querySelector(".hh input[name=q]"); i.value = "lemon"; i.click(); await new Promise((r) => setTimeout(r, 600));`);
expect("home search field opens the sheet with its text", await ev(`return [document.getElementById("search").open, document.getElementById("q").value, document.querySelectorAll("#s-list li").length > 0]`), [true, "lemon", true]);

// the root 404: language from the path, suggestions from the URL's words, no canonical
await go("/pt/receitas/brigadeiro-de-maconha-xyz/");
expect("pt 404", await ev(`await new Promise((r) => setTimeout(r, 500)); return [document.documentElement.lang, document.title, [...document.querySelectorAll("#e404 .nm")].some((n) => /Brigadeiro/.test(n.textContent)), !!document.querySelector("link[rel=canonical], link[hreflang]")]`), ["pt-BR", "Página Não Encontrada | HowToEdibles", true, false]);
await go("/asdfgh");
expect("404 with no match keeps the most-made recipes", await ev(`await new Promise((r) => setTimeout(r, 500)); return [document.documentElement.lang, document.querySelectorAll("#e404 .card").length, document.querySelector("#e404 h2").textContent]`), ["en", 4, "Most made recipes"]);

// articles index: topic chips and search filter the static lists
await go("/articles.html");
await ev(`document.querySelector('.topics [data-topic="Health"]').click()`);
expect("articles: Health chip", await ev(`return [document.getElementById("acount").textContent, document.getElementById("start").hidden, [...document.querySelectorAll("#alist li:not([hidden])")].every((l) => l.dataset.t === "Health")]`), ["12 articles", true, true]);
await ev(`document.querySelector('.topics [data-topic=""]').click(); const q = document.getElementById("aq"); q.value = "sleep"; q.dispatchEvent(new Event("input"));`);
expect("articles: search 'sleep'", await ev(`return [document.querySelectorAll("#alist li:not([hidden])").length > 0, document.getElementById("anone").hidden]`), [true, true]);

expect("no JS errors", errs, []);
ws.close(); chrome.kill();
process.exit(fails ? 1 : 0);
