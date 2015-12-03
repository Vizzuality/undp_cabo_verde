(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};

  root.app.View.mapView = Backbone.View.extend({

    el: '.l-map',

    initialize: function(options) {
      this.actorsCollection = options.actorsCollection;
      /* queue is an array of methods and arguments ([ func, args ]) that is
       * stored in order to wait for the map to be instanced. Once done, each
       * queue's methods are called. The queue is FIFO. */
      this.queue = [];
      this.renderMap();
      /* We make a first call to addMarkers in order to make sure to add them
       * in case the collection would be populated before the view would be
       * instanced */
      this.addActorsMarkers();
      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(this.actorsCollection, 'sync change', this.addActorsMarkers);
      this.map.on('zoomend', this.updateMarkersSize.bind(this));
    },

    renderMap: function() {
      if(!this.map) {
        this.map = new L.Map('map', {
          center: [14.91, -23.51],
          zoom: 13,
          minZoom: 8,
          maxBounds: [
            L.latLng(13.637819, -28.389729),
            L.latLng(18.228372, -19.292213)
          ]
        });
      }

      this.isMapInstanciated = false;
      cartodb.createLayer(this.map,
        'https://simbiotica.cartodb.com/api/v2/viz/d26b8254-78d1-11e5-b910-0ecfd53eb7d3/viz.json')
        .addTo(this.map)
        .on('done', function() {
          this.isMapInstanciated = true;
          this.applyQueue();
        }.bind(this))
        .on('error', function(error) {
          console.error('Unable to render the map: ' + error);
        });
    },

    /* Add the markers for the actors
     * NOTE: we debounce the method so it's not called twice because the
     * collection gets populated right after this view is instanciated */
    addActorsMarkers: _.debounce(function() {
      if(!this.isMapInstanciated) {
        this.queue.push([this.addActorsMarkers, null]);
        return;
      }

      /* Return the icon corresponding to each specific actor */
      var makeIcon = function(actorLevel) {
        return L.divIcon({
          html: '<div class="map-marker -' + actorLevel+ '"></div>',
          className: 'actor',
          iconSize: L.point(12, 12),
          iconAnchor: L.point(6, 6)
        });
      };

      _.each(this.actorsCollection.toJSON(), function(actor) {
        _.each(actor.locations, function(location) {
          L.marker([location.lat, location.long], {
            icon: makeIcon(actor.level)
          }).addTo(this.map);
        }, this);
      }, this);
    }, 15),

    /* Update the markers' size according to the map's zoom level */
    updateMarkersSize: function() {
      if(!this.isMapInstanciated) {
        this.queue.push([this.updateMarkersSize, null]);
        return;
      }

      var zoom = this.map.getZoom();
      /* We don't want the markers to be smaller than 5px but also no bigger
       * than 12px. To do so, we use the css transform: scale property and bound
       * it to values between .42 and 1 (default marker's size is 12px). We
       * consider 13 the level from which makers' size shouldn't change. */
       var scale;
       if(zoom <= 5)       { scale = 0.42; }
       else if(zoom >= 13) { scale = 1; }
       else                { scale = zoom / 13; }

       this.$el.find('.map-marker').css('transform', 'scale(' + scale + ')');
    },

    /* Call all the methods stored in this.queue in order */
    applyQueue: function() {
      _.each(this.queue, function(method) {
        if(!method || method.length < 2 || typeof method[0] !== 'function') {
          console.warn('Unable to execute a queue\'s method');
        } else {
          method[0].apply(this, method[1]);
        }
      }, this);
    }

  });

})(this);
