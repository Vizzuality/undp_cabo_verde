(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};

  var Status = Backbone.Model.extend({
    defaults: { sidebarVisible: true }
  });

  root.app.View.mapButtonsView = Backbone.View.extend({

    el: '#map-buttons',

    events: {
      'change .js-relationships-checkbox': 'onGraphToggle'
    },

    initialize: function() {
      this.status = new Status();

      this.relationsButton = this.el.querySelector('.js-relationships-checkbox');
    },

    onGraphToggle: function(e) {
      this.trigger('toggle:graph', { visible: e.currentTarget.checked });
    },

    /* Move the buttons to the right when the sidebar is hidden or to the left
     * when it's expanded */
    toggleButtonsPosition: function() {
      this.el.classList.toggle('-slided', !this.status.get('sidebarVisible'));

      if(!this.credits) {
        this.credits = document.querySelector('.l-map .leaflet-control-attribution');
      }
      this.credits.classList.toggle('-slided',
        !this.status.get('sidebarVisible'));
    },

    /* Toggle the relations buttons depending on the visible attribute from the
     * options object passed as argument */
    toggleRelationsButton: function(options) {
      this.relationsButton.checked = options.visible;
    }

  });

})(this);
