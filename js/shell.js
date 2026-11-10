// The new shell (#51): theme, the scroll-up compact bar, the menu and search <dialog>s, per-language search.
// Pages on the old shell still use dark-mode.js / search-autocomplete.js; they share the "theme" key.
(function () {
  var d = document, b = d.body, root = d.documentElement;

  // ---- theme: Auto removes the key (the old dark-mode.js would apply "auto" literally) ----
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
  var S = d.getElementById("search"), T = JSON.parse(S.dataset.t), pre = S.dataset.prefix, idx = null, sel = -1;
  var q = d.getElementById("q"), clear = d.getElementById("qclear");
  var idle = d.getElementById("s-idle"), none = d.getElementById("s-none"), list = d.getElementById("s-list");
  var ul = list.querySelector("ul"), more = list.querySelector(".more");
  function fold(s) { return s.normalize("NFD").replace(/[̀-ͯ]/g, "").toLowerCase(); }
  function esc(s) { return String(s).replace(/[&<>"]/g, function (c) { return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]; }); }
  function loadIndex() {
    if (idx) return;
    idx = [];
    fetch(S.dataset.index).then(function (r) { return r.json(); }).then(function (j) {
      idx = j.r.map(function (x) { var c = j.c[x[3]]; return { slug: x[0], name: x[1], en: x[2], cat: c, mg: x[4], g: x[5], key: fold(x[1] + " " + x[2] + " " + c[0]) }; });
      if (q.value.trim()) render();
    }).catch(function () { idx = null; });
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
    if (!idx || !idx.length) return; // still loading: render() runs again when the index arrives
    var hits = idx.filter(function (x) { return words.every(function (w) { return x.key.indexOf(w) >= 0; }); });
    hits.sort(function (a, b) { return (fold(a.name).indexOf(words[0]) === 0 ? 0 : 1) - (fold(b.name).indexOf(words[0]) === 0 ? 0 : 1); });
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

  d.addEventListener("click", function (e) {
    var o = e.target.closest("[data-open]");
    if (o) return open(o.dataset.open);
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
