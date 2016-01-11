(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};
  root.app.Mixin = root.app.Mixin || {};
  root.app.Helper = root.app.Helper || {};

  var Status = Backbone.Model.extend({
    defaults: { isHidden: false }
  });

  root.app.View.rangesliderView = Backbone.View.extend({

    el: '#map-rangeslider',

    events: {
      'click .sliderlink': 'confirm'
    },

    initialize: function(options) {
      this.router = options.router;
      this.status = new Status();
      $("#slider").slider({
        animate: "fast",
        max: 2010,
        min: 1991,
        range: true,
        step: 1,
        values: [1995, 2005]
      });
      this.setListeners();
    },

    setListeners: function() {
      // this.listenTo(this.router, 'route', this.toggleVisibilityFromRoute);
      // this.listenTo(this.status, 'change', this.applySearch);
    },

    confirm: function() {

    }

  });

})(this);
