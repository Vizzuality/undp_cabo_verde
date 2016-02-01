(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};
  root.app.Model = root.app.Model || {};
  root.app.pubsub = root.app.pubsub || {};
  root.app.Helper = root.app.Helper || {};

  var Status = Backbone.Model.extend({
    defaults: { relationshipsVisible: true }
  });

  root.app.View.mapView = Backbone.View.extend({

    el: '.l-map',

    events: {
      'change .js-relationships-checkbox': 'triggerRelationshipsVisibility'
    },

    popupTemplate: HandlebarsTemplates['popup_template'],

    initialize: function(options) {
      this.router = options.router;
      this.status = new Status();

      this.actorsCollection = new root.app.Collection.actorsCollection(null, {
        router: this.router
      });
      this.actionsCollection = new root.app.Collection.actionsCollection(null, {
        router: this.router
      });
      /* actorModel and actionModel are used to store the information about the
       * maker whose popup is open. Their data can be fetched by this view, or
       * synced by another one using the pubsub object. */
      this.actorModel = new root.app.Model.actorModel();
      this.actionModel = new root.app.Model.actionModel();

      this.$legend = this.$el.find('#map-legend');
      this.$relationshipsToggle = this.$el.find('.js-relationships-checkbox');
      this.$buttons = this.$el.find('#map-buttons');
      /* Cache for the relationships part of the legend */
      this.$actorToActionLegend = this.$el.find('.js-actor-to-action');
      this.$actorToActorLegend = this.$el.find('.js-actor-to-actor');
      this.$actionToActionLegend = this.$el.find('.js-action-to-action');

      this.setListeners();

      this.initMap();
    },

    setListeners: function() {
      this.listenTo(root.app.pubsub, 'relationships:visibility',
        this.onRelationshipsVisibilityChange);
      this.listenTo(root.app.pubsub, 'sidebar:visibility',
        this.onSidebarVisibilityChange);

      this.listenTo(this.actorModel, 'sync', this.onActorModelSync);
      this.listenTo(this.actionModel, 'sync', this.onActionModelSync);
      this.listenTo(root.app.pubsub, 'sync:actorModel',
        this.onActorModelRemoteSync);
      this.listenTo(root.app.pubsub, 'sync:actionModel',
        this.onActionModelRemoteSync);
      this.listenTo(this.router, 'change:queryParams', this.onFiltering);
      this.listenTo(root.app.pubsub, 'click:goBack', this.onGoBack);
      this.listenTo(root.app.pubsub, 'change:timeline', this.onTimelineChange);
    },

    /* GETTERS */

    /* Return the marker (DOM element) corresponding at the type, id and
     * locationId passed as arguments. If not found, display a warning in the
     * console.
     * NOTE: in case the locationId is omited, return all the entity's markers
     */
    getMarker: function(type, id, locationId) {
      var entityClass = type === 'actors' ? '.js-actor-marker' :
        '.js-action-marker';
      var selector = entityClass + '[data-id="' + id + '"]' +
        (locationId ? '[data-location="' + locationId + '"]' : '');

      var marker = locationId ? document.querySelector(selector) :
        document.querySelectorAll(selector);

      return marker;
    },

    /* Return the Leaflet marker corresponding to the passed arguments */
    getLeafletMarker: function(type, id, locationId) {
      return _.find(this.markersLayer.getLayers(), function(m) {
        return m.options.type === type && m.options.id === id &&
          m.options.locationId === locationId;
      })
    },

    /* Return the type, id and locationId of the selected marker (ie the marker
     * whose info is displayed in the sidebar) */
    getSelectedMarkerInfo: function() {
      var route = this.router.getCurrentRoute();
      var markerInfo = {};

      if(route.name === 'actors' || route.name === 'actions') {
        markerInfo = {
          type: route.name,
          id: parseInt(route.params[0]),
          locationId: parseInt(route.params[1])
        };
      }

      return markerInfo;
    },

    /* Return all the map's highlighted markers as a NodeList */
    getAllHighlightedMarkers: function() {
      var selector = '.js-actor-marker.-active, .js-action-marker.-active';
      return document.querySelectorAll(selector);
    },

    /* EVENT HANDLERS */

    onMapClick: function() {
      var route = this.router.getCurrentRoute();

      this.resetMarkersHighlight();
      this.removeRelations();
      this.updateLegendRelationships();
      if(route.name === 'actions' || route.name === 'actors') {
        this.highlightSelectedMarkers();
        this.renderSelectedMarkerRelations();
      }
    },

    onMarkerClick: function(e) {
      var markers = this.getMarker(e.target.options.type,
        e.target.options.id);

      this.lastActiveMarkerInfo = {
        type:       e.target.options.type,
        id:         e.target.options.id,
        locationId: e.target.options.locationId
      };

      this.resetMarkersHighlight();
      this.removeRelations();
      this.highlightMarkers(markers);
      this.updateLegendRelationships(e.target);

      this.fetchModelFor(e.target.options.type, e.target.options.id)
        .then(function() {
          this.renderMarkerRelations(e.target.options.type, e.target.options.id,
            e.target.options.locationId);
          this.renderPopupFor(e.target);
        }.bind(this));
    },

    onMoreInfoButtonClick: function(marker) {
      this.router.navigate([
        '/' + marker.options.type,
        marker.options.id,
        marker.options.locationId
      ].join('/'), { trigger: true });

      root.app.pubsub.trigger('show:' + marker.options.type.slice(0, -1), {
        id: marker.options.id,
        locationId: marker.options.locationId
      });

      this.map.closePopup(marker.getPopup());
    },

    onFiltering: function() {
      this.map.closePopup();
      this.fetchFilteredCollections()
        .then(function() {
          this.removeMarkers();
          this.removeRelations();
          this.addFilteredMarkers();
          this.updateLegendRelationships();
        }.bind(this));
    },

    onRelationshipsVisibilityChange: function(options) {
      var isVisible = options.visible;
      /* We toggle the part concerning the relationships from the legend */
      this.$legend.toggleClass('-reduced', !isVisible);
      /* We move the zoom buttons according to the legend move */
      if(this.$zoomButtons) {
        /* The variable only exists after the map is initialized */
        this.$zoomButtons.toggleClass('-slided', !isVisible);
      }
      /* We toggle the switch button concerning the relationships */
      this.$relationshipsToggle.prop('checked', isVisible);
      /* We save the visibility to the model */
      this.status.set({ relationshipsVisible: isVisible });
      /* We toggle the relations' visibility */
      this.toggleRelationsVisibility();
    },

    onSidebarVisibilityChange: function(options) {
      this.$buttons.toggleClass('-slided', options.isHidden);
      if(this.$credits) {
        /* The variable only exists once the map is initialized */
        this.$credits.toggleClass('-slided', options.isHidden);
      }
    },

    /* Trigger an event through the pubsub object to inform about the new state
     * of the actor model */
    onActorModelSync: function() {
      root.app.pubsub.trigger('sync:actorModel', this.actorModel);
    },

    /* Trigger an event through the pubsub object to inform about the new state
     * of the action model */
    onActionModelSync: function() {
      root.app.pubsub.trigger('sync:actionModel', this.actionModel);
    },

    /* Set the content of this.actorModel with the content of the passed model
     * NOTE: as the view itself can trigger this method by the sync event of its
     * own model, we make the comprobation that the id of the passed model is
     * different from the one stored in the current model */
    onActorModelRemoteSync: function(model) {
      if(!_.isEmpty(this.actorModel.attributes) &&
        this.actorModel.get('id') === model.get('id')) {
        return;
      }

      this.actorModel.clear({ silent: true });
      this.actorModel.set(model.toJSON());
    },

    /* Set the content of this.actionModel with the content of the passed model
     * NOTE: as the view itself can trigger this method by the sync event of its
     * own model, we make the comprobation that the id of the passed model is
     * different from the one stored in the current model */
    onActionModelRemoteSync: function(model) {
      if(!_.isEmpty(this.actionModel.attributes) &&
        this.actionModel.get('id') === model.get('id')) {
        return;
      }

      this.actionModel.clear({ silent: true });
      this.actionModel.set(model.toJSON());
    },

    onGoBack: function() {
      this.map.closePopup();
      this.updateLegendRelationships();
      this.resetMarkersHighlight();
      this.removeRelations();
    },

    onTimelineChange: function(options) {
      this.filterMarkers(options);
    },

    onZoomEnd: function() {
      this.updateMarkersSize();
      this.computeMarkersOptimalPosition();
      this.removeRelations();

      if(!_.isEmpty(this.lastActiveMarkerInfo)) {
        this.renderMarkerRelations(this.lastActiveMarkerInfo.type,
          this.lastActiveMarkerInfo.id,
          this.lastActiveMarkerInfo.locationId);
      }
    },

    /* LOGIC */

    initMap: function() {
      this.renderMap()
        .then(this.fetchFilteredCollections.bind(this))
        .then(function() {
          /* We wait for the map to create the elements */
          this.$zoomButtons = this.$el.find('.leaflet-control-zoom');
          this.$credits = this.$el.find('.leaflet-control-attribution');

          this.addFilteredMarkers();
          this.highlightSelectedMarkers();
          this.renderSelectedMarkerRelations();
          this.updateLegendRelationships();

          this.lastActiveMarkerInfo = this.getSelectedMarkerInfo();

          /* We initialize the map's timeline when we're sure the map is ready
           */
          this.mapSliderView = new root.app.View.mapSliderView({
            router: this.router
          });
        }.bind(this));
    },

    /* Render the map and return a deferred */
    renderMap: function() {
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
      this.map.on('click', this.onMapClick.bind(this));
      this.map.on('zoomend', this.onZoomEnd.bind(this));

      var deferred = $.Deferred();
      cartodb.createLayer(this.map,
        'https://simbiotica.cartodb.com/api/v2/viz/d26b8254-78d1-11e5-b910-0ecfd53eb7d3/viz.json')
        .addTo(this.map)
        .on('done', deferred.resolve)
        .on('error', function(error) {
          console.error('Unable to render the map: ' + error);
          deferred.reject();
        });

      return deferred;
    },

    /* Fetch only the collections that are not filtered out and return a
     * deferred object */
    fetchFilteredCollections: function() {
      var queryParams = this.router.getQueryParams();

      /* If one of the required filter doesn't have any value, we just don't
       * fetch the collections, the user will see a warning in the sidebar
       * anyway */
      if(queryParams.types && queryParams.types.length === 0 ||
        queryParams.levels && queryParams.levels.length === 0 ||
        queryParams.domains_ids && queryParams.domains_ids.length === 0) {
        console.error('A required parameter hasn\'t been provided');
        return;
      }

      var params = {};
      if(queryParams.types && queryParams.types.length !== 2) {
        params.only = queryParams.types[0];
      }

      return this.fetchCollections(params);
    },

    /* Fetch the actors and actions collections and returns a deferred object
     * Options:
     *  - only ("actors" or "actions"): restrict the fetch to only one
     *    collection */
    fetchCollections: function(options) {
      var collectionsToFetch = [];

      if(!(options && options.only) || options && options.only === 'actors') {
        collectionsToFetch.push(this.actorsCollection);
      }
      if(!(options && options.only) || options && options.only === 'actions') {
        collectionsToFetch.push(this.actionsCollection);
      }

      var deferred = $.Deferred();
      $.when.apply(null, _.invoke(collectionsToFetch, 'fetch'))
        .done(deferred.resolve)
        .fail(function() {
          console.error('Unable to fetch the collections');
          deferred.reject();
        });

      return deferred;
    },

    /* Only add the markers of the collections that haven't been filtered out */
    addFilteredMarkers: function() {
      var queryParams = this.router.getQueryParams();

      var params = {};
      if(queryParams.types && queryParams.types.length !== 2) {
        params.only = queryParams.types[0];
      }

      this.addMarkers(params);
    },

    /* Return the icon corresponding to each specific entity and location */
    /* Internal method used by _addEntityMarkers to create the icons of the
     * markers. Expects the type of markers, its level, its id and location id
     * NOTE: it shouldn't be called outside of _addEntityMarkers */
    _generateMarkerIcon: function(type, level, id, locationId) {
      return L.divIcon({
        html: '<svg class="map-marker ' +
          ((type === 'actors') ? '-actor js-actor-marker"' : '-action js-action-marker"') +
          ' data-id="' + id + '" data-location="' + locationId + '">' +
          '<use xlink:href="#' + level + 'MarkerIcon" x="0" y="0" />' +
          '<use xlink:href="#' + level + 'OutlineMarkerIcon" x="0" y="0" />' +
          '</svg>',
        className: type === 'actors' ? 'actor' : 'action',
        iconSize: L.point(22, 22),
        iconAnchor: L.point(11, 11),
        popupAnchor: L.point(0, -10)
      });
    },

    /* Internal method used by addMarkers to add markers to the map. Expects the
     * collection of actors/actions (the JSON object) and its type ("actions" or
     * "actions")
     * NOTE: it shouldn't be called outside of addMarkers */
    _addEntityMarkers: function(collection, type) {
      var marker, popup;
      _.each(collection, function(entity) {
        _.each(entity.locations, function(location) {

          marker = L.marker([location.lat, location.long], {
            icon: this._generateMarkerIcon(type, entity.level, entity.id,
              location.id),
            type: type,
            id: entity.id,
            locationId: location.id
          });

          this.markersLayer.addLayer(marker);

          /* We bind the basic popup */
          popup = L.popup({
            closeButton: false,
            minWidth: 220,
            maxWidth: 276, /* 20px padding + 4 icons */
            className: 'popup -' + type + ' -' + entity.level
          }).setContent('<div class="message -loading"><svg class="icon">' +
             '<use xlink:href="#waitIcon" x="0" y="0" /></svg>' +
             I18n.translate('front.loading') +
             '</message>');
          marker.bindPopup(popup);

          marker.on('click', this.onMarkerClick.bind(this));
        }, this);
      }, this);
    },

    /* Add markers for each location of each entity of the collection.
    * Options:
    *  - only ("actors" or "actions"): restrict to only one collection */
    addMarkers: function(options) {
      /* We close the current popup if exists */
      this.map.closePopup();

      this.markersLayer = L.layerGroup();

      if(!(options && options.only) || options && options.only === 'actors') {
        this._addEntityMarkers(this.actorsCollection.toJSON(), 'actors');
      }
      if(!(options && options.only) || options && options.only === 'actions') {
        this._addEntityMarkers(this.actionsCollection.toJSON(), 'actions');
      }

      /* Cache for the timeline animation */
      this.leafletMarkers = this.markersLayer.getLayers();

      this.computeMarkersOptimalPosition();

      this.markersLayer.addTo(this.map);
    },

    /* Compute the position of each marker depending on the position of the
     * other ones. If several markers have the exact same position, we move them
     * along an archimede spiral. Expects the layer of markers. */
    computeMarkersOptimalPosition: function() {
      /* Constants used as parameters for the spiral */
      var spiralGap, spiralInitialDistance, spiralAngleFactor;
      var mapZoom = this.map.getZoom();
      switch(true) {
        case mapZoom <= 9:
          spiralGap             = 1;
          spiralInitialDistance = 0;
          spiralAngleFactor     = Math.PI / 3;
          break;

        case mapZoom <= 11:
          spiralGap             = 2;
          spiralInitialDistance = 2;
          spiralAngleFactor     = Math.PI / 3;
          break;

        default:
          spiralGap             = 5;
          spiralInitialDistance = 5;
          spiralAngleFactor     = Math.PI / 3;
          break;
      }

      /* By grouping and filtering the markers, we get an array of all the
       * groups of markers which share the same location (ie an array of arrays
       * of markers with the same location) */
      var latLng;
      var conflictingMarkersGroups = _.filter(_.groupBy(this.markersLayer.getLayers(), function(m) {
        latLng = m.options.originalLatLng || m.getLatLng();
        return ''.concat(latLng.lat, latLng.lng);
      }), function(group) {
        return group.length > 1;
      });

      /* We create an array of all the markers that will be moved */
      var optimallyPositionedMarkers = _.flatten(_.map(conflictingMarkersGroups,
        function(conflictingMarkersGroup) {
        return _.map(conflictingMarkersGroup, function(conflictingMarker) {
          return conflictingMarker;
        });
      }));

      /* We compare the list of all the markers which will be moved with the
       * previously moved to compute if we need to restore their original
       * position */
      var markersToRestorePosition = _.compact(_.map(this.optimallyPositionedMarkers,
        function(m) {
        if(!~optimallyPositionedMarkers.indexOf(m)) {
          return m;
        }
      }, this));

      /* We restore the position of markers */
      _.each(markersToRestorePosition, function(m) {
        m.setLatLng(m.options.originalLatLng);
      });

      this.optimallyPositionedMarkers = optimallyPositionedMarkers;

      /* This layer contains all the map's elements useful for the user to
       * understand that some markers have been moved from their original
       * positions. It contains lines and a marker at the original position. */
      if(this.optimalPositioningLayer) {
        this.optimalPositioningLayer.clearLayers();
      } else {
        this.optimalPositioningLayer = L.layerGroup();
      }

      var centroidLatLng, centroidXY;
      _.each(conflictingMarkersGroups, function(conflictingMarkersGroup) {
        /* The centroid is the position of any marker as they all share the same
         * coordinates */
        centroidLatLng = conflictingMarkersGroup[0].options.originalLatLng ||
          conflictingMarkersGroup[0].getLatLng();
        centroidXY = this.map.latLngToLayerPoint(centroidLatLng);

        /* We add a marker at the original position so the user knows where the
         * original markers' position */
        L.marker(centroidLatLng, {
          icon: L.divIcon({
            className: 'map-marker -secondary js-position-marker',
            iconSize: L.point(4, 4),
            iconAnchor: L.point(2, 2)
          })
        }).addTo(this.optimalPositioningLayer);

        /* We compute the position of each marker from the centroid position.
         * Basically, we add a small deviance that follow the path of this
         * Archimedean spiral:
         * rho = a * theta + b (polar coordinates)
         *    where: a     is spiralGap
         *           b     is spiralInitialDistance
         *           theta is angle
         */
        var angle = spiralAngleFactor,
            optimalX,
            optimalY;
        _.each(conflictingMarkersGroup, function(conflictingMarker) {
          optimalX = centroidXY.x +
            (spiralInitialDistance + spiralGap * angle) * Math.cos(angle);
          optimalY = centroidXY.y +
            (spiralInitialDistance + spiralGap * angle) * Math.sin(angle);

          conflictingMarker.setLatLng(this.map.layerPointToLatLng([optimalX,
            optimalY]));
          conflictingMarker.options.originalLatLng = centroidLatLng;

          /* We add a line between the marker which represents the original
           * position and the marker which moved */
           L.polyline([ centroidLatLng, this.map.layerPointToLatLng([optimalX,
             optimalY]) ], {
             className: 'map-line -secondary'
           }).addTo(this.optimalPositioningLayer);

          angle += spiralAngleFactor;
        }, this);

      }, this);

      if(!this.map.hasLayer(this.optimalPositioningLayer)) {
        this.optimalPositioningLayer.addTo(this.map);
      }
    },

    /* Highlight the marker associated to the actor/action present in the URL if
     * exists, otherwise do nothing */
    highlightSelectedMarkers: function() {
      var activeMarkerInfo = this.getSelectedMarkerInfo();

      if(!_.isEmpty(activeMarkerInfo)) {
        var activeMarkers = this.getMarker(activeMarkerInfo.type,
          activeMarkerInfo.id);
        this.highlightMarkers(activeMarkers);
      }
    },

    /* Highlight the marker passed as argument or display a warning in the
     * console if the marker is evaluated as false (ie null or undefined) */
    highlightMarker: function(marker) {
      if(!marker) {
        console.warn('Unable to highlight a marker on the map');
        return;
      }
      marker.classList.add('-active');
    },

    /* Highlight all the markers passed as argument */
    highlightMarkers: function(markers) {
      for(var i = 0, j = markers.length; i < j; i++) {
        this.highlightMarker(markers[i]);
      }
    },

    /* Remove the highlight effects to all the map's markers */
    resetMarkersHighlight: function() {
      var highlightedMarkers = this.getAllHighlightedMarkers();
      for(var i = 0, j = highlightedMarkers.length; i < j; i++) {
        highlightedMarkers[i].classList.remove('-active');
      }
    },

    /* Load the content of the passed marker and display it inside the popup
     * attached to it */
    renderPopupFor: function(marker) {
      var popup = marker.getPopup();

      /* If the popup is already open, we don't want to render once again
       * NOTE: newer versions of Leaflet include a method isOpen, but CartoDB
       * hasn't included it yet */
      if(!this.map.hasLayer(popup)) {
        return;
      }

      /* Model which will contain the information about the actor or action */
      var model = marker.options.type === 'actors' ? this.actorModel :
        this.actionModel;

      popup.setContent(this.popupTemplate(model.toJSON()));
      this.$el.find('.leaflet-popup .js-more').on('click', function() {
        this.onMoreInfoButtonClick(marker);
      }.bind(this));
      this.$el.find('.leaflet-popup .js-close').on('click', function() {
        this.map.closePopup();
      }.bind(this));
    },

    /* Dynamically hide a part of the relationships legend depending on the
     * active marker type: if a marker is passed as parameter (Leaflet object),
     * consider it as the active marker, otherwise, take into account the marker
     * attached to the current URL. If there's no active marker, reset the
     * legend in its original state */
    updateLegendRelationships: function(marker) {
      if(marker) {
        this.$actionToActionLegend.toggleClass('-disabled',
          marker.options.type === 'actors');
        this.$actorToActorLegend.toggleClass('-disabled',
          marker.options.type === 'actions');
      } else {
        var route = this.router.getCurrentRoute();
        this.$actionToActionLegend.toggleClass('-disabled',
          route.name === 'actors');
        this.$actorToActorLegend.toggleClass('-disabled',
          route.name === 'actions');
      }
    },

    /* Delete all the map's markers */
    removeMarkers: function() {
      this.map.removeLayer(this.markersLayer);
      this.map.removeLayer(this.optimalPositioningLayer);
    },

    /* Update the markers' size according to the map's zoom level */
    updateMarkersSize: function() {
      var zoom = this.map.getZoom();
      /* We don't want the markers to be smaller than 5px but also no bigger
       * than 12px. To do so, we use the css transform: scale property and bound
       * it to values between .42 and 1 (default marker's size is 12px). We
       * consider 13 the level from which makers' size shouldn't change. */
      var scale;
      if(zoom <= 5)       { scale = 0.42; }
      else if(zoom >= 13) { scale = 1; }
      else                { scale = zoom / 13; }

      this.$el.find('.js-actor-marker, .js-action-marker').css('transform',
        'scale(' + scale + ')');

      /* We also udate the size of the position markers but as the CSS transform
       * property already has a value, we add the scale to it */
      var positionMarkers = this.$el.find('.js-position-marker'),
          transform;
      for(var i = 0, j = positionMarkers.length; i < j; i++) {
        transform = positionMarkers[i].style.transform;
        if(/scale\(.*\)/gi.test(transform)) {
          transform.replace(/scale\(.*\)/gi, 'scale(' + scale + ')');
        } else {
          transform += ' scale(' + scale + ')';
        }
        positionMarkers[i].style.transform = transform;
      }
    },

    /* Trigger the visibility of the relationships (ie links) on the map */
    triggerRelationshipsVisibility: function(e) {
      root.app.pubsub.trigger('relationships:visibility',
        { visible: e.currentTarget.checked });
    },

    /* Remove all the relations from the map */
    removeRelations: function() {
      if(this.map.hasLayer(this.relationsLayer)) {
        this.map.removeLayer(this.relationsLayer);
      }

      var highlightedMarkers = this.el.querySelectorAll('.js-relation-highlight');
      for(var i = 0, j = highlightedMarkers.length; i < j; i++) {
        highlightedMarkers[i].classList.remove('js-relation-highlight');
      }
    },


    /* Fetch the model for the marker mathcing the type and id and return a
     * deferred object
     * NOTE: if the current stored model has the right information, there won't
     * be any API call */
    fetchModelFor: function(type, id) {
      var deferred = $.Deferred();

      /* Model which will contain the information about the actor or action */
      var model = (type === 'actors') ? this.actorModel : this.actionModel;

      /* In case we already have the data for the selected marker, we don't want
       * to fetch the model again */
      if(!_.isEmpty(model.attributes) && model.get('id') === id) {
        deferred.resolve();
      } else {
        model.setId(id);
        model.fetch()
          .done(deferred.resolve)
          .fail(function() {
            console.warn('Unable to fetch the model /' + [type, id].join('/'));
            deferred.reject();
          });
      }

      return deferred;
    },

    /* Render the relations of the marker matching the type, id and locationId
     * passed as arguments */
    renderMarkerRelations: function(type, id, locationId) {
      var model = (type === 'actors') ? this.actorModel : this.actionModel;

      /* Method which draws the lines
      * relations is the collection of relations and entityType designates the
      * type of the relations ("actors" or "actions") */
      var addLines = function(relations, entityType) {
        var markers = this.markersLayer.getLayers();

        /* We search the position of the clicked marker as it can differ from
         * the one stored in the model because of the "optimal positioning" */
        var clickedMarker = this.getLeafletMarker(type, id, locationId);

        if(!clickedMarker) {
          console.warn('Unable to find the clicked marker');
          return;
        }

        var clickedMarkerLatLng = clickedMarker.getLatLng();

        /* We then find each marker which is linked to the clicked one, save its
         * coordinates and add a line between them */
        var otherMarker, otherDOMMarker, otherMarkerLatLng, latLngs;
        this.relationsLayer = L.layerGroup(_.compact(_.map(relations,
          function(relation) {

          if(!relation.locations.length) {
            console.warn('Unable to show the relation with /' + entityType +
              '/' + relation.id + ' because it doesn\'t have any location');
          } else {
            /* TODO: real main location */
            otherMarker = this.getLeafletMarker(entityType, relation.id,
              relation.locations[0].id);

            if(!!otherMarker) {
              otherMarkerLatLng = otherMarker.getLatLng();
              otherDOMMarker = this.getMarker(entityType, relation.id,
                relation.locations[0].id);

              if(this.status.get('relationshipsVisible')) {
                this.highlightMarker(otherDOMMarker);
              }
              /* And we add a special class to it so it can't be hidden with the
               * toggle button for the relationships */
              otherDOMMarker.classList.add('js-relation-highlight');

              latLngs = [ clickedMarkerLatLng, otherMarkerLatLng ];

              /* We define the line's options */
              var options = { className: 'map-line js-line' };
              if(entityType !== type) options.dashArray = '3, 6';
              if(!this.status.get('relationshipsVisible')) {
                options.className += ' -hidden';
              }

              return L.polyline(latLngs, options);
            }
          }
        }, this)));
      }.bind(this);

      /* We add the relations with the actors */
      var relations = _.union(model.get('actors').parents,
        model.get('actors').children);
      addLines(relations, 'actors');
      /* We add the relations with the actions */
      relations = _.union(model.get('actions').parents,
        model.get('actions').children);
      addLines(relations, 'actions');

      /* We finally add the relations to the map */
      this.relationsLayer.addTo(this.map);
    },

    renderSelectedMarkerRelations: function() {
      var activeMarkerInfo = this.getSelectedMarkerInfo();

      if(!_.isEmpty(activeMarkerInfo)) {
        this.fetchModelFor(activeMarkerInfo.type, activeMarkerInfo.id)
          .then(function() {
            this.renderMarkerRelations(activeMarkerInfo.type,
              activeMarkerInfo.id, activeMarkerInfo.locationId);
          }.bind(this));
      }
    },

    /* Toggle the visibility of the map's relations */
    toggleRelationsVisibility: function() {
      var lines = this.el.querySelectorAll('.js-line');
      for(var i = 0, j = lines.length; i < j; i++) {
        lines[i].classList.toggle('-hidden');
      }
      var highlightedMarkers = this.el.querySelectorAll('.js-relation-highlight');
      for(var i = 0, j = highlightedMarkers.length; i < j; i++) {
        highlightedMarkers[i].classList.toggle('-active');
      }
    },

    /* Filter the map's markers depending on if they exist at the passed date.
     * If not, they're hidden.
     * NOTE: this function MUST BE optimized as much as possible because it's
     * called in a requestAnimationFrame (its duration should be less than 10
     * ms) */
    filterMarkers: function(options) {
      /* If we're asked to filter the markers for the same date, we don't do
       * anything (important for rendering improvements when seing a big range)
       */
      if(this.lastFilterDate && this.lastFilterDate === options.date) {
        return;
      } else {
        this.lastFilterDate = options.date;
      }

      this.map.removeLayer(this.markersLayer);

      /* In case there's no date, we reset the markers */
      if(!options.date) {
        this.markersLayer = L.layerGroup(this.leafletMarkers);
        this.lastFilterDate = null;
      } else {
        this.markersLayer = L.layerGroup(_.filter(this.leafletMarkers,
          function(m) {
          return Math.random() < 0.5;
        }));
      }

      this.removeRelations();
      this.computeMarkersOptimalPosition();

      this.markersLayer.addTo(this.map);
    }

  });

})(this);
