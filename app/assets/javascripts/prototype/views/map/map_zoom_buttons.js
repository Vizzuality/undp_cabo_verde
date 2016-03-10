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
      'click .js-zoom-to-extent': 'onZoomToExtent'
    },

    initialize: function() {
      this.status = new Status();

      this.zoomToExtentButton = document.querySelector('.js-zoom-to-extent');
    },

    onZoomToExtent: function(e) {
      if(!this.zoomToExtentButton.classList.contains('-disabled')) {
        this.trigger('click:zoomToExtent');
      }
    },

    /* Enable the button zoom to fit */
    enableZoomToExtent: function() {
      this.zoomToExtentButton.classList.remove('-disabled');
    },

    /* Disable the button zoom to fit */
    disableZoomToExtent: function() {
      this.zoomToExtentButton.classList.add('-disabled');
    }

  });

})(this);
