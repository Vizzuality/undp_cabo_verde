(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};

  root.app.View.mapView = Backbone.View.extend({

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
      this.addMarkers();
    },

    setListeners: function() {
      this.listenTo(this.actorsCollection, 'change', this.addMarkers);
    },

    renderMap: function() {
      if(!this.map) {
        this.map = new L.Map('map', {
          center: [14.91, -23.51],
          zoom: 13
        });
      }

      this.isMapInstanced = false;
      cartodb.createLayer(this.map,
        'https://simbiotica.cartodb.com/api/v2/viz/d26b8254-78d1-11e5-b910-0ecfd53eb7d3/viz.json')
        .addTo(this.map)
        .on('done', function() {
          this.isMapInstanced = true;
          this.applyQueue();
        }.bind(this))
        .on('error', function(error) {
          console.error('Unable to render the map: ' + error);
        });
    },

    addMarkers: function() {
      if(!this.isMapInstanced) {
        this.queue.push([this.addMarkers, null]);
        return;
      }

      _.each(this.actorsCollection.toJSON(), function(actor) {
        _.each(actor.locations, function(location) {
          L.marker([location.lat, location.long]).addTo(this.map);
        }, this);
      }, this);
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
