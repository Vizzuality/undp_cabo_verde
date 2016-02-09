(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};
  root.app.Helper = root.app.Helper || {};
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

    /* Return the relations of the passed model */
    extractRelations: function(model) {
      var collections = [
        {
          relations: model.get('actors').parents,
          type:       'actors',
          hierarchy:  'parents'
        },
        {
          relations: model.get('actors').children,
          type:       'actors',
          hierarchy:  'children'
        },
        {
          relations: model.get('actions').parents,
          type:       'actions',
          hierarchy:  'parents'
        },
        {
          relations: model.get('actions').children,
          type:       'actions',
          hierarchy:  'children'
        }
      ];

      return _.reduce(_.map(collections, function(collection) {
        return _.each(_.clone(collection.relations), function(relation) {
          relation.type = collection.type;
          relation.hierarchy = collection.hierarchy;
        });
      }), function(memo, collection) {
        return _.union(memo, collection);
      }, []);
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
      var relations = this.extractRelations(model);

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

        if(!relation) {
          console.warn('Unable to find the information about the relations of' +
            ' /'+ relatedMarker.options.type + '/' + relatedMarker.options.id);
          return false;
        }

        /* In case the user filtered the dates in the search form, we make sure
         * to display only the relations that exist in the range */
        var queryParams = this.router.getQueryParams();
        if(relation.info && (queryParams.start_date || queryParams.end_date)) {
          if(relation.info.start_date &&
            !root.app.Helper.utils.isDateBetween(relation.info.start_date, queryParams.start_date, queryParams.end_date) ||
            relation.info.end_date &&
            !root.app.Helper.utils.isDateBetween(relation.info.end_date, queryParams.start_date, queryParams.end_date)) {
            return false;
          }
        }

        /* In case we're filtering a specific date with the timeline, we want
         * to check if the relation can be displayed */
        if(this.lastFilterDate && relation.info) {
          if(relation.info.start_date &&
            this.lastFilterDate < (new Date(relation.info.start_date)).getTime() ||
            relation.info.end_date &&
            this.lastFilterDate > (new Date(relation.info.end_date)).getTime()) {
            return false;
          }
        }

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

    /* Save the filtering options passed as paramters */
    setFiltering: function(options) {
      if(_.isEmpty(options)) {
        this.lastFilterDate = null;
      } else if(options.date) {
        this.lastFilterDate = options.date;
      }
    }

  });

})(this);
