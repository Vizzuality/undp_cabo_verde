(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};

  var Status = Backbone.Model.extend({
    defaults: { relationshipsVisible: true }
  });

  root.app.View.mapZoomButtonsView = Backbone.View.extend({

    el: '.l-map',

    initialize: function() {
      this.status = new Status();
    },

    /* Reduce the visible portion of the legend or not depending on if the
     * relations are visible on the map */
    toggleButtonsPosition: function() {
      if(!this.zoomButtons) {
        this.zoomButtons = this.el.querySelector('.leaflet-control-zoom');
      }

      this.zoomButtons.classList.toggle('-slided',
        !this.status.get('relationshipsVisible'));
    }

  });

})(this);
