$(document).on('ready', function() {
  if($("#calculator-widget").length !== 0) {
    const DELTA_QUANTITY = 0.5, DELTA_STRENGTH = 1, DELTA_SERVINGS = 1
    const MINIMUM_QUANTITY = 0.01, MAXIMUM_QUANTITY = 28
    const MINIMUM_STRENGTH = 1, MAXIMUM_STRENGTH = 99
    const MINIMUM_PORTIONS = 1, MAXIMUM_PORTIONS = 200

    const decreaseQuantityButton = $("#decrease-quantity")
    const increaseQuantityButton = $("#increase-quantity")

    const decreaseStrengthButton = $("#decrease-strength")
    const increaseStrengthButton = $("#increase-strength")

    const decreaseServingsButton = $("#decrease-servings")
    const increaseServingsButton = $("#increase-servings")

    let state = {
      grams: null,
      strength: null,
      portions: null
    }

    window.updateQuantity = (quantity) => setState({ grams: quantity })
    window.updateStrength = (quantity) => setState({ strength: quantity })
    window.updatePortion = (quantity) => setState({ portions: quantity })

    function initialize() {
      initializeSliders()
      setState({
        grams: parseFloat($('#grams-slider')[0].value).toFixed(1),
        strength: parseInt($('#strength-slider')[0].value),
        portions: parseInt($('#portion-slider')[0].value)
      })

      setListenerUpDownButton('grams', decreaseQuantityButton, increaseQuantityButton, DELTA_QUANTITY)
      setListenerUpDownButton('strength', decreaseStrengthButton, increaseStrengthButton, DELTA_STRENGTH)
      setListenerUpDownButton('portions', decreaseServingsButton, increaseServingsButton, DELTA_SERVINGS)
    }

    function initializeSliders() {
      $('#grams-slider').slider().on('change', (slider) => setState({ grams: slider.value.newValue }))
      $('#strength-slider').slider().on('change', (slider) => setState({ strength: slider.value.newValue }))
      $('#portion-slider').slider().on('change', (slider) => setState({ portions: slider.value.newValue }))
    }

    function setListenerUpDownButton(attribute, decreaseButton, increaseButton, delta) {
      decreaseButton.on('click', (event) => {
        event.preventDefault()
        let newState = {}

        // Workaround: Multiplying and dividing by zero to fix the floating point in js
        // https://stackoverflow.com/a/3439981/5942182
        newState[attribute] = ((state[attribute] - delta) * 10) / 10
        setState(newState)
      })

      increaseButton.on('click', (event) => {
        event.preventDefault()
        let newState = {}
        newState[attribute] = parseFloat(state[attribute]) + delta
        setState(newState)
      })
    }

    function getDosageLevelLabel(value) {
      if (value < 10)
        return "<i class='far fa-smile fa-lg green icon-large' aria-hidden='true'></i> " + "THRESHOLD DOSE"
      else if (value < 20)
        return "<i class='far fa-surprise fa-lg yellow icon-large' aria-hidden='true'></i> " + "COMMON DOSE"
      else if (value < 30)
        return "<i class='far fa-grimace fa-lg orange icon-large' aria-hidden='true'></i> " + "STRONG DOSE"
      else
        return "<i class='far fa-flushed fa-lg red icon-large' aria-hidden='true'></i> " + "HEAVY DOSE"
    }

    function renderPositiveEffects(value) {
      const LEVEL_ONE_POSITIVE_EFFECTS = [
        "relaxation",
        "stress reduction",
        "mood lift",
        "giggling",
        "laughing"
      ]

      const LEVEL_TWO_POSITIVE_EFFECTS = [
        "creative",
        "reduced nausea",
        "euphoria",
        "increased appetite",
        "tasks become more interesting"
      ]

      const LEVEL_THREE_POSITIVE_EFFECTS = [
        "enhanced senses",
        "philosophical",
        "ideas flow easily",
        "increase in body/mind connection"
      ]

      let effects = []
      if (value > 0 ) effects = [...LEVEL_ONE_POSITIVE_EFFECTS]
      if (value >= 10) effects = [...effects, ...LEVEL_TWO_POSITIVE_EFFECTS]
      if (value >= 20) effects = [...effects, ...LEVEL_THREE_POSITIVE_EFFECTS]

      return effects.map(effect => "<p class='badge badge-success badge-label'>" + effect + "</p> ").join('')
    }

    function renderNegativeEffects(value) {
      const LEVEL_ONE_NEGATIVE_EFFECTS = ["lightheadedness"]
      const LEVEL_TWO_NEGATIVE_EFFECTS = [
        "headaches",
        "paranoia",
        "short-term memory impairment"
      ]
      const LEVEL_THREE_NEGATIVE_EFFECTS = [
        "anxiety",
        "time perception altered",
        "nausea",
        "agitation"
      ]
      const LEVEL_FOUR_NEGATIVE_EFFECTS = [
        "racing heart",
        "loss of coordination",
        "panic attacks"
      ]

      let effects = [];

      if (value > 0) effects = [...LEVEL_ONE_NEGATIVE_EFFECTS]
      if (value >= 10) effects = [...effects, ...LEVEL_TWO_NEGATIVE_EFFECTS]
      if (value >= 20) effects = [...effects, ...LEVEL_THREE_NEGATIVE_EFFECTS]
      if (value >= 30) effects = [...effects, ...LEVEL_FOUR_NEGATIVE_EFFECTS]

      return effects.map(effect => "<p class='badge badge-danger badge-label'>" + effect + "</p> ").join('')
    }

    function render() {
      renderInputComponents('grams', $("#grams-input"), $("#grams-slider"))
      renderInputComponents('strength', $("#strength-input"), $("#strength-slider"))
      renderInputComponents('portions', $("#portion-input"), $("#portion-slider"))
      renderQuantityLabels()
      renderPotency()
      renderEffects()
      updateReferenceRecipes()
    }

    function renderInputComponents(attribute, input, slider) {
      if(input.val() !== state[attribute]) input.val(state[attribute]) // update input if slider has changed
      if(slider.val() !== state[attribute]) slider.slider('setValue', state[attribute]) // update slider if input has changed
    }

    function renderQuantityLabels() {
      $("#grams-quantity-label").text(pluralize("gram", state['grams']))
      $("#grams-quantity-recipe").text(pluralize("gram", state['grams'], true))
    }

    function renderPotency() {
      const currentDosage = getCurrentDosage()

      $("#potency-result").text(Number(currentDosage).toFixed(2) + " mg").animateCss('flash')
      $("#potency-result-total").text(Number(currentDosage * state['portions']).toFixed(1) + " mg").animateCss('flash')
      $("#highness-level").html(getDosageLevelLabel(currentDosage))
    }

    function renderEffects() {
      $("#positive-effect-details").html(renderPositiveEffects(getCurrentDosage()))
      $("#negative-effect-details").html(renderNegativeEffects(getCurrentDosage()))
    }

    function getMinimumBy(attribute) {
      if(attribute === 'grams') {
        return MINIMUM_QUANTITY
      } else if(attribute === 'strength') {
        return MINIMUM_STRENGTH
      } else if(attribute === 'portions') {
        return MINIMUM_PORTIONS
      }
    }

    function getMaximumBy(attribute) {
      if(attribute === 'grams') {
        return MAXIMUM_QUANTITY
      } else if(attribute === 'strength') {
        return MAXIMUM_STRENGTH
      } else if(attribute === 'portions') {
        return MAXIMUM_PORTIONS
      }
    }

    function checkAndSetStateRangeLimit(state) {
      const attribute = Object.keys(state)[0]
      const minimum = getMinimumBy(attribute)
      const maximum = getMaximumBy(attribute)

      if(state[attribute] < minimum)
        state[attribute] = minimum
      else if(state[attribute] > maximum)
        state[attribute] = maximum

      return state
    }

    function setState(newState) {
      newState = checkAndSetStateRangeLimit(newState)
      state = {...state, ...newState}
      render()
    }

    function getCurrentDosage() {
      return (10 * (state['grams'] * state['strength'])) / state['portions']
    }

    function updateReferenceRecipes() {
      $('.recipe-reference').each(function() {
        var link = $(this).attr('href').split('?')[0] + "?quantity=" + state['grams'] + "&potency=" + state['strength'] + "&portion=" + 1;
        $(this).attr('href', link);
      });
    }

    initialize();
  }
})