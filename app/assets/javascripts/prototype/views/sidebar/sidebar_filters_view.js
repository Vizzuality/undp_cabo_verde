(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};
  root.app.Mixin = root.app.Mixin || {};

  var Status = Backbone.Model.extend({
    defaults: { isHidden: false }
  });

  root.app.View.sidebarFiltersView = Backbone.View.extend({
    el: '#sidebar-filters-view',

    initialize: function(options) {
      this.router = options.router;
      this.status = new Status();
      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(this.router, 'route', this.toggleVisibilityFromRoute);
    },

    /* According to the route broadcast by the router show or hide the pane */
    toggleVisibilityFromRoute: function(route) {
      if(route !== 'welcome') {
        this.hide();
      } else {
        this.show();
      }
    }
  });

  /* We extend the view with method to show, hide and toggle the pane */
  _.extend(root.app.View.sidebarFiltersView.prototype,
    root.app.Mixin.visibility);

})(this);
