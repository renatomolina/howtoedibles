/* search-autocomplete.js — client-side recipe autocomplete */
(function () {
  var input = document.getElementById('recipe-search');
  if (!input) return;

  var MAX_RESULTS = 8;
  var recipes = null;   // loaded lazily
  var activeIndex = -1;
  var dropdown = null;

  /* ── Build dropdown container ─────────────────────────── */
  function buildDropdown() {
    dropdown = document.createElement('div');
    dropdown.id = 'search-dropdown';
    dropdown.className = 'search-dropdown';
    dropdown.setAttribute('role', 'listbox');
    input.parentNode.style.position = 'relative';
    input.parentNode.appendChild(dropdown);
  }

  /* ── Load index on first keystroke ────────────────────── */
  function loadIndex(cb) {
    if (recipes) { cb(); return; }
    fetch('/data/search-index.json')
      .then(function (r) { return r.json(); })
      .then(function (data) { recipes = data; cb(); })
      .catch(function () { recipes = []; });
  }

  /* ── Filter recipes ────────────────────────────────────── */
  function filter(query) {
    var q = query.toLowerCase().trim();
    if (!q) return [];
    return recipes.filter(function (r) {
      return r.name.toLowerCase().includes(q) ||
             (r.cat && r.cat.toLowerCase().includes(q));
    }).slice(0, MAX_RESULTS);
  }

  /* ── Highlight matching text ───────────────────────────── */
  function highlight(text, query) {
    var q = query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    return text.replace(new RegExp('(' + q + ')', 'gi'),
      '<mark>$1</mark>');
  }

  /* ── Render dropdown ───────────────────────────────────── */
  function render(results, query) {
    dropdown.innerHTML = '';
    activeIndex = -1;
    if (!results.length) { close(); return; }

    results.forEach(function (r, i) {
      var item = document.createElement('a');
      item.className = 'search-dropdown-item';
      item.href = '/recipes/' + r.slug + '/';
      item.setAttribute('role', 'option');
      item.innerHTML =
        '<span class="sdi-name">' + highlight(r.name, query) + '</span>' +
        (r.cat ? '<span class="sdi-cat">' + r.cat + '</span>' : '');

      item.addEventListener('mousedown', function (e) {
        e.preventDefault(); // prevent blur before click
      });
      item.addEventListener('click', function () {
        input.value = r.name;
        close();
      });
      item.addEventListener('mousemove', function () {
        setActive(i);
      });
      dropdown.appendChild(item);
    });

    dropdown.classList.add('open');
  }

  /* ── Keyboard active item ──────────────────────────────── */
  function setActive(index) {
    var items = dropdown.querySelectorAll('.search-dropdown-item');
    items.forEach(function (el, i) {
      el.classList.toggle('active', i === index);
    });
    activeIndex = index;
  }

  /* ── Close ─────────────────────────────────────────────── */
  function close() {
    if (dropdown) {
      dropdown.classList.remove('open');
      dropdown.innerHTML = '';
    }
    activeIndex = -1;
  }

  /* ── Events ─────────────────────────────────────────────── */
  input.addEventListener('input', function () {
    var q = input.value;
    loadIndex(function () {
      render(filter(q), q);
    });
  });

  input.addEventListener('keydown', function (e) {
    var items = dropdown ? dropdown.querySelectorAll('.search-dropdown-item') : [];
    if (e.key === 'ArrowDown') {
      e.preventDefault();
      setActive(Math.min(activeIndex + 1, items.length - 1));
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      setActive(Math.max(activeIndex - 1, 0));
    } else if (e.key === 'Enter') {
      if (activeIndex >= 0 && items[activeIndex]) {
        e.preventDefault();
        items[activeIndex].click();
      }
    } else if (e.key === 'Escape') {
      close();
    }
  });

  input.addEventListener('blur', function () {
    setTimeout(close, 150); // delay to allow click
  });

  input.addEventListener('focus', function () {
    if (input.value.trim()) {
      loadIndex(function () {
        render(filter(input.value), input.value);
      });
    }
  });

  buildDropdown();
})();
