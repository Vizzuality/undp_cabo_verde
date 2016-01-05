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
      this.actionsCollection = options.actionsCollection;
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
      this.$zoomButtons = this.$el.find('.leaflet-control-zoom');
      this.$relationshipsToggle = this.$el.find('.js-relationships-checkbox');
      this.$buttons = this.$el.find('#map-buttons');
      this.$credits = this.$el.find('.leaflet-control-attribution');
      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(this.actorsCollection, 'sync change',
        this.addActorsMarkers);
      this.listenTo(this.actionsCollection, 'sync change',
        this.addActionsMarkers);
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

    /* Add markers for each location of each entity of the collection. Depending
     * on the type ("actors" or "actions"), the attributes and callbacks of the
     * markers will differ. */
    addMarkers: function(collection, type) {
      /* Return the icon corresponding to each specific entity and location */
      var makeIcon = function(type, level, id, locationId) {
        return L.divIcon({
          html: '<svg class="map-marker ' +
            ((type === 'actors') ? '-actor js-actor-marker"' : '-action js-action-marker"') +
            ' data-id="' + id + '" data-location="' + locationId + '">' +
            '<use xlink:href="#' + level + 'MarkerIcon" x="0" y="0" />' +
            '<use xlink:href="#' + level + 'OutlineMarkerIcon" x="0" y="0" />' +
            '</svg>',
          className: type === 'actors' ? 'actor' : 'action',
          iconSize: L.point(22, 22),
          iconAnchor: L.point(11, 11)
        });
      };

      var marker;
      _.each(collection, function(entity) {
        _.each(entity.locations, function(location) {
          marker = L.marker([location.lat, location.long], {
            icon: makeIcon(type, entity.level, entity.id, location.id),
            type: type,
            id: entity.id,
            locationId: location.id
          });
          marker.addTo(this.map);
          marker.on('click', this.markerOnClick.bind(this));
        }, this);
      }, this);
    },

    /* Delete the selected type of markers */
    removeMarkers: function(type) {
      var selector = type === 'actors' ? '.js-actor-marker' :
        '.js-action-marker';
      /* We actually remove the parent of the marker because leaflet adds a
       * wrapper */
      this.$el.find(selector).parent().remove();
    },

    /* Add the markers for the actors
     * NOTE: we should debounce the method so it's not called twice because the
     * collection gets populated right after this view is instanciated, but this
     * cause the priority order to not be respected when applying the queue */
    addActorsMarkers: function() {
      if(!this.isMapInstanciated) {
        this.queue.push([ this.addActorsMarkers, null, 1 ]);
        return;
      }

      /* We remove the previous markers in case the method has been called
       * multiple times
       * TODO: instead of removing and adding once again the markers, just add
       * them once */
      this.removeMarkers('actors');
      this.addMarkers(this.actorsCollection.toJSON(), 'actors');
    },

    /* Add the markers for the actions
     * NOTE: we should debounce the method so it's not called twice because the
     * collection gets populated right after this view is instanciated, but this
     * cause the priority order to not be respected when applying the queue */
    addActionsMarkers: function() {
      if(!this.isMapInstanciated) {
        this.queue.push([ this.addActionsMarkers, null, 1 ]);
        return;
      }

      /* We remove the previous markers in case the method has been called
       * multiple times
       * TODO: instead of removing and adding once again the markers, just add
       * them once */
      this.removeMarkers('actions');
      this.addMarkers(this.actionsCollection.toJSON(), 'actions');
    },

    /* Triggers an event with the id of the clicked entity */
    markerOnClick: function(e) {
      this.updateMarkersFocus(e.target.options.type, e.target.options.id,
        e.target.options.locationId);
      this.router.navigate([
        e.target.options.type === 'actors' ? '/actors' : '/actions',
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

    /* Remove the focus styles to all the actors or actions markers depending on
     * the value of type ("actors" or "actions").
     * NOTE: If type is null or undefined the focus is removed from all
     * markers. */
    resetMarkersFocus: function(type) {
      var selector = '.js-actor-marker, .js-action-marker';
      if(type && type === 'actors') {
        selector = selector.split(' ')[0].slice(0, -1);
      } else if(type && type === 'actions') {
        selector = selector.split(' ')[1];
      }

      var markers = this.$el.find(selector);
      for(var i = 0, j = markers.length; i < j; i++) {
        markers[i].classList.remove('-active');
      }
    },

    /* Add the focus styles to the entity's marker which id and location id is
     * passed as argument */
    focusOnMarker: function(type, id, locationId) {
      //debugger;
      var entityClass = type === 'actors' ? '.js-actor-marker' :
        '.js-action-marker';
      var selector = entityClass + '[data-id="' + id + '"]' +
        '[data-location="' + locationId + '"]';

      this.$el.find(selector)[0].classList.add('-active');
    },

    /* Update the markers depending on the entity's id and location passed
     * as parameters, by focusing it and bluring the other ones */
    updateMarkersFocus: function(type, id, locationId) {
      if(!this.isMapInstanciated) {
        this.queue.push([this.updateMarkersFocus, [ type, id, locationId ],
          2]);
        return;
      }

      this.resetMarkersFocus(type);
      this.focusOnMarker(type, id, locationId);
    },

    /* Update the map and the markers according to the route triggered by the
     * router */
    updateMapFromRoute: function(route) {
      switch(route) {
        case 'actor':
          this.updateMarkersFocus('actors', arguments[1][0], arguments[1][1]);
          break;
        default:
          this.resetMarkersFocus();
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
      /* We move the zoom buttons according to the legend move */
      this.$zoomButtons.toggleClass('-slided', !isVisible);
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

    /* Move the buttons and the credits aligned with the sidebar */
    slideButtons: function(options) {
      this.$buttons.toggleClass('-slided', options.isHidden);
      this.$credits.toggleClass('-slided', options.isHidden);
    }

  });

})(this);
