Mealyzer.Views.MobileSubmissionsView = Backbone.View.extend({

  initialize: function(params) {
    // Instantiate a slider
    var carbSlider = $('#carb').slider();
    var proteinSlider = $('#protein').slider();
    var fatSlider = $('#fat').slider();
    var fiberSlider = $('#fiber').slider();
  }

});