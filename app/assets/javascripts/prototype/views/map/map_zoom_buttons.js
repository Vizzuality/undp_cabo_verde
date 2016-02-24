(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};

  var Status = Backbone.Model.extend({
    defaults: { graphVisible: false }
  });

  root.app.View.mapZoomButtonsView = Backbone.View.extend({

    el: '.l-map',

    events: {
      'click .js-zoom-to-fit': 'onZoomToFit'
    },

    initialize: function() {
      this.status = new Status();

      this.zoomToFitButton = document.querySelector('.js-zoom-to-fit');

      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(this.status, 'change:graphVisible',
        this.toggleButtonsPosition);
    },

    onZoomToFit: function(e) {
      if(!this.zoomToFitButton.classList.contains('-disabled')) {
        this.trigger('click:zoomToFit');
      }
    },

    /* Reduce the visible portion of the legend or not depending on if the
     * relations are visible on the map */
    toggleButtonsPosition: function() {
      if(!this.zoomButtons) {
        this.zoomButtons = this.el.querySelector('.leaflet-control-zoom');
      }

      this.zoomButtons.classList.toggle('-slided',
        this.status.get('graphVisible'));
      this.zoomToFitButton.classList.toggle('-slided',
        this.status.get('graphVisible'));
    },

    /* Enable the button zoom to fit */
    enableZoomToFit: function() {
      this.zoomToFitButton.classList.remove('-disabled');
    },

    /* Disable the button zoom to fit */
    disableZoomToFit: function() {
      this.zoomToFitButton.classList.add('-disabled');
    }

  });

})(this);
