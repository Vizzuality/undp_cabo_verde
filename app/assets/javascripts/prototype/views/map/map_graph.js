(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};
  root.app.Collection = root.app.Collection || {};

  var Status = Backbone.Model.extend({
    defaults: { visible: false }
  });

  root.app.View.mapGraphView = Backbone.View.extend({

    initialize: function(options) {
      this.router = options.router;
      this.status = new Status();
      this.collection = new root.app.Collection.relationshipsCollection();

      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(this.status, 'change:visible', this.toggleVisibility);
    },

    /* Fetch the relations. Return a deferred oject. */
    fetchRelations: function() {
      var deferred = $.Deferred();

      this.collection.fetch()
        .done(deferred.resolve)
        .fail(function() {
          console.warn('Unable to fetch the relations');
          deferred.reject();
        });

      return deferred;
    },

    render: function() {
      var relations = this.collection.toJSON();

      var startLatLng, endLatLng, colorClass;
      this.relationsLayer = L.layerGroup(_.compact(_.map(relations,
        function(relation) {
        /* We make sure we have the start and end locations */
        if(_.isEmpty(relation.start_location) ||
          _.isEmpty(relation.end_location)) {
          return;
        }

        startLatLng = L.latLng(relation.start_location.lat,
          relation.start_location.long);
        endLatLng = L.latLng(relation.end_location.lat,
          relation.end_location.long);

        switch(relation.type) {
          case 'Actor-Actor':
            colorClass = '-actors';
            break;
          case 'Action-Action':
            colorClass = '-actions';
            break;
          default:
            colorClass = '-mixed';
            break;
        }

        return L.polyline([startLatLng, endLatLng], {
          className: 'map-line ' + colorClass
        });
      })));
    },

    /* Toggle the visibility of all the relations */
    toggleVisibility: function() {
      var isVisible = this.status.get('visible');

      if(isVisible) {
        if(this.relationsLayer) {
          if(!this.map.hasLayer(this.relationsLayer)) {
            this.relationsLayer.addTo(this.map);
          }
        } else {
          this.fetchRelations()
            .then(this.render.bind(this))
            .then(function() {
              this.relationsLayer.addTo(this.map);
            }.bind(this));
        }
      } else {
        if(this.relationsLayer && this.map.hasLayer(this.relationsLayer)) {
          this.map.removeLayer(this.relationsLayer);
        }
      }
    }

  });

})(this);
