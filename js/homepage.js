/* homepage.js — Search + client-side pagination for the recipe grid */

document.addEventListener('DOMContentLoaded', function () {
  var ITEMS_PER_PAGE = 12;
  var currentPage = 1;
  var allCards = Array.from(document.querySelectorAll('.recipe-card-item'));
  var visibleCards = allCards; // subset after search filter
  var controls = document.getElementById('pagination-controls');
  var noResults = document.getElementById('search-no-results');
  var searchInput = document.getElementById('recipe-search');

  if (allCards.length === 0) return;

  /* ── Search ────────────────────────────────────────────────── */
  function getSearchTerm() {
    return searchInput ? searchInput.value.trim().toLowerCase() : '';
  }

  function filterCards() {
    var term = getSearchTerm();
    if (!term) {
      visibleCards = allCards;
    } else {
      visibleCards = allCards.filter(function (card) {
        var text = (card.getAttribute('data-search') || card.textContent).toLowerCase();
        return text.indexOf(term) !== -1;
      });
    }
    currentPage = 1;
    showPage(1, false);
    if (noResults) noResults.style.display = visibleCards.length === 0 ? 'block' : 'none';
  }

  if (searchInput) {
    /* Pre-fill from ?search= URL param */
    var urlTerm = new URLSearchParams(window.location.search).get('search');
    if (urlTerm) { searchInput.value = urlTerm; }

    searchInput.addEventListener('input', filterCards);

    /* On non-homepage pages, pressing Enter redirects to /?search=... */
    searchInput.addEventListener('keydown', function (e) {
      if (e.key === 'Enter') {
        e.preventDefault();
        var q = searchInput.value.trim();
        if (q) window.location.href = '/?search=' + encodeURIComponent(q);
      }
    });
  }

  /* ── Pagination ─────────────────────────────────────────────── */
  function showPage(page, scroll) {
    currentPage = page;
    var start = (page - 1) * ITEMS_PER_PAGE;
    var end   = start + ITEMS_PER_PAGE;

    allCards.forEach(function (card) { card.classList.add('hidden'); });
    visibleCards.forEach(function (card, i) {
      if (i >= start && i < end) card.classList.remove('hidden');
    });

    renderControls();
    if (scroll) window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  function renderControls() {
    if (!controls) return;
    var totalPages = Math.ceil(visibleCards.length / ITEMS_PER_PAGE);
    if (totalPages <= 1) { controls.innerHTML = ''; return; }

    var html = '<ul class="pagination justify-content-center">';

    html += '<li class="page-item' + (currentPage === 1 ? ' disabled' : '') + '">';
    html += '<a class="page-link" href="#" data-page="' + (currentPage - 1) + '">&laquo;</a></li>';

    for (var p = 1; p <= totalPages; p++) {
      html += '<li class="page-item' + (p === currentPage ? ' active' : '') + '">';
      html += '<a class="page-link" href="#" data-page="' + p + '">' + p + '</a></li>';
    }

    html += '<li class="page-item' + (currentPage === totalPages ? ' disabled' : '') + '">';
    html += '<a class="page-link" href="#" data-page="' + (currentPage + 1) + '">&raquo;</a></li>';

    html += '</ul>';
    controls.innerHTML = html;

    controls.querySelectorAll('.page-link').forEach(function (link) {
      link.addEventListener('click', function (e) {
        e.preventDefault();
        var page = parseInt(this.getAttribute('data-page'));
        if (page >= 1 && page <= totalPages && page !== currentPage) showPage(page, true);
      });
    });
  }

  /* Initial render (respects ?search= param) */
  filterCards();
});
