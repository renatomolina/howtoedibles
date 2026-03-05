(function () {
  var toggle = document.getElementById('dark-mode-toggle');
  if (!toggle) return;

  function setTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    try { localStorage.setItem('theme', theme); } catch (e) {}
  }

  toggle.addEventListener('click', function () {
    var current = document.documentElement.getAttribute('data-theme');
    setTheme(current === 'dark' ? 'light' : 'dark');
  });
})();
