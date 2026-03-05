(function(){
  var nav = document.getElementById('navbarMain');
  if (!nav) return;

  // Toggle body scroll lock when menu opens/closes
  nav.addEventListener('shown.bs.collapse', function() {
    document.body.classList.add('mobile-menu-open');
  });
  nav.addEventListener('hidden.bs.collapse', function() {
    document.body.classList.remove('mobile-menu-open');
  });

  // Bootstrap 4 events
  $(nav).on('show.bs.collapse', function() {
    document.body.classList.add('mobile-menu-open');
  });
  $(nav).on('hide.bs.collapse', function() {
    document.body.classList.remove('mobile-menu-open');
  });

  // Close menu when clicking the ::before pseudo-element (X icon area)
  nav.addEventListener('click', function(e) {
    // The ::before sits at the top — detect clicks in that region
    var rect = nav.getBoundingClientRect();
    var clickY = e.clientY - rect.top + nav.scrollTop;
    // Only close if clicking in the top bar area (roughly 60px) and not on a nav link
    if (clickY <= 60 && e.target === nav) {
      $(nav).collapse('hide');
    }
  });
})();
