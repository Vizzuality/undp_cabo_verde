(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};
  root.app.pubsub = root.app.pubsub || {};

  root.app.View.mapView = Backbone.View.extend({

    el: '.l-map',

    events: {
      'change .js-relationships-checkbox': 'triggerRelationshipsVisibility'
    },

    initialize: function(options) {
      this.actorsCollection = options.actorsCollection;
      this.router = options.router;
      /* queue is an array of methods and arguments ([ func, args ]) that is
       * stored in order to wait for the map to be instanced. Once done, each
       * queue's methods are called. The queue's elements have a priority number
       * so the ones with the smallest number are executed first (FIFO). */
      this.queue = [];
      this.renderMap();
      /* We make a first call to addMarkers in order to make sure to add them
       * in case the collection would be populated before the view would be
       * instanced */
      this.addActorsMarkers();
      this.$legend = this.$el.find('#map-legend');
      this.$relationshipsToggle = this.$el.find('.js-relationships-checkbox');
      this.$buttons = this.$el.find('#map-buttons');
      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(this.actorsCollection, 'sync change', this.addActorsMarkers);
      this.listenTo(this.router, 'route', this.updateMapFromRoute);
      this.listenTo(root.app.pubsub, 'relationships:visibility',
        this.toggleRelationshipsVisibility);
      this.listenTo(root.app.pubsub, 'sidebar:visibility',
        this.slideButtons);
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

        this.map.zoomControl.setPosition('bottomleft');
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
     * NOTE: we should debounce the method so it's not called twice because the
     * collection gets populated right after this view is instanciated, but this
     * cause the priority order to not be respected when applying the queue */
    addActorsMarkers: function() {
      if(!this.isMapInstanciated) {
        this.queue.push([this.addActorsMarkers, null, 1]);
        return;
      }

      /* Return the icon corresponding to each specific actor */
      var makeIcon = function(actorLevel, actorId, actorLocationId) {
        return L.divIcon({
          html: '<div class="map-marker -' + actorLevel+ ' js-actor-marker"' +
            ' data-id="' + actorId + '" data-location="' +
            actorLocationId + '"></div>',
          className: 'actor',
          iconSize: L.point(12, 12),
          iconAnchor: L.point(6, 6)
        });
      };

      var marker;
      _.each(this.actorsCollection.toJSON(), function(actor) {
        _.each(actor.locations, function(location) {
          marker = L.marker([location.lat, location.long], {
            icon: makeIcon(actor.level, actor.id, location.id),
            id: actor.id,
            locationId: location.id
          });
          marker.addTo(this.map);
          marker.on('click', this.actorMarkerOnClick.bind(this));
        }, this);
      }, this);
    },

    /* Triggers an event with the id of the clicked actor */
    actorMarkerOnClick: function(e) {
      this.updateActorMarkersFocus(e.target.options.id);
      this.router.navigate([
        '/actors',
        e.target.options.id,
        e.target.options.locationId
      ].join('/'), { trigger: true });
    },

    /* Update the markers' size according to the map's zoom level */
    updateMarkersSize: function() {
      if(!this.isMapInstanciated) {
        this.queue.push([this.updateMarkersSize, null, 2]);
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

    /* Remove the focus styles to all the actors markers */
    resetActorMarkersFocus: function() {
      this.$el.find('.js-actor-marker').removeClass('-active');
    },

    /* Add the focus styles to the actor's marker which id and location id is
     * passed as argument */
    focusOnActorMarker: function(actorId, locationId) {
      var selector = '.js-actor-marker[data-id="' + actorId + '"]' +
        '[data-location="' + locationId + '"]';
      this.$el.find(selector).addClass('-active');
    },

    /* Update the actors markers depending on the actor's id and location passed
     * as parameters, by focusing it and bluring the other ones */
    updateActorMarkersFocus: function(actorId, locationId) {
      if(!this.isMapInstanciated) {
        this.queue.push([this.updateActorMarkersFocus, [ actorId, locationId ],
          2]);
        return;
      }

      this.resetActorMarkersFocus();
      this.focusOnActorMarker(actorId, locationId);
    },

    /* Update the map and the markers according to the route triggered by the
     * router */
    updateMapFromRoute: function(route) {
      switch(route) {
        case 'actor':
          this.updateActorMarkersFocus(arguments[1][0], arguments[1][1]);
          break;
        default:
          this.resetActorMarkersFocus();
          break;
      }
    },

    /* Call all the methods stored in this.queue in order */
    applyQueue: function() {
      /* We sort the queue so that the numbers with the smallest priority number
       * are executed the first */
      this.queue = this.queue.sort(function(a, b) {
        if(a.length < 3 || b.length < 3) {
          console.warning('Each element of the queue needs a priority number');
          return -1;
        }
        return a[2] - b[2];
      });

      _.each(this.queue, function(method) {
        if(!method || method.length < 2 || typeof method[0] !== 'function') {
          console.warn('Unable to execute a queue\'s method');
        } else {
          method[0].apply(this, method[1]);
        }
      }, this);
    },

    /* Toggle the visibility of the relationships on the map (ie the links) and
     * the switch button
     * options can be null/undefined or { visible: [boolean] } */
    toggleRelationshipsVisibility: function(options) {
      var isVisible = options.visible;
      /* We toggle the part concerning the relationships from the legend */
      this.$legend.toggleClass('-reduced', !isVisible);
      /* We toggle the switch button concerning the relationships */
      this.$relationshipsToggle.prop('checked', isVisible);
      /* TODO: implementation of the method */
      console.warn('Feature not yet implemented');
    },

    /* Trigger the visibility of the relationships (ie links) on the map */
    triggerRelationshipsVisibility: function(e) {
      root.app.pubsub.trigger('relationships:visibility',
        { visible: e.currentTarget.checked });
    },

    /* Move the buttons aligned with the sidebar */
    slideButtons: function(options) {
      this.$buttons.toggleClass('-slided', options.isHidden);
    }

  });

})(this);
