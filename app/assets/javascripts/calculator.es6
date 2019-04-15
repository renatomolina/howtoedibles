$(document).on('ready', function() {
  console.log('renato');
  if($("#calculator-widget").length !== 0) {
    const DELTA_QUANTITY = 0.5, DELTA_STRENGTH = 1, DELTA_SERVINGS = 1
    const MINIMUM_QUANTITY = 0.5, MAXIMUM_QUANTITY = 28
    const MINIMUM_STRENGTH = 1, MAXIMUM_STRENGTH = 95
    const MINIMUM_PORTIONS = 1, MAXIMUM_PORTIONS = 200

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

      setListenerUpDownButton('grams', $("#decrease-quantity"), $("#increase-quantity"), DELTA_QUANTITY)
      setListenerUpDownButton('strength', $("#decrease-strength"), $("#increase-strength"), DELTA_STRENGTH)
      setListenerUpDownButton('portions', $("#decrease-servings"), $("#increase-servings"), DELTA_SERVINGS)
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
        return "<i class='fa fa-check-circle fa-lg green' aria-hidden='true'></i> " + I18n.step2_low_dose
      else if (value < 20)
        return "<i class='fa fa-exclamation-circle fa-lg yellow' aria-hidden='true'></i> " + I18n.step2_medium_dose
      else if (value < 30)
        return "<i class='fa fa-exclamation-circle fa-lg orange' aria-hidden='true'></i> " + I18n.step2_strong_dose
      else
        return "<i class='fa fa-exclamation-circle fa-lg red' aria-hidden='true'></i> " + I18n.step2_very_strong_dose
    }

    function renderPositiveEffects(value) {
      const LEVEL_ONE_POSITIVE_EFFECTS = [
        I18n.relaxation_label,
        I18n.stress_reduction_label,
        I18n.mood_lift_label,
        I18n.giggling_label,
        I18n.laughing_label
      ]

      const LEVEL_TWO_POSITIVE_EFFECTS = [
        I18n.creative_label,
        I18n.euphoria_label,
        I18n.reduced_nausea_label,
        I18n.increased_appetite_label,
        I18n.tasks_label
      ]

      const LEVEL_THREE_POSITIVE_EFFECTS = [I18n.senses_label, I18n.philosophical_label, I18n.ideas_label, I18n.mind_body_label]

      let effects = []
      if (value > 0 ) effects = [...LEVEL_ONE_POSITIVE_EFFECTS]
      if (value > 10) effects = [...effects, ...LEVEL_TWO_POSITIVE_EFFECTS]
      if (value > 20) effects = [...effects, ...LEVEL_THREE_POSITIVE_EFFECTS]

      return effects.map(effect => "<p class='badge badge-success badge-label'>" + effect + "</p> ").join('')
    }

    function renderNegativeEffects(value) {
      const LEVEL_ONE_NEGATIVE_EFFECTS = [I18n.lightheadedness_label]
      const LEVEL_TWO_NEGATIVE_EFFECTS = [I18n.headaches_label, I18n.memory_label, I18n.paranoia_label]
      const LEVEL_THREE_NEGATIVE_EFFECTS = [I18n.anxiety_label, I18n.time_sense_label, I18n.nausea_label, I18n.agitation_label]
      const LEVEL_FOUR_NEGATIVE_EFFECTS = [I18n.racing_heart_label, I18n.coordination_label, I18n.panic_attacks_label]

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
    }

    function renderInputComponents(attribute, input, slider) {
      if(input.val() !== state[attribute]) input.val(state[attribute]) // update input if slider has changed
      if(slider.val() !== state[attribute]) slider.slider('setValue', state[attribute]) // update slider if input has changed
    }

    function renderQuantityLabels() {
      $("#grams-quantity-label").text(pluralize(I18n.gram_label, state['grams']))
      $("#grams-quantity-recipe").text(pluralize(I18n.gram_label, state['grams'], true))
    }

    function renderPotency() {
      const currentDosage = getCurrentDosage()

      $("#potency-result").text(Number(currentDosage).toFixed(2) + " mg").animateCss('flash')
      $("#potency-result-total").text(Number(currentDosage * state['portions']).toFixed(0) + " mg").animateCss('flash')
      $("#high-level").html(getDosageLevelLabel(currentDosage))
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

    initialize()
  }
})