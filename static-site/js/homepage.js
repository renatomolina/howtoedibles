/* homepage.js — Client-side pagination for the recipe grid
   Shows 12 cards per page; all cards are pre-rendered in HTML */

document.addEventListener('DOMContentLoaded', function () {
  var ITEMS_PER_PAGE = 12;
  var currentPage = 1;

  var allCards = Array.from(document.querySelectorAll('.recipe-card-item'));
  var totalPages = Math.ceil(allCards.length / ITEMS_PER_PAGE);
  var controls = document.getElementById('pagination-controls');

  if (allCards.length === 0) return;

  function showPage(page) {
    currentPage = page;
    var start = (page - 1) * ITEMS_PER_PAGE;
    var end   = start + ITEMS_PER_PAGE;

    allCards.forEach(function (card, i) {
      if (i >= start && i < end) {
        card.classList.remove('hidden');
      } else {
        card.classList.add('hidden');
      }
    });

    renderControls();
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  function renderControls() {
    if (!controls || totalPages <= 1) return;

    var html = '<ul class="pagination justify-content-center">';

    /* Previous */
    html += '<li class="page-item' + (currentPage === 1 ? ' disabled' : '') + '">';
    html += '<a class="page-link" href="#" data-page="' + (currentPage - 1) + '">&laquo;</a></li>';

    /* Page numbers */
    for (var p = 1; p <= totalPages; p++) {
      html += '<li class="page-item' + (p === currentPage ? ' active' : '') + '">';
      html += '<a class="page-link" href="#" data-page="' + p + '">' + p + '</a></li>';
    }

    /* Next */
    html += '<li class="page-item' + (currentPage === totalPages ? ' disabled' : '') + '">';
    html += '<a class="page-link" href="#" data-page="' + (currentPage + 1) + '">&raquo;</a></li>';

    html += '</ul>';
    controls.innerHTML = html;

    /* Wire click events */
    controls.querySelectorAll('.page-link').forEach(function (link) {
      link.addEventListener('click', function (e) {
        e.preventDefault();
        var page = parseInt(this.getAttribute('data-page'));
        if (page >= 1 && page <= totalPages && page !== currentPage) {
          showPage(page);
        }
      });
    });
  }

  showPage(1);
});
