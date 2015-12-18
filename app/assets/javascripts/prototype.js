//= require jquery2
//= require underscore
//= require backbone
//= require handlebars

//= require prototype/router
//= require_tree ./prototype/mixins
//= require_tree ./prototype/helpers
//= require_tree ./prototype/templates
//= require_tree ./prototype/views
//= require_tree ./prototype/collections
//= require_tree ./prototype/models

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
    Helper: {},
    Mixin: {}
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
        actorsCollection: this.actorsCollection,
        router: this.router
      });
      this.mapView = new root.app.View.mapView({
        actorsCollection: this.actorsCollection,
        router: this.router
      });
      this.filtersView = new root.app.View.sidebarFiltersView({
        router: this.router
      });
      this.actorView = new root.app.View.sidebarActorView({
        router: this.router
      });

      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(this.router, 'route:welcome', this.welcomePage);
      this.listenTo(this.router, 'route:actor', this.fetchCollections);
      this.listenTo(this.router, 'route:about', this.aboutPage);
    },

    welcomePage: function() {
      this.fetchCollections();
    },

    aboutPage: function() {

    },

    fetchCollections: function() {
      if(this.actorsCollection.length === 0) {
        this.actorsCollection.fetch();
      }
    },

    start: function() {
      Backbone.history.start({ pushState: false });
    }

  });

  new app.AppView().start();

})(this);
