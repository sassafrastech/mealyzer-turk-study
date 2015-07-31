Mealyzer.Views.FoodLocationsView = Backbone.View.extend({

  initialize: function(params) {
    // Get food image source, used later.
    this.src = this.$('#food')[0].src;

    // Add any existing locations
    if (params.locations) {
      var self = this;
      jQuery("body")[0].onload = function(){ self.add_existing(params.locations); };
    }
  },

  events: {
    'click .next' : 'save_annotations'
  },

  // Adds boxes around existing food locations.
  add_existing: function(locations) {
    console.log('stuff')
    for (var l in locations) {
      anno.addAnnotation({ src: this.src, text: l, shapes: [{ type: 'rect', geometry: locations[l] }] });
    }
  },

  save_annotations: function(params) {
    // Get all of the rectangles drawn by the user
    var rectangles = [];
    console.log(anno.getAnnotations());
    return;
    anno.getAnnotations().forEach(function(a) {
      rectangles.push({ "x": a.shapes[0].geometry.x, "y": a.shapes[0].geometry.y,
      "width": a.shapes[0].geometry.width, "height": a.shapes[0].geometry.height});
    });

    // Convert rectangles to json
    var locations = (rectangles.length > 0) ? JSON.stringify(rectangles) : null;

    // Format parameter string and add meal id
    var data = { "answer" : {"food_locations" : locations, "meal_id" : $('#food').data("id")}};

    $.post("/tags/", data).done(function(data){ console.log("finished");});
  },

});