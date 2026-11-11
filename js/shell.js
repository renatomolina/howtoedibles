// The new shell (#51): theme, the scroll-up compact bar, the menu and search <dialog>s, per-language search,
// plus the homepage's ?q= / ?search= results and the 404's suggestions (#74), which reuse the same index.
(function () {
  var d = document, b = d.body, root = d.documentElement;

  // ---- theme: "light" / "dark" in localStorage; Auto removes the key ----
  var mq = matchMedia("(prefers-color-scheme: dark)");
  function stored() { try { var t = localStorage.getItem("theme"); return t === "dark" || t === "light" ? t : "auto"; } catch (e) { return "auto"; } }
  function applyTheme() {
    var t = stored();
    root.dataset.theme = t === "auto" ? (mq.matches ? "dark" : "light") : t;
    d.querySelectorAll("[data-theme-set]").forEach(function (x) { x.setAttribute("aria-pressed", x.dataset.themeSet === t); });
  }
  if (mq.addEventListener) mq.addEventListener("change", applyTheme);
  applyTheme();

  // ---- compact bar: in only while scrolling up past the masthead, so it never covers the recipe ----
  var lastY = scrollY;
  addEventListener("scroll", function () {
    var y = scrollY;
    if (Math.abs(y - lastY) > 6) { b.classList.toggle("mini-on", y > 140 && y < lastY); lastY = y; }
  }, { passive: true });

  // ---- dialogs: each open pushes a history entry, so Back (and the iOS edge swipe) closes it ----
  var switching = false;
  function open(id) {
    var cur = d.querySelector("dialog[open]"), dlg = d.getElementById(id);
    if (cur === dlg) return;
    if (cur) { switching = true; cur.close(); switching = false; history.replaceState({ dlg: id }, ""); }
    else history.pushState({ dlg: id }, "");
    dlg.showModal();
    b.classList.add("locked");
    if (id === "search") { var q = d.getElementById("q"); q.focus(); q.select(); loadIndex(); }
  }
  d.querySelectorAll("dialog").forEach(function (dlg) {
    dlg.addEventListener("close", function () {
      if (switching) return;
      b.classList.remove("locked");
      if (history.state && history.state.dlg) history.back();
    });
  });
  addEventListener("popstate", function () { var o = d.querySelector("dialog[open]"); if (o) o.close(); });

  // ---- search: per-language index, accent-insensitive, prefix matches first ----
  var S = d.getElementById("search"), T = JSON.parse(S.dataset.t), pre = S.dataset.prefix, idx = null, wait = null, sel = -1;
  var q = d.getElementById("q"), clear = d.getElementById("qclear");
  var idle = d.getElementById("s-idle"), none = d.getElementById("s-none"), list = d.getElementById("s-list");
  var ul = list.querySelector("ul"), more = list.querySelector(".more");
  function fold(s) { return s.normalize("NFD").replace(/[̀-ͯ]/g, "").toLowerCase(); }
  function esc(s) { return String(s).replace(/[&<>"]/g, function (c) { return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]; }); }
  function loadIndex() {
    return wait || (wait = fetch(S.dataset.index).then(function (r) { return r.json(); }).then(function (j) {
      idx = j.r.map(function (x) { var c = j.c[x[3]]; return { slug: x[0], name: x[1], en: x[2], cat: c, mg: x[4], g: x[5], key: fold(x[1] + " " + x[2] + " " + c[0]) }; });
      if (q.value.trim()) render();
      return idx;
    }).catch(function () { wait = null; return []; }));
  }
  // every word in the name, English name or category; names that start with the first word come first
  function match(v) {
    var words = fold(v).split(/\s+/).filter(Boolean);
    var hits = idx.filter(function (x) { return words.every(function (w) { return x.key.indexOf(w) >= 0; }); });
    return hits.sort(function (a, b) { return (fold(a.name).indexOf(words[0]) === 0 ? 0 : 1) - (fold(b.name).indexOf(words[0]) === 0 ? 0 : 1); });
  }
  // the build's card() (scripts/build_redesign.rb), with the same slug-seeded cover placement
  function seeded(s) {
    var h = 2166136261;
    for (var i = 0; i < s.length; i++) h = Math.imul(h ^ s.charCodeAt(i), 16777619) >>> 0;
    return function (n) { h = (Math.imul(h ^ (h >>> 15), 2246822507) ^ n) >>> 0; return h / 4294967296; };
  }
  function card(x, withCat) {
    var r = seeded(x.slug), c = x.cat, r1 = function (v) { return Math.round(v * 10) / 10; };
    var st = "--cat-lt:" + c[1] + ";--deep-lt:" + c[2] + ";--cat-dk:" + c[3] + ";--deep-dk:" + c[4] + ";--gs:" + r1(90 + r(1) * 14) + "%;--gx:" + r1(-12 - r(2) * 16) + "%;--gy:" + r1(-12 - r(3) * 16) + "%;--gr:" + r1(-20 + r(4) * 30) + "deg";
    return '<a class="card" href="' + pre + "/recipes/" + x.slug + '/"><span class="cv" style="' + st + '"><svg viewBox="0 0 100 100" aria-hidden="true"><use href="#g-' + x.g + '"/></svg>' +
      '<span class="dot" title="' + x.mg + " mg THC " + esc(T.per) + '"><b>' + x.mg + '</b><small>mg</small></span></span><span class="nm">' + esc(x.name) + "</span>" +
      (withCat ? '<span class="mt">' + esc(c[0]) + "</span>" : "") + "</a>";
  }
  function hi(text, w) {
    var i = w ? fold(text).indexOf(w) : -1;
    return i < 0 ? esc(text) : esc(text.slice(0, i)) + "<mark>" + esc(text.slice(i, i + w.length)) + "</mark>" + esc(text.slice(i + w.length));
  }
  function row(x, w) {
    var c = x.cat, alt = x.en && fold(x.name).indexOf(w) < 0 && fold(x.en).indexOf(w) >= 0;
    return '<li><a href="' + pre + "/recipes/" + x.slug + '/" role="option"><span class="cv" style="--cat-lt:' + c[1] + ";--deep-lt:" + c[2] + ";--cat-dk:" + c[3] + ";--deep-dk:" + c[4] +
      '"><svg viewBox="0 0 100 100" aria-hidden="true"><use href="#g-' + x.g + '"/></svg></span><div><b>' + hi(x.name, w) + "</b>" +
      (alt ? '<span class="alt">' + esc(T.also) + " " + hi(x.en, w) + "</span><br>" : "") + "<span>" + esc(c[0]) + " · " + x.mg + " mg " + esc(T.per) + "</span></div></a></li>";
  }
  function render() {
    var v = q.value.trim(), words = fold(v).split(/\s+/).filter(Boolean);
    clear.hidden = !q.value; sel = -1;
    if (!words.length) { idle.hidden = false; none.hidden = list.hidden = true; return; }
    if (!idx) return; // still loading: render() runs again when the index arrives
    var hits = match(v);
    idle.hidden = true;
    none.hidden = !!hits.length; list.hidden = !hits.length;
    if (!hits.length) { none.querySelector("h3").textContent = T.q.replace("{q}", v); return; }
    ul.innerHTML = hits.slice(0, 8).map(function (x) { return row(x, words[0]); }).join("");
    more.hidden = hits.length <= 8;
    more.href = pre + "/?q=" + encodeURIComponent(v);
    more.textContent = T.all.replace("{n}", hits.length);
  }
  q.addEventListener("input", render);
  q.addEventListener("keydown", function (e) {
    var items = ul.querySelectorAll("a");
    if (list.hidden || !items.length) return;
    if (e.key === "ArrowDown" || e.key === "ArrowUp") {
      e.preventDefault();
      sel = Math.max(0, Math.min(items.length - 1, sel + (e.key === "ArrowDown" ? 1 : -1)));
      items.forEach(function (a, i) { a.setAttribute("aria-selected", i === sel); });
      items[sel].scrollIntoView({ block: "nearest" });
    } else if (e.key === "Enter") { e.preventDefault(); location.href = (items[sel] || items[0]).href; }
  });

  // ---- homepage in search mode (?q=, or the legacy ?search=): the build's inline script has set html.q ----
  var R = d.getElementById("results");
  if (R && root.classList.contains("q")) {
    var RT = JSON.parse(R.dataset.t), P = new URLSearchParams(location.search), v = (P.get("q") || P.get("search") || "").trim();
    R.querySelector("h2").textContent = RT.title.replace("{q}", v);
    R.querySelectorAll("input[name=q]").forEach(function (i) { i.value = v; });
    loadIndex().then(function () {
      var hits = idx ? match(v) : [], none = d.getElementById("qnone");
      d.getElementById("qn").textContent = hits.length ? RT.n.replace("{n}", hits.length) : "";
      d.getElementById("qgrid").innerHTML = hits.map(function (x) { return card(x, true); }).join("");
      none.querySelector("p").textContent = RT.none.replace("{q}", v);
      none.hidden = !!hits.length;
    });
  }

  // ---- 404: up to 4 recipes whose slug or name shares a word with the broken URL ----
  var E = d.getElementById("e404");
  if (E) {
    var path = location.pathname, u = d.getElementById("e404u");
    u.textContent = path; u.parentNode.hidden = false;
    var STOP = "recipes recipe receitas receita rezepte rezept recetas receta html htm php www index how to make made easy best simple homemade the a an and with for of de da do com con mit und y e para cannabis weed marijuana maconha infused canna page".split(" ");
    var split = function (s) { return s.toLowerCase().split(/[^a-z0-9À-ɏ一-鿿]+/); };
    var stem = function (w) { return w.replace(/ies$/, "y").replace(/(es|s)$/, ""); };
    try { path = decodeURIComponent(path); } catch (err) {}
    var words = split(path).filter(function (w) { return w.length > 2 && STOP.indexOf(w) < 0 && !/^\d+$/.test(w); });
    var ws = words.map(stem).filter(function (w, i, a) { return a.indexOf(w) === i; });
    if (ws.length) {
      E.parentNode.querySelector("input[name=q]").value = words.join(" ");
      loadIndex().then(function () {
        var hits = (idx || []).map(function (x) {
          var hay = split(x.slug + " " + x.name + " " + x.en).filter(function (w) { return w.length > 2; }).map(stem);
          return [ws.filter(function (w) { return hay.some(function (h) { return h === w || (w.length > 3 && (h.indexOf(w) === 0 || w.indexOf(h) === 0)); }); }).length, x];
        }).filter(function (p) { return p[0] > 0; }).sort(function (a, b) { return b[0] - a[0] || a[1].slug.length - b[1].slug.length; }).slice(0, 4);
        if (!hits.length) return;
        E.querySelector("h2").textContent = JSON.parse(E.dataset.t).looking;
        E.querySelector(".grid").innerHTML = hits.map(function (p) { return card(p[1]); }).join("");
      });
    }
  }

  d.addEventListener("click", function (e) {
    var o = e.target.closest("[data-open]");
    if (o) { // the homepage/404 search fields open the sheet too, carrying what's typed
      open(o.dataset.open);
      if (o.tagName === "INPUT") { q.value = o.value; render(); }
      return;
    }
    var c = e.target.closest("[data-close]");
    if (c) return c.closest("dialog").close();
    if (e.target.closest("#qclear")) { q.value = ""; render(); return q.focus(); }
    var th = e.target.closest("[data-theme-set]");
    if (th) {
      try { if (th.dataset.themeSet === "auto") localStorage.removeItem("theme"); else localStorage.setItem("theme", th.dataset.themeSet); } catch (err) {}
      applyTheme();
    }
  });
})();
