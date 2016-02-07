(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};

  root.app.View.mapMapView = Backbone.View.extend({

    initialize: function(options) {
      this.router = options.router;
      this.render();
    },

    onMapClick: function() {
      this.trigger('click:map');
    },

    onZoomEnd: function() {
      this.trigger('zoom:map');
    },

    onMapRendered: function() {
      this.trigger('render:map', this.map);
    },

    render: function() {
      this.map = new L.Map('map', {
        center: [14.91, -23.51],
        zoom: 13,
        minZoom: 8,
        maxBounds: [
          L.latLng(13.637819, -28.389729),
          L.latLng(18.228372, -19.292213)
        ]
      });

      this.map.zoomControl.setPosition('bottomleft');
      this.map.on('click',   this.onMapClick.bind(this));
      this.map.on('zoomend', this.onZoomEnd.bind(this));

      cartodb.createLayer(this.map,
        'https://simbiotica.cartodb.com/api/v2/viz/d26b8254-78d1-11e5-b910-0ecfd53eb7d3/viz.json')
        .addTo(this.map)
        .on('done', this.onMapRendered.bind(this))
        .on('error', function(error) {
          console.error('Unable to render the map: ' + error);
        });
    },
  });

})(this);
