Mealyzer.Views.MatchesView = Backbone.View.extend({

  initialize: function(params) {

    console.log(params);

    console.log(params.source);

    // Make current image annotatable
    anno.makeAnnotatable(document.getElementById("photo_"+params.id));
    // hiding selection widget prevents editing
    anno.hideSelectionWidget();

    // create a new annotation
    var a = {
      src: params.source,
      text: params.name,
      editable: false,
      shapes: [{
        type: 'rect',
        geometry: params.geometry
      }]
    };

    // add and show annotation
    anno.addAnnotation(a);
    anno.highlightAnnotation(a);
  },

});
