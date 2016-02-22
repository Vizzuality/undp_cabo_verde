(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};
  root.app.Helper = root.app.Helper || {};
  root.app.pubsub = root.app.pubsub || {};

  var Status = Backbone.Model.extend({
    defaults: { relationsVisible: true }
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

      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(this.status, 'change:relationsVisible',
        this.toggleRelationsVisibility);
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
      this.relationsLayer = null;
      this.relatedMarkers = null;
    },

    /* Render the relations of the marker passed as arguments with the other
     * ones (also passed as argument) */
    renderRelations: function(marker, relatedMarkers) {
      var markerLatLng = marker.getLatLng();

      this.relatedMarkers = relatedMarkers;

      var line, hiddenLine;

      /* We compute the relations */
      var model = marker.options.type === 'actors' ? this.actorModel :
        this.actionModel;
      var visibleRelations = model.getVisibleRelations();

      var relation;
      this.relationsLayer = L.layerGroup(_.compact(_.flatten(_.map(relatedMarkers,
        function(relatedMarker) {

        var options = { className: 'map-line js-line' };

        if(relatedMarker.options.type !== marker.options.type) {
          options.dashArray = '3, 6';
        }

        /* We add data so then we can filter the relations depending on whom
         * they're connected to */
        options.destinationEntity = {
          id:   relatedMarker.options.id,
          type: relatedMarker.options.type
        };

        line = L.polyline([ markerLatLng, relatedMarker.getLatLng() ], options);

        /* hiddenLine is an hidden line on top of the other, transparent, which
         * is used to trigger the pointer events on a wider zone (its stroke is
         * bigger and not dashed) */
        options.className += ' -sensitive';
        delete options.dashArray;
        hiddenLine = L.polyline([ markerLatLng, relatedMarker.getLatLng() ],
          options);

        relation = _.findWhere(visibleRelations, {
          type: relatedMarker.options.type,
          id:   relatedMarker.options.id
        });

        if(!relation) return false;

        if(relation.info) {
          hiddenLine.on('mouseover', (function(line, relation) {
            return function() {
              var title = relation.info[relation.hierarchy === 'parents' ?
                'title_reverse' : 'title'];
              this.onRelationHover(line, title);
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
      this.addRelationsToMap();
    },

    /* Filter the visible relations. Options can have the following params:
     *  - only { id, type }: only show the relation from the current selected
     *    actor/action to the entity matching the params
     */
    filterRelations: function(options) {
      if(options && _.isObject(options.only)) {
        var relations = this.relationsLayer.getLayers();
        var relation = _.find(relations, function(relation) {
          return relation.options.destinationEntity.type === options.only.type &&
            relation.options.destinationEntity.id === options.only.id;
        });
        this.map.removeLayer(this.relationsLayer);
        this.relationsLayer =  L.layerGroup([ relation ]);
        this.addRelationsToMap();
      }
    },

    /* Add the relations on the map if they can be shown */
    addRelationsToMap: function() {
      if(this.status.get('relationsVisible')) {
        this.relationsLayer.addTo(this.map);
      }
    },

    /* Toggle the visibility of the relations on the map depending on if they
     * can be shown */
    toggleRelationsVisibility: function() {
      if(this.relationsLayer) {
        if(this.status.get('relationsVisible')) {
          this.addRelationsToMap();
        } else {
          if(this.map.hasLayer(this.relationsLayer)) {
            this.map.removeLayer(this.relationsLayer);
          }
        }
      }
    }

  });

})(this);
