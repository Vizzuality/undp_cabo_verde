(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};
  root.app.Collection = root.app.Collection || {};

  root.app.View.mapView = Backbone.View.extend({

    initialize: function(options) {
      this.router = options.router;

      this.actorsCollection = new root.app.Collection.actorsCollection(null, {
        router: this.router
      });
      this.actionsCollection = new root.app.Collection.actionsCollection(null, {
        router: this.router
      });


      /* actorModel and actionModel are used to store the information about the
       * maker whose popup is open. Their data can be fetched by this view, or
       * synced by another one using the pubsub object. */
      this.actorModel = new root.app.Model.actorModel(null, {
        router: this.router
      });
      this.actionModel = new root.app.Model.actionModel(null, {
        router: this.router
      });

      this.mapMapView = new root.app.View.mapMapView({ router: this.router });
      this.mapMarkersView = new root.app.View.mapMarkersView({
        router: this.router,
        actorsCollection:  this.actorsCollection,
        actionsCollection: this.actionsCollection,
        actorModel:  this.actorModel,
        actionModel: this.actionModel
      });
      this.mapRelationsView = new root.app.View.mapRelationsView({
        router: this.router,
        actorsCollection:  this.actorsCollection,
        actionsCollection: this.actionsCollection,
        actorModel:  this.actorModel,
        actionModel: this.actionModel
      });
      this.mapLegendView = new root.app.View.mapLegendView({
        router: this.router
      });
      this.mapZoomButtonsView = new root.app.View.mapZoomButtonsView();
      this.mapButtonsView = new root.app.View.mapButtonsView();
      this.mapSliderView = new root.app.View.mapSliderView({
        router: this.router
      });

      this.mapReady = false;

      this.setListeners();

      this.mapMapView.start();
    },

    setListeners: function() {
      this.listenTo(this.router, 'change:queryParams', this.onFiltering);
      this.listenTo(this.router, 'route', this.onRoute);

      this.listenTo(this.mapMapView, 'render:map', this.onMapRender);
      this.listenTo(this.mapMapView, 'click:map', this.onMapClick);
      this.listenTo(this.mapMapView, 'zoom:map', this.onMapZoom);

      this.listenTo(this.mapMarkersView, 'hover:marker', this.onMarkerHover);
      this.listenTo(this.mapMarkersView, 'click:marker', this.onMarkerClick);
      this.listenTo(this.mapMarkersView, 'open:marker', this.onMarkerOpen);

      this.listenTo(this.mapButtonsView, 'toggle:relations',
        this.onToggleRelations);

      this.listenTo(this.actorModel, 'sync', this.onActorModelSync);
      this.listenTo(this.actionModel, 'sync', this.onActionModelSync);

      this.listenTo(root.app.pubsub, 'sync:actorModel',
        this.onActorModelRemoteSync);
      this.listenTo(root.app.pubsub, 'sync:actionModel',
        this.onActionModelRemoteSync);
      this.listenTo(root.app.pubsub, 'relationships:visibility',
        this.onRelationshipsVisibilityChange);
      this.listenTo(root.app.pubsub, 'sidebar:visibility',
        this.onSidebarVisibilityChange);
      this.listenTo(root.app.pubsub, 'change:timeline', this.onTimelineChange);
      this.listenTo(root.app.pubsub, 'filter:sidebarFilters',
        this.onSidebarFiltersChange);
      this.listenTo(root.app.pubsub, 'filter:relations',
        this.onFilteringRelations);
    },

    onMapRender: function(map) {
      /* We set the object "this.map" for the markers and relations views */
      this.mapMarkersView.map   = map;
      this.mapRelationsView.map = map;
      this.map                  = map;

      this.fetchFilteredCollections()
        .then(function() {
          this.mapMarkersView.addFilteredMarkers();
          this.mapLegendView.updateLegendRelations();
          this.restoreOpenedMarkerState({ zoomToFit: true });
          this.mapReady = true;
        }.bind(this));
    },

    onMapClick: function() {
      this.mapMarkersView.resetMarkersHighlight();
      this.mapMarkersView.resetRelatedMarkers();
      this.mapRelationsView.removeRelations();
      this.mapLegendView.updateLegendRelations();

      this.restoreOpenedMarkerState();
    },

    onMapZoom: function() {
      this.mapMarkersView.updateMarkersSize();
      this.mapMarkersView.computeMarkersOptimalPosition();
      this.mapRelationsView.removeRelations();

      /* We need to remove the markers highlights because when the user is
       * seeing a marker in the sidebar and then he/she clicks another one, and
       * then he/she zooms we want to highlight the opened marker and not the
       * last clicked */
      this.mapMarkersView.resetMarkersHighlight();
      this.mapMarkersView.resetRelatedMarkers();

      /* When the map is zoomed, because we compute once again the optimal
       * position, we need to redraw the relations in two cases */
      var route = this.router.getCurrentRoute();
      if(route.name === 'actions' || route.name === 'actors') {
        this.restoreOpenedMarkerState();
      }
    },

    onFiltering: function() {
      this.map.closePopup();
      this.fetchFilteredCollections()
        .then(function() {
          this.mapMarkersView.removeMarkers();
          this.mapRelationsView.removeRelations();
          this.mapMarkersView.addFilteredMarkers();
          this.mapLegendView.updateLegendRelations();
        }.bind(this));
    },

    onMarkerClick: function(marker) {
      this.router.navigate([
        '/' + marker.options.type,
        marker.options.id,
        marker.options.locationId
      ].join('/'), { trigger: true });
    },

    onMarkerHover: function(marker) {
      marker.openPopup();

      this.fetchModel(marker.options.type, marker.options.id)
        .then(function() {
          this.mapMarkersView.renderPopup(marker);
        }.bind(this));
    },

    onMarkerOpen: function(marker) {
      this.onMarkerClick(marker);
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

    onRelationshipsVisibilityChange: function(options) {
      this.mapMarkersView.status.set({ relationshipsVisible: options.visible });
      this.mapMarkersView.toggleRelatedMarkersHighlight();

      this.mapRelationsView.status.set({
        relationshipsVisible: options.visible });
      this.mapRelationsView.toggleRelationsVisibility();

      this.mapLegendView.status.set({ relationshipsVisible: options.visible });
      this.mapLegendView.toggleLegendPosition();

      this.mapZoomButtonsView.status.set({
        relationshipsVisible: options.visible });
      this.mapZoomButtonsView.toggleButtonsPosition();

      this.mapButtonsView.toggleRelationsButton(options);
    },

    onSidebarVisibilityChange: function(options) {
      this.mapButtonsView.status.set({ sidebarVisible: !options.isHidden });
      this.mapButtonsView.toggleButtonsPosition();
    },

    onToggleRelations: function(options) {
      root.app.pubsub.trigger('relationships:visibility',
        { visible: options.visible });
    },

    onTimelineChange: function(options) {
      this.router.navigate('/', { trigger: true });

      this.mapMarkersView.filterMarkers(options);
    },

    onSidebarFiltersChange: function(options) {
      this.mapMarkersView.filterMarkers(options);
    },

    onRoute: function(route, params) {
      if(this.mapReady) {
        this.map.closePopup();
        this.mapMarkersView.resetMarkersHighlight();
        this.mapMarkersView.resetRelatedMarkers();
        this.mapRelationsView.removeRelations();
        this.mapLegendView.updateLegendRelations();

        if(route === 'actors' || route === 'actions') {
          this.restoreOpenedMarkerState({ zoomToFit: true });
        }
      }
    },

    onFilteringRelations: function(options) {
      var openedMarkerInfo = this.getOpenedMarkerInfo();

      if(options && _.isObject(options.only)) {
        var model = openedMarkerInfo.type === 'actors' ? this.actorModel :
          this.actionModel;
        var relations = model.getVisibleRelations();
        var relatedMarker = _.find(relations, function(relation) {
          return relation.type === options.only.type &&
            relation.id === options.only.id;
        });
        var relatedMarkerMainLocation = _.findWhere(relatedMarker.locations,
          { main: true }) || relatedMarker.locations[0];

        /* We only let the relation we want to highlight */
        this.mapRelationsView.filterRelations(options);
        /* We remove the highlight on all the markers */
        this.mapMarkersView.resetMarkersHighlight();
        /* We finally add the highlight only to the opened marker and the one
         * which is described in the params */
        this.mapMarkersView.highlightMarkers(openedMarkerInfo.type,
          openedMarkerInfo.id, openedMarkerInfo.locationId);
        this.mapMarkersView.highlightMarkers(relatedMarker.type,
          relatedMarker.id, relatedMarkerMainLocation.id);
      }
      /* We restore the relations and markers highlight */
      else {
        var openedLeafletMarker = this.mapMarkersView.getLeafletMarkers(openedMarkerInfo.type,
          openedMarkerInfo.id, openedMarkerInfo.locationId);
        var relatedMarkers = this.mapMarkersView.getRelatedLeafletMarkers(openedLeafletMarker);

        /* We highlight all the related markers */
        this.mapMarkersView.highlightRelatedMarkers(openedLeafletMarker,
          relatedMarkers);
        /* We then remove all the relations */
        this.mapRelationsView.removeRelations();
        /* We render the relations of the opened marker */
        this.mapRelationsView.renderRelations(openedLeafletMarker,
          relatedMarkers);
      }
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
        var deferred = $.Deferred();
        return deferred.reject();
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

    /* Fetch the model for the entity matching the type and id and return a
     * deferred object
     * NOTE: if the current stored model has the right information, there won't
     * be any API call */
    fetchModel: function(type, id) {
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

    /* Return the type, id and locationId of the opened marker (ie the marker
     * whose info is displayed in the sidebar) */
    getOpenedMarkerInfo: function() {
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

    /* If the information of a marker is available in the sidebar, highlight
     * its markers, its related markers and display the relations betweeen them
     * The following options can be passed to the method:
     *  * zoomToFit: fit the related markers inside the view
     */
    restoreOpenedMarkerState: function(options) {
      options = options || {};
      var route = this.router.getCurrentRoute();

      if(route.name === 'actions' || route.name === 'actors') {
        var openedMarkerInfo = this.getOpenedMarkerInfo();

        if(!_.isEmpty(openedMarkerInfo)) {
          /* We highlight the opened marker on the map */
          this.mapMarkersView.highlightMarkers(openedMarkerInfo.type,
            openedMarkerInfo.id);

          /* We fetch the data for that marker */
          this.fetchModel(openedMarkerInfo.type, openedMarkerInfo.id)
            .then(function() {
              /* We search for the opened marker */
              var openedMarker = this.mapMarkersView.getLeafletMarkers(openedMarkerInfo.type,
                openedMarkerInfo.id, openedMarkerInfo.locationId);

              if(openedMarker) {
                var relatedMarkers = this.mapMarkersView.getRelatedLeafletMarkers(openedMarker);
                this.mapMarkersView.highlightRelatedMarkers(openedMarker,
                  relatedMarkers);
                this.mapRelationsView.renderRelations(openedMarker,
                  relatedMarkers);

                if(options.zoomToFit) {
                  /* We zoom to fit the all the concerned markers */
                  var markersToFit = relatedMarkers;
                  if(markersToFit.length > 0) {
                    markersToFit = relatedMarkers.slice(0);
                    markersToFit.push(openedMarker);
                  }
                  this.mapMapView.zoomToFit(markersToFit);
                }
              } else {
                console.warn('Unable to find the Leaflet marker corresponding' +
                  ' to the URL');
              }
            }.bind(this));
        }
      }
    }

  });

})(this);
