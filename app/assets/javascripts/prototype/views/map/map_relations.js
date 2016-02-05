(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};
  root.app.pubsub = root.app.pubsub || {};

  var Status = Backbone.Model.extend({
    defaults: { relationshipsVisible: true }
  });

  root.app.View.mapRelationsView = Backbone.View.extend({

    el: '.l-map',

    initialize: function(options) {
      this.router = options.router;
      this.status = new Status();
      this.actorsCollection  = options.actorsCollection;
      this.actionsCollection = options.actionsCollection;
      this.actorModel =  options.actorModel;
      this.actionModel = options.actionModel;
    },

    /* Remove all the relations from the map */
    removeRelations: function() {
      if(this.map.hasLayer(this.relationsLayer)) {
        this.map.removeLayer(this.relationsLayer);
      }
      this.markerWithRelations = null;
      this.relatedMarkers = null;
    },

    /* Render the relations of the marker passed as arguments with the other
     * ones (also passed as argument) */
    renderRelations: function(marker, relatedMarkers) {
      var markerLatLng = marker.getLatLng();

      this.markerWithRelations = marker;
      this.relatedMarkers = relatedMarkers;

      var options = { className: 'map-line js-line' };
      this.relationsLayer = L.layerGroup(_.compact(_.map(relatedMarkers,
        function(relatedMarker) {

        if(relatedMarker.options.type !== marker.options.type) {
          options.dashArray = '3, 6';
        }

        if(!this.status.get('relationshipsVisible')) {
          options.className += ' -hidden';
        }

        return L.polyline([ markerLatLng, relatedMarker.getLatLng() ], options);
      }, this)));

      /* We finally add the relations to the map */
      this.relationsLayer.addTo(this.map);
    },

    /* Toggle the visibility of the map's relations */
    toggleRelationsVisibility: function() {
      if(!this.status.get('relationshipsVisible') &&
        this.map.hasLayer(this.relationsLayer)) {
        this.map.removeLayer(this.relationsLayer);
      } else if(this.markerWithRelations && this.relatedMarkers) {
        this.renderRelations(this.markerWithRelations, this.relatedMarkers);
      }
    },

  });

})(this);
