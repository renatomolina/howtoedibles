$(document).on('ready', function(){
  if($("#recipe_description").length !== 0) {
    var DELTA_QUANTITY = MINIMUM_QUANTITY = 0.5;
    var MAXIMUM_QUANTITY = 28;
    var DELTA_STRENGTH = DELTA_SERVINGS = 1;
    var MAXIMUM_STRENGTH = 95;
    var MAXIMUM_SERVINGS = 80;
    var MINIMUM_STRENGTH = 1;
    var MINIMUM_SERVINGS = 1;

    initialize = function(){
      this._initializeViews();
      this._initializeQuantities();
      this._updatePotency();
      this._initializeUpDownQuantityButtons();
      this._initializeUpDownStrengthButtons();
      this._initializeUpDownServingsButtons();
    };

    _initializeViews = function(){
      var that = this;
      $('#grams').slider({ id: 'green-bar'});
      $('#grams').on('change', function (slider){
        $("#grams-quantity").html(that._makeBold(pluralize(I18n.gram_label, slider.value.newValue.toFixed(1), true)));
        $("#grams-quantity-recipe").text(pluralize(I18n.gram_label, slider.value.newValue.toFixed(1), true));
        that._updatePotency();
      });

      $('#strength').slider({ id: 'green-bar'});
      $('#strength').on('change', function (slider){
        $("#strength-quantity").html(that._makeBold("THC: " + slider.value.newValue + " %"));
        that._updatePotency();
      });

      $('#number-of-servings').slider({ id: 'green-bar'});
      $('#number-of-servings').on('change', function (slider){
        $("#servings-quantity").html(that._makeBold(pluralize(I18n.portion_label, slider.value.newValue, true)));
        that._updatePotency();
      });

      $('.close-harm-warning').click(function(event){
        event.preventDefault();
        $('.harm-reduction-warning').fadeOut('slow', function() {
          this.hide();
        });
      });
    };

    _makeBold = function(text) {
      return "<strong>" + text + "</strong>";
    }

    _initializeQuantities = function() {
      $("#grams-quantity-recipe").text(pluralize(I18n.gram_label, parseFloat($('#grams')[0].value).toFixed(1), true));
      $("#grams-quantity").html(this._makeBold(pluralize(I18n.gram_label, parseFloat($('#grams')[0].value).toFixed(1), true)));
      $("#strength-quantity").html(this._makeBold('THC: ' + $('#strength')[0].value + " %"));
      $("#servings-quantity").html(this._makeBold(pluralize(I18n.portion_label, parseInt($('#number-of-servings')[0].value) , true)));
    };

    _initializeUpDownQuantityButtons = function() {

      var that = this;
      $("#decrease-quantity").click(function(event){
        event.preventDefault();

        var grams = parseFloat($('#grams')[0].value);
        if(grams > MINIMUM_QUANTITY) {
          $('#grams').slider('setValue', grams - DELTA_QUANTITY);
          $("#grams-quantity").html(that._makeBold(pluralize(I18n.gram_label, (grams - DELTA_QUANTITY).toFixed(1), true)));
          $("#grams-quantity-recipe").text(pluralize(I18n.gram_label, (grams - DELTA_QUANTITY).toFixed(1), true));
          that._updatePotency();
        }
      });

      $("#increase-quantity").click(function(event){
        event.preventDefault();

        var grams = parseFloat($('#grams')[0].value);

        if(grams < MAXIMUM_QUANTITY) {
          $('#grams').slider('setValue', grams + DELTA_QUANTITY);
          $("#grams-quantity").html(that._makeBold(pluralize(I18n.gram_label, (grams + DELTA_QUANTITY).toFixed(1), true)));
          $("#grams-quantity-recipe").text(pluralize(I18n.gram_label, (grams + DELTA_QUANTITY).toFixed(1), true));
          that._updatePotency();
        }
      });
    };

    _initializeUpDownStrengthButtons = function() {

      var that = this;
      $("#decrease-strength").click(function(event){
        event.preventDefault();

        var strength = parseInt($('#strength')[0].value);

        if(strength > MINIMUM_STRENGTH) {
          $('#strength').slider('setValue', parseInt(strength - DELTA_QUANTITY));
          $("#strength-quantity").html(that._makeBold("THC: " + parseInt(strength - DELTA_STRENGTH) + " %"));
          that._updatePotency();
        }
      });

      $("#increase-strength").click(function(event){
        event.preventDefault();

        var strength = parseInt($('#strength')[0].value);

        if(strength < MAXIMUM_STRENGTH) {
          $('#strength').slider('setValue', parseInt(strength + DELTA_STRENGTH));
          $("#strength-quantity").html(that._makeBold("THC: " + parseInt(strength + DELTA_STRENGTH) + " %"));
          that._updatePotency();
        }
      });
    };

    _initializeUpDownServingsButtons = function() {

      var that = this;
      $("#decrease-servings").click(function(event){
        event.preventDefault();

        var numberOfServings = parseInt($('#number-of-servings')[0].value);

        if(numberOfServings > MINIMUM_SERVINGS) {
          $('#number-of-servings').slider('setValue', parseInt(numberOfServings - DELTA_SERVINGS));
          $("#servings-quantity").html(that._makeBold(pluralize(I18n.portion_label, parseInt(numberOfServings - DELTA_SERVINGS), true)));
          that._updatePotency();
        }
      });

      $("#increase-servings").click(function(event){
        event.preventDefault();

        var numberOfServings = parseInt($('#number-of-servings')[0].value);

        if(numberOfServings < MAXIMUM_SERVINGS) {
          $('#number-of-servings').slider('setValue', parseInt(numberOfServings + DELTA_SERVINGS));
          $("#servings-quantity").html(that._makeBold(pluralize(I18n.portion_label, parseInt(numberOfServings + DELTA_SERVINGS), true)));
          that._updatePotency();
        }
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
         effects = effects.concat([I18n.creative_label, I18n.reduced_nausea_label, I18n.euphoria_label, I18n.increased_appetite_label, I18n.tasks_label]);
      if (value > 20)
        effects = effects.concat([I18n.philosophical_label, I18n.senses_label, I18n.ideas_label, I18n.mind_body_label]);

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

      if (value > 10)
        effects = effects.concat([I18n.headaches_label, I18n.lightheadedness_label, I18n.paranoia_label]);
      if (value > 20)
        effects = effects.concat([I18n.time_sense_label, I18n.anxiety_label, I18n.nausea_label, I18n.agitation_label]);
      if(value > 30)
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

