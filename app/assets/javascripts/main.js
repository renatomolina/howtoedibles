$(document).on('turbolinks:load', function(){

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
    $("#high-level").text(getHighLevel(result));

    //$("#positive-effect-details").animateCss('flash');
    $("#positive-effect-details").text(getHighPositiveDescription(result));

    //$("#negative-effect-details").animateCss('flash');
    $("#negative-effect-details").text(getHighNegativeDescription(result));
  };

  getHighLevel = function(value) {
    if (value < 10)
      return "Low dose";
    else if (value < 20)
      return "Medium dose";
    else if (value < 30)
      return "Strong dose";
    else
      return "Very Strong dose";
  }

  getHighPositiveDescription = function(value) {
    if (value < 10)
      return "Relaxation, stress reduction, mood lift, increased giggling and laughing.";
    else if (value < 20)
      return "Relaxation, pain releaf, stress reduction, mood lift, giggling and laughing, creative, boring tasks become more interesting or funny, reduced nausea and increased appetite.";
    else if (value > 20)
      return "Relaxation, pain releaf, stress reduction, mood lift, giggling and laughing, creative, philosophical, ideas flow more easily, boring tasks can become more interesting, reduced nausea, increased awareness of senses, change in experience of muscle fatigue and increase in body/mind connection.";
  }

  getHighNegativeDescription = function(value) {
    if (value < 10)
      return "Difficulty with short-term memory during effects";
    else if (value < 20)
      return "Difficulty with short-term memory during effects, headaches, lightheadedness, paranoid.";
    else if (value < 30)
      return "Difficulty with short-term memory during effects, headaches, lightheadedness, paranoid, time sense altered, mild to high anxiety, nausea and agitation.";
    else
      return "Difficulty with short-term memory during effects, headaches, lightheadedness, paranoid, time sense altered, racing heart, loss of coordination, severe anxiety or panic attacks, nausea and agitation.";
  }

  initializeQuantities = function (){
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
