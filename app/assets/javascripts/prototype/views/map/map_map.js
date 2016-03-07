(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};
  root.app.Helper = root.app.Helper || {};

  root.app.View.mapMapView = Backbone.View.extend({

    initialize: function(options) {
      this.router = options.router;
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

    start: function() {
      this.render();
    },

    render: function() {
      L.mapbox.accessToken = root.app.Helper.globals.mapToken;

      this.map = L.mapbox.map('map', 'undp-caboverde.b3dd420c', {
        center: [20.5, 26],
        zoom: 3
      });

      this.map.zoomControl.setPosition('bottomleft');
      this.map.on('click',   this.onMapClick.bind(this));
      this.map.on('zoomend', this.onZoomEnd.bind(this));

      /* We could directly trigger the event but as the map could be
       * asynchronous, we prefer to let this structure */
      this.onMapRendered();
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
    },

    /* Center the map to the latLng object or array of coordinates passed as
     * argument */
    centerMap: function(latLng) {
      if(this.map) {
        this.map.panTo(latLng);
      }
    }
  });

})(this);
