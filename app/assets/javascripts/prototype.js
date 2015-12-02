//= require jquery2
//= require underscore
//= require backbone

//= require prototype/router
//= require_tree ./prototype/helpers
//= require_tree ./prototype/views
//= require_tree ./prototype/collections

(function(root) {

  'use strict';

  /**
   * Provide top-level namespaces for our javascript.
   * @type {Object}
   */
  root.app = root.app || {
    Model: {},
    Collection: {},
    View: {},
    Helper: {}
  };

  /**
   * Main Application View
   */
  root.app.AppView = Backbone.View.extend({

    /**
     * Main DOM element
     * @type {Object}
     */
    el: document.querySelector('body > .container'),

    initialize: function() {
      this.router = new root.app.Router();

      this.actorsCollection = new root.app.Collection.actorsCollection();

      this.sidebarView = new root.app.View.sidebarView({
        actorsCollection: this.actorsCollection
      });
      this.mapView = new root.app.View.mapView({
        actorsCollection: this.actorsCollection
      });

      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(this.router, 'route:welcome', this.welcomePage);
      this.listenTo(this.router, 'route:about', this.aboutPage);
    },

    welcomePage: function() {
      this.actorsCollection.fetch();
    },

    aboutPage: function() {

    },

    start: function() {
      Backbone.history.start({ pushState: false });
    }

  });

  new app.AppView().start();

})(this);
