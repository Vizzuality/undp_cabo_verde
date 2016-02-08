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

    onRelationHover: function(relation, title) {
      relation.setText(title, { center: true, offset: -10,
        class: 'map-text', arrow: true });
    },

    onRelationBlur: function(relation) {
      relation.setText(null);
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

      var line, hiddenLine;

      /* We compute the relations */
      var model = marker.options.type === 'actors' ? this.actorModel :
        this.actionModel;
      var relations = _.each(_.union(model.get('actors').parents,
        model.get('actors').children), function(relation) {
          relation.type = 'actors';
        });
      relations.push(_.each(_.union(model.get('actions').parents,
        model.get('actions').children), function(relation) {
          relation.type = 'actions';
        }));
      relations = _.flatten(relations);

      var relation;
      this.relationsLayer = L.layerGroup(_.compact(_.flatten(_.map(relatedMarkers,
        function(relatedMarker) {

        var options = { className: 'map-line js-line' };

        if(relatedMarker.options.type !== marker.options.type) {
          options.dashArray = '3, 6';
        }

        if(!this.status.get('relationshipsVisible')) {
          options.className += ' -hidden';
        }

        line = L.polyline([ markerLatLng, relatedMarker.getLatLng() ], options);

        /* hiddenLine is an hidden line on top of the other, transparent, which
         * is used to trigger the pointer events on a wider zone (its stroke is
         * bigger and not dashed) */
        options.className += ' -sensitive';
        delete options.dashArray;
        hiddenLine = L.polyline([ markerLatLng, relatedMarker.getLatLng() ],
          options);

        relation = _.findWhere(relations, {
          type: relatedMarker.options.type,
          id:   relatedMarker.options.id
        });

        if(relation && relation.info) {
          hiddenLine.on('mouseover', (function(line, relation) {
            return function() {
              this.onRelationHover(line, relation.info.title);
            };
          })(line, relation).bind(this));
          hiddenLine.on('mouseout', (function(line) {
            return function() {
              this.onRelationBlur(line);
            };
          })(line).bind(this));
        }

        return [ line, hiddenLine ];
      }, this))));

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
