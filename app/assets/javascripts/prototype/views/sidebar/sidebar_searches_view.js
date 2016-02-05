(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};
  root.app.Model = root.app.Model || {};
  root.app.Mixin = root.app.Mixin || {};
  root.app.pubsub = root.app.pubsub || {};

  var Status = Backbone.Model.extend({
    defaults: { isHidden: true}
  });

  root.app.View.sidebarSearchesView = Backbone.View.extend({
    el: '#sidebar-searches-view',

    events: {
      'click .js-back': 'goBack'
    },

    template: HandlebarsTemplates['sidebar/sidebar_searches_template'],

    initialize: function(options) {
      this.status = new Status();
      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(root.app.pubsub, 'click:goBack', this.hide);
      this.listenTo(root.app.pubsub, 'show:searches', this.render);
    },

    getSavedSearches: function() {
      var searches = JSON.parse(localStorage.getItem('searches'));
      return searches;
    },

    render: function() {
      //get data from localStorage
      var array = this.getSavedSearches();

      var array2 = [
        {name: "Andrew"},
        {name: "Michael", age: 22}
      ];

      this.$el.html(this.template(array));
      /* We finally slide the pane to display the information */
      this.show();
    }
  });

  /* We extend the view with method to show, hide and toggle the pane */
  _.extend(root.app.View.sidebarSearchesView.prototype, root.app.Mixin.visibility);

})(this);
