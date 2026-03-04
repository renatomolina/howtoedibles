/* calculator.js — Vanilla JS port of calculator.es6
   Replaces jQuery + bootstrap-slider with native range inputs */

document.addEventListener('DOMContentLoaded', function () {
  var widget = document.getElementById('calculator-widget');
  if (!widget) return;

  var DELTA_QUANTITY = 0.5, DELTA_STRENGTH = 1, DELTA_SERVINGS = 1;
  var MINIMUM_QUANTITY = 0.01, MAXIMUM_QUANTITY = 28;
  var MINIMUM_STRENGTH = 1, MAXIMUM_STRENGTH = 99;
  var MINIMUM_PORTIONS = 1, MAXIMUM_PORTIONS = 200;

  var state = { grams: null, strength: null, portions: null };

  /* --- Exposed globals (used by inline onchange handlers) --- */
  window.updateQuantity = function (v) { setState({ grams: parseFloat(v) }); };
  window.updateStrength = function (v) { setState({ strength: parseFloat(v) }); };
  window.updatePortion  = function (v) { setState({ portions: parseFloat(v) }); };

  /* --- Init ------------------------------------------------- */
  function getInitialState() {
    var defaults = window.RECIPE_DEFAULTS || {};
    var params   = new URLSearchParams(window.location.search);

    var grams    = params.has('quantity') ? parseFloat(params.get('quantity'))
                 : defaults.quantity      != null ? defaults.quantity
                 : 3.5;

    var strength = params.has('potency')  ? parseFloat(params.get('potency'))
                 : defaults.potency       != null ? defaults.potency
                 : 14;

    var portions = params.has('portion')  ? parseFloat(params.get('portion'))
                 : defaults.portion       != null ? defaults.portion
                 : 50;

    return { grams: grams, strength: strength, portions: portions };
  }

  function initialize() {
    var init = getInitialState();

    /* Seed slider positions before first setState */
    setSliderValue('grams-slider',    init.grams);
    setSliderValue('strength-slider', init.strength);
    setSliderValue('portion-slider',  init.portions);

    /* Wire range input events */
    on('grams-slider',    'input', function () { setState({ grams:    parseFloat(this.value) }); });
    on('strength-slider', 'input', function () { setState({ strength: parseFloat(this.value) }); });
    on('portion-slider',  'input', function () { setState({ portions: parseFloat(this.value) }); });

    /* Wire +/- buttons */
    wireUpDown('grams',    'decrease-quantity', 'increase-quantity', DELTA_QUANTITY);
    wireUpDown('strength', 'decrease-strength', 'increase-strength', DELTA_STRENGTH);
    wireUpDown('portions', 'decrease-servings', 'increase-servings', DELTA_SERVINGS);

    setState(init);
  }

  /* --- State ------------------------------------------------ */
  function clamp(val, min, max) {
    return Math.min(Math.max(val, min), max);
  }

  function clampState(s) {
    var key = Object.keys(s)[0];
    var ranges = {
      grams:    [MINIMUM_QUANTITY, MAXIMUM_QUANTITY],
      strength: [MINIMUM_STRENGTH, MAXIMUM_STRENGTH],
      portions: [MINIMUM_PORTIONS, MAXIMUM_PORTIONS]
    };
    var r = ranges[key];
    if (r) s[key] = clamp(s[key], r[0], r[1]);
    return s;
  }

  function setState(newState) {
    newState = clampState(newState);
    state = Object.assign({}, state, newState);
    render();
  }

  /* --- Render ----------------------------------------------- */
  function render() {
    syncInput('grams-input',    'grams-slider',    state.grams,    true);
    syncInput('strength-input', 'strength-slider', state.strength, false);
    syncInput('portion-input',  'portion-slider',  state.portions, false);

    renderQuantityLabels();
    renderPotency();
    renderEffects();
    updateReferenceRecipes();
  }

  function syncInput(inputId, sliderId, value, fixed) {
    var input  = document.getElementById(inputId);
    var slider = document.getElementById(sliderId);
    var display = fixed ? parseFloat(value).toFixed(1) : parseInt(value);
    if (input  && String(input.value)  !== String(display)) input.value  = display;
    if (slider && parseFloat(slider.value) !== parseFloat(value)) slider.value = value;
    if (slider) updateSliderFill(slider);
  }

  function updateSliderFill(slider) {
    var min = parseFloat(slider.min) || 0;
    var max = parseFloat(slider.max) || 100;
    var val = parseFloat(slider.value) || 0;
    var pct = ((val - min) / (max - min)) * 100;
    slider.style.background = 'linear-gradient(to right, #f27242 ' + pct + '%, #e8e8e8 ' + pct + '%)';
  }

  function renderQuantityLabels() {
    var gLabel = document.getElementById('grams-quantity-label');
    var gRecipe = document.getElementById('grams-quantity-recipe');
    if (gLabel)  gLabel.textContent  = pluralize('gram', state.grams);
    if (gRecipe) gRecipe.textContent = pluralize('gram', state.grams, true);
  }

  function renderPotency() {
    var dosage = getCurrentDosage();
    var result = document.getElementById('potency-result');
    var total  = document.getElementById('potency-result-total');
    var level  = document.getElementById('highness-level');

    if (result) { result.textContent = dosage.toFixed(2) + ' mg'; animateFlash(result); }
    if (total)  { total.textContent  = (dosage * state.portions).toFixed(1) + ' mg'; animateFlash(total); }
    if (level)  level.innerHTML = getDosageLevelLabel(dosage);
  }

  function renderEffects() {
    var dosage = getCurrentDosage();
    var pos = document.getElementById('positive-effect-details');
    var neg = document.getElementById('negative-effect-details');
    if (pos) pos.innerHTML = renderPositiveEffects(dosage);
    if (neg) neg.innerHTML = renderNegativeEffects(dosage);
  }

  function updateReferenceRecipes() {
    document.querySelectorAll('.recipe-reference').forEach(function (el) {
      var base = el.getAttribute('href').split('?')[0];
      el.setAttribute('href', base + '?quantity=' + state.grams + '&potency=' + state.strength + '&portion=1');
    });
  }

  /* --- Dosage formula --------------------------------------- */
  function getCurrentDosage() {
    return (10 * (state.grams * state.strength)) / state.portions;
  }

  /* --- Labels / Effects ------------------------------------- */
  function getDosageLevelLabel(value) {
    if (value < 10)
      return "<i class='far fa-smile fa-lg green icon-large' aria-hidden='true'></i> THRESHOLD DOSE";
    else if (value < 20)
      return "<i class='far fa-surprise fa-lg yellow icon-large' aria-hidden='true'></i> COMMON DOSE";
    else if (value < 30)
      return "<i class='far fa-grimace fa-lg orange icon-large' aria-hidden='true'></i> STRONG DOSE";
    else
      return "<i class='far fa-flushed fa-lg red icon-large' aria-hidden='true'></i> HEAVY DOSE";
  }

  function badge(text, type) {
    return "<p class='badge badge-" + type + " badge-label'>" + text + "</p> ";
  }

  function renderPositiveEffects(value) {
    var L1 = ['relaxation','stress reduction','mood lift','giggling','laughing'];
    var L2 = ['creative','reduced nausea','euphoria','increased appetite','tasks become more interesting'];
    var L3 = ['enhanced senses','philosophical','ideas flow easily','increase in body/mind connection'];
    var effects = [];
    if (value > 0)  effects = effects.concat(L1);
    if (value >= 10) effects = effects.concat(L2);
    if (value >= 20) effects = effects.concat(L3);
    return effects.map(function (e) { return badge(e, 'success'); }).join('');
  }

  function renderNegativeEffects(value) {
    var L1 = ['lightheadedness'];
    var L2 = ['headaches','paranoia','short-term memory impairment'];
    var L3 = ['anxiety','time perception altered','nausea','agitation'];
    var L4 = ['racing heart','loss of coordination','panic attacks'];
    var effects = [];
    if (value > 0)  effects = effects.concat(L1);
    if (value >= 10) effects = effects.concat(L2);
    if (value >= 20) effects = effects.concat(L3);
    if (value >= 30) effects = effects.concat(L4);
    return effects.map(function (e) { return badge(e, 'danger'); }).join('');
  }

  /* --- Utilities -------------------------------------------- */
  function pluralize(word, count, withCount) {
    var n = parseFloat(count);
    var plural = Math.abs(n) !== 1 ? word + 's' : word;
    return withCount ? n.toFixed(1) + ' ' + plural : plural;
  }

  function animateFlash(el) {
    el.classList.remove('flash');
    void el.offsetWidth; /* trigger reflow */
    el.classList.add('flash');
  }

  function on(id, event, handler) {
    var el = document.getElementById(id);
    if (el) el.addEventListener(event, handler);
  }

  function setSliderValue(id, value) {
    var el = document.getElementById(id);
    if (el) el.value = value;
  }

  function wireUpDown(attribute, decId, incId, delta) {
    on(decId, 'click', function (e) {
      e.preventDefault();
      var s = {};
      s[attribute] = ((state[attribute] - delta) * 10) / 10;
      setState(s);
    });
    on(incId, 'click', function (e) {
      e.preventDefault();
      var s = {};
      s[attribute] = parseFloat(state[attribute]) + delta;
      setState(s);
    });
  }

  initialize();
});
