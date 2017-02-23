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
      return "<i class='fa fa-check-circle fa-lg green' aria-hidden='true'></i> Low dose";
    else if (value < 20)
      return "<i class='fa fa-exclamation-circle fa-lg yellow' aria-hidden='true'></i> Medium dose";
    else if (value < 30)
      return "<i class='fa fa-exclamation-circle fa-lg orange' aria-hidden='true'></i> Strong dose";
    else
      return "<i class='fa fa-exclamation-circle fa-lg red' aria-hidden='true'></i> Very Strong dose";
  }

  getHighPositiveDescription = function(value) {
    var effects = [];
    var result = "";

    effects = effects.concat(["relaxation", "stress reduction", "mood lift", "giggling", "laughing"]);

    if (value > 10)
       effects = effects.concat(["creative", "reduced nausea", "euphoria", "increased appetite", "tasks become more interesting"]);
    if (value > 20)
      effects = effects.concat(["philosophical", "increased awareness of senses", "ideas flow easily", "increase in body/mind connection"]);

    for(var i = 0 in effects) {
      result += "<span class='label label-success'>" + effects[i] + "</span> ";
    }
    return result;
  }

  getHighNegativeDescription = function(value) {
    var effects = [];
    var result = "";

    effects = effects.concat(["difficulty with short-term memory"]);

    if (value > 10)
      effects = effects.concat(["headaches", "lightheadedness", "paranoia"]);
    if (value > 20)
      effects = effects.concat(["time sense altered", "anxiety", "nausea", "agitation"]);
    if(value > 30)
      effects = effects.concat(["racing heart", "loss of coordination", "panic attacks"]);

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
    $("#servings-quantity").text(pluralize('portion', parseInt($('#number-of-servings')[0].value) , true));
  };

  initializeViews = function(){
    $('#grams').slider({ id: 'green-bar'});
    $('#grams').on('slide',function (slider){
      $("#grams-quantity").text(pluralize('gram', slider.value, true));
      $("#grams-quantity-recipe").text(pluralize('gram', slider.value, true));
      updatePotency();
    });

    $('#strength').slider({ id: 'green-bar'});
    $('#strength').on('slide',function (slider){
      $("#strength-quantity").text("THC: " + slider.value + " %");
      updatePotency();
    });

    $('#number-of-servings').slider({ id: 'green-bar'});
    $('#number-of-servings').on('slide',function (slider){
      $("#servings-quantity").text(pluralize('portion', slider.value, true));
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
