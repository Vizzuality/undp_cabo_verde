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
      /* We update the action to action icon */
      this.$actionToActionLegend.find('svg')[0].classList.toggle('-actions',
        this.status.get('graphVisible'));
      this.$actionToActionLegend.find('svg')[0].classList.toggle('-monochrome',
        !this.status.get('graphVisible'));

      /* We update the actor to actor icon */
      this.$actorToActorLegend.find('svg')[0].classList.toggle('-actors',
        this.status.get('graphVisible'));
      this.$actorToActorLegend.find('svg')[0].classList.toggle('-monochrome',
        !this.status.get('graphVisible'));

      /* We update the actor to action icon */
      this.$actorToActionLegend.find('svg')[0].classList.toggle('-mixed',
        this.status.get('graphVisible'));
      this.$actorToActionLegend.find('svg')[0].classList.toggle('-monochrome',
        !this.status.get('graphVisible'));
      this.$actorToActionLegend.find('svg > use')[0].setAttribute('xlink:href',
        this.status.get('graphVisible') ? '#actorToActorIcon' :
        '#actorToActionIcon');

      this.el.classList.toggle('-reduced',
        this.status.get('graphVisible'));
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
