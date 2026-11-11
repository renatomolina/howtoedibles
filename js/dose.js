// The calculator card (#54 A · Steppers, #59 peek + compact rail): recipe pages, the homepage hero and calculator.html (#74).
// The build pre-renders the panel, peek, sticker, facts and hero lines from the recipe defaults
// (scripts/build_redesign.rb: live_html, peek_html, newbie_html); this mirrors those helpers and only
// re-renders on input, never the inputs themselves (the keyboard stays open).
// COOKING_EFFICIENCY must match build_site.rb.
(function () {
  var D = window.DOSE;
  if (!D) return;
  var d = document, b = d.body, T = D.t, L = D.lang, EFF = 0.8;
  var LEVELS = [[0, 2.5], [2.5, 5], [5, 15], [15, 30], [30, 50], [50, 80]];
  var RANGES = ["1–2.5 mg", "2.5–5 mg", "5–15 mg", "15–30 mg", "30–50 mg", "50+ mg"];
  var COLORS = ["#8fd6a9", "#5cc48a", "#f4c542", "#f29a42", "#f27242", "#d9412b"];
  var FRACS = [[1 / 2, "½", "半"], [1 / 3, "⅓", "三分之一"], [1 / 4, "¼", "四分之一"], [1 / 6, "⅙", "六分之一"], [1 / 8, "⅛", "八分之一"], [1 / 10, "1/10", "十分之一"], [1 / 12, "1/12", "十二分之一"]];
  var LIM = { g: [0.1, 28, 0.5], s: [1, 99, 1], n: [1, 200, 1] };

  var fmts = {};
  function nf(v, dg) { return (fmts[dg] = fmts[dg] || new Intl.NumberFormat(L === "zh" ? "zh-CN" : L, { maximumFractionDigits: dg })).format(v); }
  function fmtMg(mg) { return nf(mg, mg >= 10 ? 0 : 1); }
  function fmtG(g) { return nf(g, g < 1 ? 2 : 1); }
  function esc(s) { return String(s).replace(/[&<>"']/g, function (c) { return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]; }); }
  function fill(s, v) { return s.replace(/\{(\w+)\}/g, function (_, k) { return v[k]; }); }
  function clamp(k, v) { return Math.min(LIM[k][1], Math.max(LIM[k][0], v)); }
  function mgOf(x) { return (10 * x.g * x.s * EFF) / x.n; }
  function lvl(mg) { for (var i = 0; i < 6; i++) if (mg <= LEVELS[i][1]) return i; return 5; }
  function five(mg) {
    if (mg <= 5) return { one: true };
    for (var i = 0; i < FRACS.length; i++) if (FRACS[i][0] <= 5 / mg) return { f: L === "zh" ? FRACS[i][2] : FRACS[i][1], mg: mg * FRACS[i][0] };
    return { tooStrong: true };
  }

  function newbieHTML(mg) {
    var h = five(mg);
    return (h.one ? T.newbieOne : h.tooStrong ? T.newbieTooStrong : fill(T.newbie, { f: h.f, mg: fmtMg(h.mg) })) + T.begLink;
  }
  function splitHTML(x) {
    var h = five(mgOf(x)), cut = "<small>" + esc(fill(T.cut, { n: Math.ceil((10 * x.g * x.s * EFF) / 5) })) + "</small>";
    if (h.one) return "";
    return h.f ? '<p class="split">' + fill(T.split, { f: h.f, t: nf(5, 1) }) + cut + "</p>" : '<p class="split bad">' + esc(T.tooStrong) + cut + "</p>";
  }
  function liveHTML(x) {
    var mg = mgOf(x), i = lvl(mg), lo = LEVELS[i][0], hi = LEVELS[i][1];
    var pos = Math.round(((i + Math.min(1, Math.max(0, (mg - lo) / (hi - lo)))) / 6) * 10000) / 100, lad = "";
    for (var j = 0; j < 6; j++) lad += j === i ? '<i class="on"></i>' : "<i></i>";
    return '<div class="big"><div><span class="mg">' + fmtMg(mg) + '<small> mg</small></span><span class="lbl">' + esc(T.per) + "</span></div>" +
      '<div class="tot"><b>' + fmtMg(mg * x.n) + " mg</b>" + esc(T.batch) + "</div></div>" +
      '<div class="lad" aria-hidden="true">' + lad + '<span class="mk" style="left:' + pos + '%"></span></div>' +
      '<div class="lvl"><b>' + esc(T.levels[i][0]) + "</b><span>" + RANGES[i] + " · " + esc(T.levels[i][1]) + "</span></div>" + splitHTML(x);
  }
  function eqHTML(x) { return "10 × " + fmtG(x.g) + " × " + nf(x.s, 1) + " × " + nf(EFF, 1) + " ÷ " + x.n + " = <b>" + fmtMg(mgOf(x)) + " mg</b>"; }
  function peekHTML(x) {
    var mg = mgOf(x);
    return "<b>" + fmtMg(mg) + "<small> mg</small></b><span>" + esc(T.levels[lvl(mg)][0]) + "<small>" + esc(T.per) + " · " + esc(fill(T.inBatch, { mg: fmtMg(mg * x.n) })) + "</small></span>";
  }

  var def = { g: D.d.g, s: D.d.s, n: D.d.n }, x = { g: def.g, s: def.s, n: def.n };
  var P = new URLSearchParams(location.search);
  [["g", "quantity"], ["s", "potency"], ["n", "portion"]].forEach(function (p) {
    var v = parseFloat(P.get(p[1]));
    if (v > 0) x[p[0]] = p[0] === "n" ? Math.round(clamp("n", v)) : clamp(p[0], v);
  });
  var live = d.getElementById("live"), peek = d.getElementById("peek"), card = d.getElementById("calc"), st = d.getElementById("sticker"), rail = d.querySelector(".rail");
  function edited() { return x.g !== def.g || x.s !== def.s || x.n !== def.n; }
  function set(o, html) { d.querySelectorAll('[data-o="' + o + '"]').forEach(function (el) { el.innerHTML = html; }); }

  function render(bump) {
    var mg = mgOf(x);
    live.innerHTML = liveHTML(x);
    peek.innerHTML = peekHTML(x);
    peek.style.setProperty("--lc", COLORS[lvl(mg)]);
    set("mgs", fmtMg(mg) + "<small>mg</small>");
    set("batch", fmtMg(mg * x.n) + " mg");
    set("n", x.n);
    set("g", fmtG(x.g));
    set("adj", esc(fill(T.adjustSub, { g: fmtG(x.g), p: nf(x.s, 1) })));
    set("newbie", newbieHTML(mg));
    set("eq", eqHTML(x));
    d.querySelectorAll("tr[data-lvl]").forEach(function (tr) { // calculator.html: the dose table follows the result
      var on = +tr.dataset.lvl === lvl(mg), td = tr.firstElementChild, y = td.querySelector(".you");
      if (on) tr.setAttribute("aria-current", "true"); else tr.removeAttribute("aria-current");
      if (on && !y) td.insertAdjacentHTML("beforeend", '<span class="you">' + esc(T.you) + "</span>");
      if (!on && y) y.remove();
    });
    d.querySelectorAll("[data-unit=n]").forEach(function (el) { el.textContent = x.n === 1 ? T.serving : T.servings; });
    d.querySelectorAll("[data-in]").forEach(function (i) { if (i !== d.activeElement) i.value = i.dataset.in === "g" ? fmtG(x.g) : nf(x[i.dataset.in], 1); });
    d.querySelectorAll(".chip[data-k]").forEach(function (c) { c.setAttribute("aria-pressed", x[c.dataset.k] === +c.dataset.v); });
    d.querySelector("[data-reset]").hidden = !edited();
    if (st) {
      st.classList.toggle("edited", edited());
      if (bump) { st.classList.remove("bump"); void st.offsetWidth; st.classList.add("bump"); }
    }
    measure();
  }
  function setK(k, v) {
    if (!isFinite(v)) return;
    x[k] = k === "n" ? Math.round(clamp(k, v)) : Math.round(clamp(k, v) * 100) / 100;
    render(true);
  }

  // The 56px peek takes over once the big panel's top has left the screen, while the fields are still on it.
  function measure() { if (rail) b.style.setProperty("--rail-h", rail.offsetHeight + "px"); onScroll(); }
  function onScroll() {
    var rt = parseFloat(getComputedStyle(b).getPropertyValue("--res-top")) || 0, r = card.getBoundingClientRect();
    card.classList.toggle("peeking", live.getBoundingClientRect().top < rt - 1 && r.bottom > rt + 120);
  }
  addEventListener("scroll", onScroll, { passive: true });
  addEventListener("resize", measure);

  d.addEventListener("input", function (e) { var k = e.target.dataset.in; if (k) { var v = parseFloat(String(e.target.value).replace(",", ".")); if (v > 0) setK(k, v); } });
  d.addEventListener("change", function (e) { if (e.target.dataset.in) { e.target.blur(); render(); } });
  d.addEventListener("keydown", function (e) { if (e.target.dataset && e.target.dataset.in && e.key === "Enter") e.target.blur(); });
  d.addEventListener("click", function (e) {
    var s = e.target.closest("[data-step]");
    if (s) { var k = s.dataset.step, step = LIM[k][2] * +s.dataset.d; return setK(k, k === "g" ? Math.round((x.g + step) / LIM.g[2]) * LIM.g[2] || LIM.g[0] : x[k] + step); }
    var c = e.target.closest(".chip[data-k]");
    if (c) return setK(c.dataset.k, +c.dataset.v);
    if (e.target.closest("[data-reset]")) { x = { g: def.g, s: def.s, n: def.n }; return render(true); }
    var w = e.target.closest("[data-wake]");
    if (w) wake(w.getAttribute("aria-pressed") !== "true");
  });

  // ---- Keep screen on (Wake Lock API); re-acquired when the tab comes back ----
  var lock = null, want = false;
  function setWake(on) { d.querySelectorAll("[data-wake]").forEach(function (w) { w.setAttribute("aria-pressed", on); w.lastChild.textContent = on ? T.wakeOn : T.wake; }); }
  function wake(on) {
    want = on;
    if (!on) { if (lock) lock.release(); lock = null; return setWake(false); }
    if (!navigator.wakeLock) { d.querySelectorAll("[data-wake-note]").forEach(function (n) { n.hidden = false; }); return setWake(false); }
    navigator.wakeLock.request("screen").then(function (l) { lock = l; setWake(true); }, function () {
      d.querySelectorAll("[data-wake-note]").forEach(function (n) { n.hidden = false; }); want = false; setWake(false);
    });
  }
  d.addEventListener("visibilitychange", function () { if (want && d.visibilityState === "visible") wake(true); });

  // QA hook (scripts/qa/devices.mjs): the static HTML must equal what this file renders for the defaults.
  D.check = function () {
    var z = { g: def.g, s: def.s, n: def.n };
    function same(el, html) { if (!el) return true; var t = d.createElement("div"); t.innerHTML = html; return t.innerHTML === el.innerHTML; }
    return same(live, liveHTML(z)) && same(peek, peekHTML(z)) && same(d.querySelector('[data-o="newbie"]'), newbieHTML(mgOf(z))) && same(d.querySelector('[data-o="eq"]'), eqHTML(z));
  };
  if (edited()) render(); else measure();
})();
