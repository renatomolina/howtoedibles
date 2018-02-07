$(document).on('ready', function(){
  if($("#calculator-widget").length !== 0) {
    var DELTA_QUANTITY = MINIMUM_QUANTITY = 0.5;
    var MAXIMUM_QUANTITY = 28;
    var DELTA_STRENGTH = DELTA_SERVINGS = MINIMUM_STRENGTH = MINIMUM_SERVINGS = 1;
    var MAXIMUM_STRENGTH = 95;
    var MAXIMUM_SERVINGS = 200;

    initialize = function() {
      this._initializeListeners();
      this._initializeQuantities();
      this._updatePotency();
      this._initializeUpDownQuantityButtons();
      this._initializeUpDownStrengthButtons();
      this._initializeUpDownServingsButtons();
    };

    _initializeListeners = function() {
      _initializeQuantitiesSlider();
      _initializeStrengthSlider();
      _initializePortionSlider();
    };

    _initializeQuantitiesSlider = function() {
      var that = this;

      $('#grams').slider({ id: 'green-bar'});
      $('#grams').on('change', function (slider){
        var quantity = slider.value.newValue.toFixed(1);

        that.updateQuantityLabel(quantity);
        that._updatePotency();
      });
    };

    _initializeStrengthSlider = function() {
      var that = this;

      $('#strength').slider({ id: 'green-bar'});
      $('#strength').on('change', function (slider){
        that.updateStrengthLabel(slider.value.newValue);
      });
    };

    _initializePortionSlider = function() {
      var that = this;

      $('#number-of-servings').slider({ id: 'green-bar'});
      $('#number-of-servings').on('change', function (slider){
        that.updatePortionLabel(slider.value.newValue);
      });
    };

    updateQuantityLabel = function(quantity, updateInput = true, updateSlider = false) {
      if (quantity < MINIMUM_QUANTITY) quantity = MINIMUM_QUANTITY;
      if (quantity > MAXIMUM_QUANTITY) quantity = MAXIMUM_QUANTITY;
      if(updateInput) $("#grams-quantity").val(quantity);
      if(updateSlider) $('#grams').slider('setValue', quantity);
      $("#grams-quantity-label").text(pluralize(I18n.gram_label, quantity));
      $("#grams-quantity-recipe").text(pluralize(I18n.gram_label, quantity, true));
      _updatePotency();
    };

    updateStrengthLabel = function(quantity, updateInput = true, updateSlider = false) {
      if (quantity < MINIMUM_STRENGTH) quantity = MINIMUM_STRENGTH;
      if (quantity > MAXIMUM_STRENGTH) quantity = MAXIMUM_STRENGTH;
      if(updateInput) $("#strength-quantity").val(quantity);
      if(updateSlider) $('#strength').slider('setValue', quantity);
      $("#strength-quantity").html(parseInt(quantity));
      _updatePotency();
    };

    updatePortionLabel = function(quantity, updateInput = true, updateSlider = false) {
      if (quantity < MINIMUM_SERVINGS) quantity = MINIMUM_SERVINGS;
      if (quantity > MAXIMUM_SERVINGS) quantity = MAXIMUM_SERVINGS;
      if(updateInput) $("#servings-quantity").val(quantity);
      if(updateSlider) $('#number-of-servings').slider('setValue', quantity);

      $("#servings-label").html(pluralize(I18n.portion_label, quantity));
      _updatePotency();
    };

    _initializeQuantities = function() {
      updateQuantityLabel(parseFloat($('#grams')[0].value).toFixed(1));
      updateStrengthLabel($('#strength')[0].value);
      updatePortionLabel($('#number-of-servings')[0].value)
    };

    _initializeUpDownQuantityButtons = function() {

      var that = this;
      $("#decrease-quantity").click(function(event){
        event.preventDefault();

        var grams = parseFloat($('#grams')[0].value);
        if(grams > MINIMUM_QUANTITY) that.updateQuantityLabel(grams - DELTA_QUANTITY, true, true);
      });

      $("#increase-quantity").click(function(event){
        event.preventDefault();

        var grams = parseFloat($('#grams')[0].value);
        if(grams < MAXIMUM_QUANTITY) that.updateQuantityLabel(grams + DELTA_QUANTITY, true, true);
      });
    };

    _initializeUpDownStrengthButtons = function() {

      var that = this;
      $("#decrease-strength").click(function(event){
        event.preventDefault();

        var strength = parseInt($('#strength')[0].value);
        if(strength > MINIMUM_STRENGTH) that.updateStrengthLabel(parseInt(strength - DELTA_STRENGTH), true, true);
      });

      $("#increase-strength").click(function(event){
        event.preventDefault();

        var strength = parseInt($('#strength')[0].value);
        if(strength < MAXIMUM_STRENGTH) that.updateStrengthLabel(parseInt(strength + DELTA_STRENGTH), true, true);
      });
    };

    _initializeUpDownServingsButtons = function() {

      var that = this;
      $("#decrease-servings").click(function(event){
        event.preventDefault();

        var numberOfServings = parseInt($('#number-of-servings')[0].value);
        if(numberOfServings > MINIMUM_SERVINGS) that.updatePortionLabel(parseInt(numberOfServings - DELTA_SERVINGS), true, true);
      });

      $("#increase-servings").click(function(event){
        event.preventDefault();

        var numberOfServings = parseInt($('#number-of-servings')[0].value);
        if(numberOfServings < MAXIMUM_SERVINGS) that.updatePortionLabel(parseInt(numberOfServings + DELTA_SERVINGS), true, true);
      });
    };

    _updatePotency = function (){
      var grams = $('#grams')[0].value;
      var strength = $('#strength')[0].value;
      var numberOfServings = $('#number-of-servings')[0].value;

      var result = ((10 * (grams * strength)) / numberOfServings);
      $("#potency-result").animateCss('flash');
      $("#potency-result").text(Number(result).toFixed(2) + " mg");

      $("#potency-result-total").animateCss('flash');
      $("#potency-result-total").text(Number(result * numberOfServings).toFixed(0) + " mg");

      $("#high-level").html(this._getHighLevel(result));
      $("#positive-effect-details").html(this._getHighPositiveDescription(result));
      $("#negative-effect-details").html(this._getHighNegativeDescription(result));
    };

    _getHighPositiveDescription = function(value) {
      var effects = [];
      var result = "";

      effects = effects.concat([I18n.relaxation_label, I18n.stress_reduction_label, I18n.mood_lift_label, I18n.giggling_label, I18n.laughing_label]);

      if (value > 10)
         effects = effects.concat([I18n.creative_label, I18n.euphoria_label, I18n.reduced_nausea_label, I18n.increased_appetite_label, I18n.tasks_label]);
      if (value > 20)
        effects = effects.concat([I18n.senses_label, I18n.philosophical_label, I18n.ideas_label, I18n.mind_body_label]);

      for(var i = 0 in effects) {
        result += "<p class='label label-success'>" + effects[i] + "</p> ";
      }
      return result;
    };

    _getHighLevel = function(value) {
      if (value < 10)
        return "<i class='fa fa-check-circle fa-lg green' aria-hidden='true'></i> " + I18n.step2_low_dose;
      else if (value < 20)
        return "<i class='fa fa-exclamation-circle fa-lg yellow' aria-hidden='true'></i> " + I18n.step2_medium_dose;
      else if (value < 30)
        return "<i class='fa fa-exclamation-circle fa-lg orange' aria-hidden='true'></i> " + I18n.step2_strong_dose;
      else
        return "<i class='fa fa-exclamation-circle fa-lg red' aria-hidden='true'></i> " + I18n.step2_very_strong_dose;
    }

    _getHighNegativeDescription = function(value) {
      var effects = [];
      var result = "";

      effects = effects.concat([I18n.memory_label]);

      if (value >= 10)
        effects = effects.concat([I18n.headaches_label, I18n.lightheadedness_label, I18n.paranoia_label]);
      if (value >= 20)
        effects = effects.concat([I18n.anxiety_label, I18n.time_sense_label, I18n.nausea_label, I18n.agitation_label]);
      if(value >= 30)
        effects = effects.concat([I18n.racing_heart_label, I18n.coordination_label, I18n.panic_attacks_label]);

      return this._getLabelTags(effects, 'danger');;
    }

    _getLabelTags = function(effects, type) {
      var result = "";
      for(var i = 0 in effects) {
        result = "<p class='label label-" + type +"'>" + effects[i] + "</p> " + result;
      }
      return result;
    }

    initialize();
  }
});

