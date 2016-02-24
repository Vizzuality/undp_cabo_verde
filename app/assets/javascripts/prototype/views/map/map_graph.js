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

      var relationTypes = _.keys(_.groupBy(relations, function(relation) {
        return relation.relation_type_slug;
      }));

      var relationColors = this.getColorScale(relationTypes.length);

      var relationTypeToColor = {};
      for(var i = 0, j = relationTypes.length; i < j; i++) {
        relationTypeToColor[relationTypes[i]] = relationColors[i];
      }

      var startLatLng, endLatLng, line;
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

        line = L.polyline([startLatLng, endLatLng]);

        line.options.color   = relationTypeToColor[relation.relation_type_slug];
        line.options.weight  = 2;
        line.options.opacity = 1;

        return line;
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
    },

    /* Return colorCount different CSS HSL colors by making variation of the
     * hue, and avoiding a large spectrum of the blue one (to avoid conflicts
     * with the basemap) and a small portion of the red and green so we don't
     * have too similar colors. The colors grey and red will be always outputed:
     * the first because it can't be obtained from a hue variation and the
     * second because of the nature of the algorithm. The saturation is set at
     * 100% and lightness at 40% to have colors darker then their hues. */

    /* Return colorCount different HSL colors by making variations of the hue,
     * saturation and lightness (HSL) according to the parameters set by the
     * user within the method. The hue range can be restricted to some portions
     * of it, and the saturation and lightness can be fixed or computed from the
     * hue, the color index number or any other algorithm. Moreover, some colors
     * can be set by default so they will always be returned.
     * NOTE: the current configuration removes the blue, a part of the green and
     * the red right hand part of the hue range to avoid collision with the
     * basemap color and avoiding having to many similar green and red colors.
     * Also, the lightness varies between two consecutive values to make sure
     * two colors with a similar hue will be visually different. */
    getColorScale: function(colorCount) {
      /* We first define the parameters of the algorithm:
       *  - hueRange is the range where the hues are extracted from
       *  - saturation can be a fixed value or a function to which the hue and
       *    the color index will be passed
       *  - lightness can be passed the same values as saturation
       *  - colors is an array of colors that will always be returned (for
       *    example colors that can't be obtained by just changing the hue like
       *    black and white) */
      var hueRange   = [ [ 0, 80 ], [ 95, 120 ], [ 150, 210 ], [ 270, 320 ] ],
          saturation = 100,
          lightness  = function(hue, index) { return index % 2 ? 70 : 55; },
          colors     = [ 'hsl(0, 0%, 70%)' ];

      /* In case we're asked fewer colors than the ones defined by default, we
       * directly use them */
      if(colorCount <= colors.length) return colors.slice(0, colorCount + 1);

      /* We compute the length of the virtual hue range by summing each
       * individual range */
      var hueExtent = hueRange.reduce(function(sum, range) {
        return sum + range[1] - range[0];
      }, 0);

      /* We compute the step between each color using our virtual scale */
      var hueStep = ~~ (hueExtent / colorCount);

      var hue;
      for(var i = 0, j = colorCount - colors.length; i < j; i++) {
        hue = i * hueStep;

        /* We now need to make the conversion from the hue virtual scale to the
         * real one to retrieve the final value */
        for(var k = 0, l = hueRange.length; k < l; k++) {
          if(hue > hueRange[k][1]) hue += hueRange[k + 1][0] - hueRange[k][1];
        }

        /* Now we have the hue, we compute the saturation and lightness */
        if(typeof saturation === 'function') saturation = saturation(hue, i);
        if(typeof lightness  === 'function') lightness  = lightness (hue, i);

        colors.push('hsl(' + hue + ', ' + saturation + '%, ' + lightness + '%)');
      }

      return colors;
    }

  });

})(this);
