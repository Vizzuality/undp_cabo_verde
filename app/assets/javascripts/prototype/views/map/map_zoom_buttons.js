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
    },

    onZoomToFit: function(e) {
      if(!this.zoomToFitButton.classList.contains('-disabled')) {
        this.trigger('click:zoomToFit');
      }
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
