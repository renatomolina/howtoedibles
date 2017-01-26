$(document).ready(function(){

  updatePotency = function (){
    var grams = $('#grams')[0].value;
    var strength = $('#strength')[0].value;
    var numberOfServings = $('#number-of-servings')[0].value;

    var result = ((10 * (grams * strength)) / numberOfServings);
    $("#potency-result").animateCss('flash');
    $("#potency-result").text(Number(result).toFixed(2) + " mg each portion");

    $("#high-level").animateCss('flash');
    $("#high-level").text(getHighLevel(result));
  };

  getHighLevel = function(value){
    if (value < 10)
      return "Low dose";
    else if (value < 20)
      return "Medium dose";
    else if (value < 30)
      return "Strong dose";
    else
      return "Very Strong dose";
  }

  initializeQuantities = function (){
    $("#grams-quantity").text(pluralize('gram', $('#grams')[0].value, true));
    $("#strength-quantity").text('THC: ' + $('#strength')[0].value + " %");
    $("#servings-quantity").text(pluralize('portion', $('#number-of-servings')[0].value, true));
  };

  initializeViews = function(){
    $('#grams').slider({ id: 'green-bar'});
    $('#grams').on('slide',function (slider){
      $("#grams-quantity").text(pluralize('gram', slider.value, true));
      updatePotency();
    });

    $('#strength').slider({ id: 'green-bar'});
    $('#strength').on('slide',function (slider){
      $("#strength-quantity").text("THC: " + slider.value + " %");
      updatePotency();
    });

    $('#number-of-servings').slider({ id: 'green-bar'});
    $('#number-of-servings').on('slide',function (slider){
      $("#servings-quantity").text(slider.value + " " + pluralize('portion', slider.val));
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
