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
      'click .js-zoom-to-extent': 'onZoomToExtent',
      'click .js-zoom-to-selection': 'onZoomToSelection'
    },

    initialize: function() {
      this.status = new Status();

      this.zoomToExtentButton = document.querySelector('.js-zoom-to-extent');
      this.zoomToSelectionButton = document.querySelector('.js-zoom-to-selection');
    },

    onZoomToExtent: function(e) {
      if(!this.zoomToExtentButton.classList.contains('-disabled')) {
        this.trigger('click:zoomToExtent');
      }
    },

    onZoomToSelection: function(e) {
      if(!this.zoomToSelectionButton.classList.contains('-disabled')) {
        this.trigger('click:zoomToSelection');
      }
    },

    /* Enable the button zoom to extent */
    enableZoomToExtent: function() {
      this.zoomToExtentButton.classList.remove('-disabled');
    },

    /* Disable the button zoom to extent */
    disableZoomToExtent: function() {
      this.zoomToExtentButton.classList.add('-disabled');
    },

    /* Enable the button zoom to selection */
    enableZoomToSelection: function() {
      this.zoomToSelectionButton.classList.remove('-disabled');
    },

    /* Disable the button zoom to selection */
    disableZoomToSelection: function() {
      this.zoomToSelectionButton.classList.add('-disabled');
    }

  });

})(this);
