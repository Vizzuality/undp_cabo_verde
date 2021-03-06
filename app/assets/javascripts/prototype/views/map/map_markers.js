(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};
  root.app.pubsub = root.app.pubsub || {};

  var Status = Backbone.Model.extend({
    defaults: { markersVisible: true }
  });

  root.app.View.mapMarkersView = Backbone.View.extend({

    el: '.l-map',

    popupTemplate: HandlebarsTemplates.popup_template,

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
      this.listenTo(this.status, 'change:markersVisible',
        this.toggleMarkersVisibility);
    },

    /* Return the marker (DOM element) corresponding to the type, id and
     * locationId passed as arguments. In the case where the locationId is
     * omitted, return all the entity's markers matching the previous
     * parameters.
     */
    getMarkers: function(type, id, locationId) {
     var entityClass = type === 'actors' ? '.js-actor-marker' :
       '.js-action-marker';
     var selector = entityClass + '[data-id="' + id + '"]' +
       (locationId ? '[data-location="' + locationId + '"]' : '');

     var marker = locationId ? document.querySelector(selector) :
       document.querySelectorAll(selector);

     return marker;
    },

    /* Return all the map's highlighted markers as a NodeList */
    getAllHighlightedMarkers: function() {
      var selector = '.js-actor-marker.-active, .js-action-marker.-active';
      return document.querySelectorAll(selector);
    },

    /* Return the Leaflet marker matching the type id and locationId or all the
     * the markers matching the first two parameters if the locationId is
     * omitted */
    getLeafletMarkers: function(type, id, locationId) {
      var markers = _.filter(this.markers, function(m) {
        return m.options.type === type &&
          m.options.id === id &&
          (locationId && m.options.locationId === locationId || !locationId);
      });

      return markers.length === 1 ? markers[0] : markers;
    },

    /* Return an array of the markers related (linked) with the marker passed as
     * argument
     * NOTE: make sure that the model associated with the marker's type is the
     * one corresponding to the marker */
    getRelatedLeafletMarkers: function(marker) {
      if(!this.markers) return [];

      var model = marker.options.type === 'actors' ? this.actorModel :
        this.actionModel;

      var relations = model.getVisibleRelations();

      var mainLocation, leafletMarker;
      return _.compact(_.map(relations, function(relation) {
        mainLocation = _.findWhere(relation.locations, { main: true }) ||
          !!~relation.locations.length && relation.locations[0];

        if(!mainLocation) return false;

        /* Once we have the main location of the relation, we find the leaflet
         * marker associated with it */
        leafletMarker = this.getLeafletMarkers(relation.type, relation.id,
          mainLocation.id);

        return leafletMarker;
      }, this));
    },

    onMarkerClick: function(e) {
      this.trigger('click:marker', e.target);
    },

    onMarkerHover: function(e) {
      /* This method is called twice because Leaflet bings the mouseover event
       * to the marker container and and the marker's HTML defined for the icon.
       * We then broadcast the event only when the mouseover concerns the SVG
       * icon. */
      if(!e.originalEvent.relatedTarget) return;
      if(root.app.Helper.utils.matches(e.originalEvent.relatedTarget, 'svg')) {
        this.trigger('hover:marker', e.target);
      }
    },

    onMarkerOpen: function(marker) {
      this.trigger('open:marker', marker);
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
      var marker, markerOptions, popup;
      _.each(collection, function(entity) {
        _.each(entity.locations, function(location) {

          markerOptions = {
            icon: this._generateMarkerIcon(type, entity.level, entity.id,
              location.id),
            type: type,
            id: entity.id,
            locationId: location.id
          };

          /* We add to each marker their start and end dates */
          if(location.start_date) {
            markerOptions.startDate = location.start_date;
          }
          if(location.end_date) {
            markerOptions.endDate = location.end_date;
          }

          /* For actions, we can have global start and end dates defined, we
           * then make sure to use them when the specific location don't provide
           * them or when the global date range isn't repected */
          if(type === 'actions' && entity.start_date) {
            if(!location.start_date ||
              (new Date(location.start_date)).getTime() < (new Date(entity.start_date)).getTime()) {
              markerOptions.startDate = entity.start_date;
            }
          }
          if(type === 'actions' && entity.end_date) {
            if(!location.end_date ||
              (new Date(location.end_date)).getTime() > (new Date(entity.end_date)).getTime()) {
              markerOptions.endDate = entity.end_date;
            }
          }

          /* We add the categories attached to the marker */
          markerOptions.socioCulturalDomains = _.map(entity.socio_cultural_domains,
            function(c) { return c.id; });
          markerOptions.otherDomains = _.map(entity.other_domains,
            function(c) { return c.id; });

          marker = new L.CustomMarker([location.lat, location.long], markerOptions);

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
          marker.bindPopup(popup, { showOnMouseOver: true });

          marker.on('click', this.onMarkerClick.bind(this));
          marker.on('mouseover', this.onMarkerHover.bind(this));
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

      this.markers = this.markersLayer.getLayers();
      this.unfilteredMarkers = this.markersLayer.getLayers();

      this.computeMarkersOptimalPosition();

      this.addMarkersToMap();
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
          spiralInitialDistance = 5;
          spiralAngleFactor     = Math.PI / 3;
          break;

        case mapZoom <= 11:
          spiralGap             = 2;
          spiralInitialDistance = 10;
          spiralAngleFactor     = Math.PI / 3;
          break;

        default:
          spiralGap             = 5;
          spiralInitialDistance = 20;
          spiralAngleFactor     = Math.PI / 3;
          break;
      }

      /* By grouping and filtering the markers, we get an array of all the
       * groups of markers which share the same location (ie an array of arrays
       * of markers with the same location) */
      var latLng;
      var conflictingMarkersGroups = _.filter(_.groupBy(this.markers,
        function(m) {
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
    },

    /* Update the size of the markers according to the map's zoom level */
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

      /* We also update the size of the position markers but as the CSS transform
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
        positionMarkers[i].style.webkitTransform = transform;
      }
    },

    /* Remove the highlight effects to all the map's markers */
    resetMarkersHighlight: function() {
      var highlightedMarkers = this.getAllHighlightedMarkers();
      for(var i = 0, j = highlightedMarkers.length; i < j; i++) {
        highlightedMarkers[i].classList.remove('-active');
      }
    },

    /* Hightlight the marker designated by its type, id and location id. If
     * locationId is omitted, then highlight all the locations of the entity
     * matching the previous parameters. */
    highlightMarkers: function(type, id, locationId) {
      var markers = this.getMarkers(type, id, locationId);
      if(markers.length) {
        for(var i = 0, j = markers.length; i < j; i++) {
          markers[i].classList.add('-active');
        }
      } else {
        markers.classList.add('-active');
      }
    },

    /* Highlight the leaflet markers passed as arguments and add to them a
     * special class so we know they're highlighted because they're linked with
     * the current clicked marker */
    highlightRelatedMarkers: function(marker, relatedMarkers) {
      /* We compute the relations */
      var model = marker.options.type === 'actors' ? this.actorModel :
        this.actionModel;
      var visibleRelations = model.getVisibleRelations();

      var domMarker, relation;
      _.each(relatedMarkers, function(relatedMarker) {
        domMarker = this.getMarkers(relatedMarker.options.type,
          relatedMarker.options.id, relatedMarker.options.locationId);
        if(!domMarker) {
          console.warn('Unable to find the marker /' +
            [ relatedMarker.options.type, relatedMarker.options.id,
            relatedMarker.options.locationId ].join('/') +
            ' on the map');
        } else {
          relation = _.findWhere(visibleRelations, {
            type: relatedMarker.options.type,
            id:   relatedMarker.options.id
          });

          /* We only highlight the marker if the relation is visible */
          if(relation) {
            domMarker.classList.add('-active');
            domMarker.classList.add('js-related-marker');
          }
        }
      }, this);
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

    /* Load the content of the passed marker and display it inside the popup
     * attached to it */
    renderPopup: function(marker) {
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

      /* This event is not documented inside Leaflet's documentation, but
       * trying to attach the event listener of the button right after the
       * "setContent" call fails randomly as it seems that's there's a kind of
       * delay for the event to be thrown (ie. the DOM is already updated and
       * accessible but the event listener can't be attached; waiting for the
       * event to be thrown proved that the issue is adressed) */
      popup.on('contentupdate', function() {
        var $popup = this.$el.find('.leaflet-popup');


        $popup.find('.js-more').on('click', function() {
          this.onMarkerOpen(marker); }.bind(this));
      }.bind(this));

      popup.setContent(this.popupTemplate(model.toJSON()));
    },

    /* Remove a special class from the markers which were related (linked) to
     * the selected one and their highlight */
    resetRelatedMarkers: function() {
      var relatedMarkers = this.el.querySelectorAll('.js-related-marker');
      for(var i = 0, j = relatedMarkers.length; i < j; i++) {
        relatedMarkers[i].classList.remove('js-related-marker');
        relatedMarkers[i].classList.remove('-active');
      }
    },

    /* Toggle the highlight of the related markers */
    toggleRelatedMarkersHighlight: function() {
      var highlightedMarkers = this.el.querySelectorAll('.js-related-marker');
      for(var i = 0, j = highlightedMarkers.length; i < j; i++) {
        highlightedMarkers[i].classList.toggle('-active', true);
      }
    },

    /* Delete all the map's markers */
    removeMarkers: function() {
      this.map.removeLayer(this.markersLayer);
      this.map.removeLayer(this.optimalPositioningLayer);
    },

    /* Filter the markers depending on if they exist at the passed date or if
     * they belong to the passed category.
     * If not, they're hidden.
     * NOTE: this function MUST BE optimized as much as possible because it's
     * called in a requestAnimationFrame (its duration should be less than 10
     * ms) */
    filterMarkers: function(options) {
      if(options.hasOwnProperty('date')) {
        /* If we're asked to filter the markers for the same date, we don't do
         * anything (important for rendering improvements when seing a big range)
         */
        if(this.lastFilterDate && this.lastFilterDate === options.date) {
          return;
        } else {
          this.lastFilterDate = options.date;
        }
      }

      /* If we don't want to filter by a category anymore, we just re-set the
       * last date used to filter */
      if(options.hasOwnProperty('category') && !options.category) {
        options.date = this.lastFilterDate;
      }

      this.map.removeLayer(this.markersLayer);

      /* In case there's no date, we reset the markers */
      if(options.hasOwnProperty('date') && !options.date) {
        this.markers = this.unfilteredMarkers;
        this.lastFilterDate = null;
      } else if(options.hasOwnProperty('date') && options.date) {
        options.date = options.date.getTime();
        this.markers = _.filter(this.unfilteredMarkers,
          function(m) {
          var startDate = m.options.startDate && new Date(m.options.startDate),
              endDate   = m.options.endDate   && new Date(m.options.endDate);
          return !startDate && !endDate ||
            startDate && !endDate && options.date >= startDate.getTime() ||
            !startDate && endDate && options.date <= endDate.getTime() ||
            startDate && endDate && options.date >= startDate.getTime() &&
            options.date <= endDate.getTime();
        });
      } else if(options.hasOwnProperty('category') && options.category) {
        /* We actually filter the markers which were already present on the map
         */
        this.markers = _.filter(this.markersLayer.getLayers(), function(m) {
          if(options.category === 'socio_cultural_domains') {
            return ~m.options.socioCulturalDomains.indexOf(options.categoryId);
          } else {
            return ~m.options.otherDomains.indexOf(options.categoryId);
          }
        });
      }

      this.markersLayer = L.layerGroup(this.markers);
      this.computeMarkersOptimalPosition();

      this.map.removeLayer(this.markersLayer);
      this.map.removeLayer(this.optimalPositioningLayer);
      this.addMarkersToMap();
    },

    /* Add the markers on the map if they can be shown */
    addMarkersToMap: function() {
      if(this.status.get('markersVisible')) {
        if(this.markersLayer) {
          this.markersLayer.addTo(this.map);
        }
        if(this.optimalPositioningLayer) {
          this.optimalPositioningLayer.addTo(this.map);
        }
      }
    },

    /* Toggle the visibility of the markers on the map depending on if they can
     * be shown */
    toggleMarkersVisibility: function() {
      if(this.markersLayer) {
        if(this.status.get('markersVisible')) {
          this.addMarkersToMap();
        } else {
          if(this.map.hasLayer(this.markersLayer)) {
            this.map.removeLayer(this.markersLayer);
          }
          if(this.map.hasLayer(this.optimalPositioningLayer)) {
            this.map.removeLayer(this.optimalPositioningLayer);
          }
        }
      }
    }

  });

})(this);
