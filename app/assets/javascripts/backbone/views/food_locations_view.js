Mealyzer.Views.FoodLocationsView = Backbone.View.extend({

  initialize: function(params) {
    // Get food image source, used later.
    this.src = this.$('#food')[0].src;
    this.meal_id = params.meal_id;
    this.component_names = params.component_names;

    // Add any existing locations
    if (params.locations) {
      var self = this;
      jQuery("body")[0].onload = function(){ self.add_existing(params.locations); };
    }
  },

  events: {
    'click .btn-primary' : 'save'
  },

  // Adds boxes around existing food locations.
  add_existing: function(locations) {
    console.log('stuff')
    for (var l in locations) {
      anno.addAnnotation({ src: this.src, text: l, shapes: [{ type: 'rect', geometry: locations[l] }] });
    }
  },

  save: function(params) {
    if (!this.validate_component_names()) return;

    var data = { _method: 'put', meal: { food_locations: {} } };

    anno.getAnnotations().forEach(function(a) {
      data.meal.food_locations[a.text] = a.shapes[0].geometry;
    });

    // Save and redirect to index on success.
    jQuery.ajax({
      type: "PUT",
      url: "/meals/" + this.meal_id,
      data: JSON.stringify(data),
      contentType: "application/json"
    })
    .done(function(){
      window.location.href = "/meals";
    })
    .fail(function(){
      alert("Save failed.");
    });
  },

  validate_component_names: function() {
    var self = this;
    var valid = true;
    anno.getAnnotations().forEach(function(a) {
      if (self.component_names.indexOf(a.text) == -1) {
        alert("The component name '" + a.text + "' is invalid.");
        valid = false;
        return false;
      }
    });
    return valid;
  }
});