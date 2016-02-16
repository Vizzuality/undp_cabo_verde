(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};
  root.app.Helper = root.app.Helper || {};

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
      L.mapbox.accessToken = root.app.Helper.globals.mapToken;

      this.map = L.mapbox.map('map', 'undp-caboverde.b3dd420c', {
        center: [14.91, -23.51],
        zoom: 13
      });

      this.map.zoomControl.setPosition('bottomleft');
      this.map.on('click',   this.onMapClick.bind(this));
      this.map.on('zoomend', this.onZoomEnd.bind(this));

      /* We make sure to trigger the event once the map_view's setListeners
       * method is executed */
      setTimeout(function() {this.onMapRendered();}.bind(this), 15);
    },

    /* Zoom to fit the passed markers */
    zoomToFit: function(markers) {
      var latLngs = _.map(markers, function(m) {
        return m.options.originalLatLng || m.getLatLng();
      });
      /* We don't zoom if the markers have the same position */
      if(_.uniq(latLngs).length > 1) {
        this.map.fitBounds(latLngs, { padding: L.point(30, 30) });
      }
    }
  });

})(this);
