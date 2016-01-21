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
      this.$zoomButtons = this.$el.find('.leaflet-control-zoom');
      this.$relationshipsToggle = this.$el.find('.js-relationships-checkbox');
      this.$buttons = this.$el.find('#map-buttons');
      this.$credits = this.$el.find('.leaflet-control-attribution');
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
    },

    /* GETTERS */

    /* Return the marker (DOM element) corresponding at the type, id and
     * locationId passed as arguments. If not found, display a warning in the
     * console. */
    getMarker: function(type, id, locationId) {
      var entityClass = type === 'actors' ? '.js-actor-marker' :
        '.js-action-marker';
      var selector = entityClass + '[data-id="' + id + '"]' +
        (locationId ? '[data-location="' + locationId + '"]' : '');

      var marker = document.querySelector(selector);
      if(!marker) {
        console.warn('Unable to find the marker /' +
          [ route.name, id, locationId ].join('/'));
      }
      return marker;
    },

    /* Return the marker (DOM element) associated to the actor/action present in
     * the URL.
     * NOTE: if there isn't any actor/action present in the URL or if the marker
     * can't be found, return undefined (and a warning when can't be found) */
    getActiveMarker: function() {
      var activeMarkerInfo = this.getActiveMarkerInfo();
      var marker;

      if(!_.isEmpty(activeMarkerInfo)) {
        marker = this.getMarker(activeMarkerInfo.type, activeMarkerInfo.id,
          activeMarkerInfo.locationId);
      }

      return marker;
    },

    /* Return the type, id and locationId of the active marker */
    getActiveMarkerInfo: function() {
      var route = this.router.getCurrentRoute();
      var markerInfo = {};

      if(route.name === 'actors' || route.name === 'actions') {
        markerInfo = {
          type: route.name,
          id: route.params[0],
          locationId: route.params[1]
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
        this.highlightActiveMarker();
        this.renderActiveMarkerRelations();
      }
    },

    onMarkerClick: function(e) {
      var marker = this.getMarker(e.target.options.type, e.target.options.id,
        e.target.options.locationId);

      this.resetMarkersHighlight();
      this.removeRelations();
      this.highlightMarker(marker);
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
          this.addFilteredMarkers();
          this.updateLegendRelationships();
        }.bind(this));
    },

    onRelationshipsVisibilityChange: function(options) {
      var isVisible = options.visible;
      /* We toggle the part concerning the relationships from the legend */
      this.$legend.toggleClass('-reduced', !isVisible);
      /* We move the zoom buttons according to the legend move */
      this.$zoomButtons.toggleClass('-slided', !isVisible);
      /* We toggle the switch button concerning the relationships */
      this.$relationshipsToggle.prop('checked', isVisible);
      /* We save the visibility to the model */
      this.status.set({ relationshipsVisible: isVisible });
      /* We toggle the relations' visibility */
      this.toggleRelationsVisibility();
    },

    onSidebarVisibilityChange: function(options) {
      this.$buttons.toggleClass('-slided', options.isHidden);
      this.$credits.toggleClass('-slided', options.isHidden);
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

    /* LOGIC */

    initMap: function() {
      this.renderMap()
        .then(this.fetchFilteredCollections.bind(this))
        .then(function() {
          this.addFilteredMarkers();
          this.highlightActiveMarker();
          this.renderActiveMarkerRelations();
          this.updateLegendRelationships();
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
      this.map.on('zoomend', this.updateMarkersSize.bind(this));

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

    /* Add markers for each location of each entity of the collection.
    * Options:
    *  - only ("actors" or "actions"): restrict to only one collection */
    addMarkers: function(options) {
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
          iconAnchor: L.point(11, 11),
          popupAnchor: L.point(0, -10)
        });
      };

      /* Method which actually adds the markers. Expects the collection (the
       * JSON object) and the type ("actions" or "actions") */
      var addEntityMarkers = function(collection, type) {
        var marker, popup;
        _.each(collection, function(entity) {
          _.each(entity.locations, function(location) {

            marker = L.marker([location.lat, location.long], {
              icon: makeIcon(type, entity.level, entity.id, location.id),
              type: type,
              id: entity.id,
              locationId: location.id
            });
            marker.addTo(this.map);

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
      };

      /* We close the current popup if exists */
      this.map.closePopup();

      if(!(options && options.only) || options && options.only === 'actors') {
        addEntityMarkers.apply(this,
          [ this.actorsCollection.toJSON(), 'actors' ]);
      }
      if(!(options && options.only) || options && options.only === 'actions') {
        addEntityMarkers.apply(this,
          [ this.actionsCollection.toJSON(), 'actions' ]);
      }
    },

    /* Highlight the marker associated to the actor/action present in the URL if
     * exists, otherwise do nothing */
    highlightActiveMarker: function() {
      var activeMarker = this.getActiveMarker();

      if(!!activeMarker) {
        this.highlightMarker(activeMarker);
      }
    },

    /* Highlight the marker passed as argument */
    highlightMarker: function(marker) {
      marker.classList.add('-active');
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
      this.$el.find('.js-more').on('click', function() {
        this.onMoreInfoButtonClick(marker);
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

    /* Delete all the map's markers or only one type of markers if specified */
    removeMarkers: function(type) {
      var selector = '.js-actor-marker, .js-action-marker';
      if(type) {
        selector = (type === 'actors') ? selector.split(', ')[0] :
          selector.split(', ')[1];
      }
      /* We actually remove the parent of the marker because leaflet adds a
       * wrapper */
      this.$el.find(selector).parent().remove();
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

       this.$el.find('.map-marker').css('transform', 'scale(' + scale + ')');
    },

    /* Trigger the visibility of the relationships (ie links) on the map */
    triggerRelationshipsVisibility: function(e) {
      root.app.pubsub.trigger('relationships:visibility',
        { visible: e.currentTarget.checked });
    },

    /* Remove all the lines from the map */
    removeRelations: function() {
      this.$el.find('.js-line').remove();
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
        /* We search for the location's coordinates */
        var location = _.findWhere(model.get('locations'),
          { id: parseInt(locationId) });
        if(!location) {
          console.warn('Unable to find the location ' + locationId +
            ' of the ' + ((type === 'actors') ? 'actor' : 'action') + ' ' +
            id);
          return;
        }
        var entityLatLng = L.latLng(location.info_data.lat,
          location.info_data.long);

        var otherEntityLatLng, latLngs;
        _.each(relations, function(relation) {
          /* TODO: real main location */
          otherEntityLatLng = L.latLng(relation.locations[0].lat,
            relation.locations[0].long);
          latLngs = [ entityLatLng, otherEntityLatLng ];

          /* We define the line's options */
          var options = { className: 'map-line js-line' };
          if(entityType !== type) options.dashArray = '3, 6';
          if(!this.status.get('relationshipsVisible')) {
            options.className += ' -hidden';
          }

          L.polyline(latLngs, options).addTo(this.map);
        }, this);
      }.bind(this);

      /* We add the relations with the actors */
      var relations = _.union(model.get('actors').parents,
        model.get('actors').children);
      addLines(relations, 'actors');
      /* We add the relations with the actions */
      relations = _.union(model.get('actions').parents,
        model.get('actions').children);
      addLines(relations, 'actions');
    },

    renderActiveMarkerRelations: function() {
      var activeMarkerInfo = this.getActiveMarkerInfo();

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
    }

  });

})(this);
