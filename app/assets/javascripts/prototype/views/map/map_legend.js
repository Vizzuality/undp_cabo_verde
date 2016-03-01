(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};

  var Status = Backbone.Model.extend({
    defaults: { graphVisible: false }
  });

  root.app.View.mapLegendView = Backbone.View.extend({

    el: '#map-legend',

    initialize: function(options) {
      this.router = options.router;
      this.status = new Status();

      /* Cache for the relationships part of the legend */
      this.$actorToActionLegend = this.$el.find('.js-actor-to-action');
      this.$actorToActorLegend = this.$el.find('.js-actor-to-actor');
      this.$actionToActionLegend = this.$el.find('.js-action-to-action');
      this.$standardLegend = this.$el.find('.js-standard-legend');
      this.$alternativeLegend = this.$el.find('.js-alternative-legend');

      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(this.status, 'change:graphVisible', this.toggleLegendState);
    },

    // /* Reduce the visible portion of the legend or not depending on if the
    //  * relations are visible on the map */
    // toggleLegendPosition: function() {
    //   this.el.classList.toggle('-reduced',
    //     !this.status.get('relationshipsVisible'));
    // },

    toggleLegendState: function() {
      if(!this.status.get('graphVisible')) {
        this.$alternativeLegend.addClass('-hidden');
        this.$standardLegend.removeClass('-hidden');
      }
    },

    showAlternativeLegend: function(options) {
      var html = '<ul>';
      html += '<li class="title">' + I18n.translate('front.relationships') +
        '</li>';

      _.map(options, function(color, title) {
        html += '<li><svg class="icon -large">' +
          '<use xlink:href="#actorToActorIcon" x="0" y="6" stroke="' +
          color + '"/></svg><span class="label">' + title + '</span></li>';
      });

      html += '</ul>';

      this.$alternativeLegend.html(html).removeClass('-hidden');
      this.$standardLegend.addClass('-hidden');
    },

    /* Dynamically hide a part of the relations depending on the active marker
     * type: if a marker is passed as parameter (Leaflet object),
     * consider it as the active marker, otherwise, take into account the marker
     * attached to the current URL. If there's no active marker, reset the
     * legend in its original state. */
    updateLegendRelations: function(marker) {
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
    }

  });

})(this);
