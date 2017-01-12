$(document).ready(function(){

  updatePotency = function (){
    var grams = $('#grams')[0].value;
    var strength = $('#strength')[0].value;
    var numberOfServings = $('#number-of-servings')[0].value;

    var result = ((10 * (grams * strength)) / numberOfServings);
    $("#potency-result").text(result + " mg each portion");
  };

  initializeQuantities = function (){
    $("#grams-quantity").text(pluralize('gram', $('#grams')[0].value, true));
    $("#strength-quantity").text($('#strength')[0].value + " %");
    $("#servings-quantity").text(pluralize('portion', $('#number-of-servings')[0].value, true));
  };

  initializeViews = function(){
    $('#grams').slider();
    $('#grams').on('slide',function (slider){
      $("#grams-quantity").text(pluralize('gram', slider.value, true));
      updatePotency();
    });

    $('#strength').slider();
    $('#strength').on('slide',function (slider){
      $("#strength-quantity").text(slider.value + " %");
      updatePotency();
    });

    $('#number-of-servings').slider();
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