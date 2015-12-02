(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};

  root.app.View.mapView = Backbone.View.extend({

    initialize: function(options) {
      this.actorsCollection = options.actorsCollection;
      this.renderMap();
      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(this.actorsCollection, 'sync', this.addMarkers);
    },

    renderMap: function() {
      if(!this.map) {
        this.map = new L.Map('map', {
          center: [14.91, -23.51],
          zoom: 14
        });
      }

      cartodb.createLayer(this.map,
        'https://simbiotica.cartodb.com/api/v2/viz/d26b8254-78d1-11e5-b910-0ecfd53eb7d3/viz.json')
        .addTo(this.map)
        .on('error', function(error) {
          console.error('Unable to render the map: ' + error);
        });
    },

    addMarkers: function() {
      _.each(this.actorsCollection.toJSON(), function(actor) {
        _.each(actor.locations, function(location) {
          L.marker([location.lat, location.long]).addTo(this.map);
        }, this);
      }, this);
    }

  });

})(this);
