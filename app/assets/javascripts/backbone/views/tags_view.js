Mealyzer.Views.TagsView = Backbone.View.extend({

  initialize: function(params) {
    // Make current image annotatable
    anno.makeAnnotatable(document.getElementById('food'));

    // Hack to hide annotator pop up and save after drawn
    anno.addHandler('onSelectionCompleted', function(event) {
      $('.annotorious-editor-text').val('Add description');
      $('.annotorious-editor-button-save').simulate("click");
    });

  },

  events: {
    'click .next' : 'save_annotations'
  },

  save_annotations: function(params) {
    // Get all of the rectangles drawn by the user
    var rectangles = [];
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