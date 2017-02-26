  $(document).on('ready', function(){

  updatePotency = function (){
    var grams = $('#grams')[0].value;
    var strength = $('#strength')[0].value;
    var numberOfServings = $('#number-of-servings')[0].value;

    var result = ((10 * (grams * strength)) / numberOfServings);
    $("#potency-result").animateCss('flash');
    $("#potency-result").text(Number(result).toFixed(2) + " mg");

    $("#potency-result-total").animateCss('flash');
    $("#potency-result-total").text(Number(result * numberOfServings).toFixed(0) + " mg");

    //$("#high-level").animateCss('flash');
    $("#high-level").html(getHighLevel(result));

    //$("#positive-effect-details").animateCss('flash');
    $("#positive-effect-details").html(getHighPositiveDescription(result));

    //$("#negative-effect-details").animateCss('flash');
    $("#negative-effect-details").html(getHighNegativeDescription(result));
  };

  getHighLevel = function(value) {
    if (value < 10)
      return "<i class='fa fa-check-circle fa-lg green' aria-hidden='true'></i> " + I18n.step2_low_dose;
    else if (value < 20)
      return "<i class='fa fa-exclamation-circle fa-lg yellow' aria-hidden='true'></i> " + I18n.step2_medium_dose;
    else if (value < 30)
      return "<i class='fa fa-exclamation-circle fa-lg orange' aria-hidden='true'></i> " + I18n.step2_strong_dose;
    else
      return "<i class='fa fa-exclamation-circle fa-lg red' aria-hidden='true'></i> " + I18n.step2_very_strong_dose;
  }

  getHighPositiveDescription = function(value) {
    var effects = [];
    var result = "";

    effects = effects.concat([I18n.relaxation_label, I18n.stress_reduction_label, I18n.mood_lift_label, I18n.giggling_label, I18n.laughing_label]);

    if (value > 10)
       effects = effects.concat([I18n.creative_label, I18n.reduced_nausea_label, I18n.euphoria_label, I18n.increased_appetite_label, I18n.tasks_label]);
    if (value > 20)
      effects = effects.concat([I18n.philosophical_label, I18n.senses_label, I18n.ideas_label, I18n.mind_body_label]);

    for(var i = 0 in effects) {
      result += "<span class='label label-success'>" + effects[i] + "</span> ";
    }
    return result;
  }

  getHighNegativeDescription = function(value) {
    var effects = [];
    var result = "";

    effects = effects.concat([I18n.memory_label]);

    if (value > 10)
      effects = effects.concat([I18n.headaches_label, I18n.lightheadedness_label, I18n.paranoia_label]);
    if (value > 20)
      effects = effects.concat([I18n.time_sense_label, I18n.anxiety_label, I18n.nausea_label, I18n.agitation_label]);
    if(value > 30)
      effects = effects.concat([I18n.racing_heart_label, I18n.coordination_label, I18n.panic_attacks_label]);

    return getLabelTags(effects, 'danger');;
  }

  getLabelTags = function(effects, type) {
    var result = "";
    for(var i = 0 in effects) {
      result = "<span class='label label-" + type +"'>" + effects[i] + "</span> " + result;
    }
    return result;
  }

  initializeQuantities = function() {
    $("#grams-quantity-recipe").text(pluralize('gram', $('#grams')[0].value, true));
    $("#grams-quantity").text(pluralize('gram', $('#grams')[0].value, true));
    $("#strength-quantity").text('THC: ' + $('#strength')[0].value + " %");
    $("#servings-quantity").text(pluralize(I18n.portion_label, parseInt($('#number-of-servings')[0].value) , true));
  };

  initializeViews = function(){
    $('#grams').slider({ id: 'green-bar'});
    $('#grams').on('change',function (slider){
      $("#grams-quantity").text(pluralize(I18n.gram_label, slider.value.newValue, true));
      $("#grams-quantity-recipe").text(pluralize(I18n.gram_label, slider.value.newValue, true));
      updatePotency();
    });

    $('#strength').slider({ id: 'green-bar'});
    $('#strength').on('change',function (slider){
      $("#strength-quantity").text("THC: " + slider.value.newValue + " %");
      updatePotency();
    });

    $('#number-of-servings').slider({ id: 'green-bar'});
    $('#number-of-servings').on('change',function (slider){
      $("#servings-quantity").text(pluralize(I18n.portion_label, slider.value.newValue, true));
      updatePotency();
    });
  };

  initialize = function(){
    initializeViews();
    initializeQuantities();
    updatePotency();
  };

  initialize();
});
