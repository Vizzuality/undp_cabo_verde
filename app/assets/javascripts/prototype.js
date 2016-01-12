//= require i18n
//= require i18n.js
//= require i18n/translations
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
    Mixin: {},
    pubsub: {}
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

      this.actorsCollection = new root.app.Collection.actorsCollection(null, {
        router: this.router
      });
      this.actionsCollection = new root.app.Collection.actionsCollection(null, {
        router: this.router
      });

      this.mapView = new root.app.View.mapView({
        actorsCollection: this.actorsCollection,
        actionsCollection: this.actionsCollection,
        router: this.router
      });
      this.sidebarView = new root.app.View.sidebarView({
        actorsCollection: this.actorsCollection,
        actionsCollection: this.actionsCollection,
        router: this.router
      });
      this.sidebarActionToolbarView = new root.app.View.sidebarActionToolbarView({
        router: this.router
      });
      this.filtersView = new root.app.View.sidebarFiltersView({
        router: this.router
      });
      this.actorView = new root.app.View.sidebarActorView({
        router: this.router
      });
      this.actionView = new root.app.View.sidebarActionView({
        router: this.router
      });

      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(this.router, 'route:welcome', this.welcomePage);
      this.listenTo(this.router, 'route:actor', this.fetchCollections);
      this.listenTo(this.router, 'route:action', this.fetchCollections);
      this.listenTo(this.router, 'route:about', this.aboutPage);
      this.listenTo(this.router, 'change:queryParams', function() {
        this.fetchCollections({ force: true });
      }.bind(this));
    },

    welcomePage: function() {
      this.fetchCollections();
    },

    aboutPage: function() {

    },

    fetchCollections: function(options) {
      if(this.actorsCollection.length === 0 || options && options.force) {
        this.actorsCollection.fetch();
      }
      if(this.actionsCollection.length === 0 || options && options.force) {
        this.actionsCollection.fetch();
      }
    },

    start: function() {
      Backbone.history.start({ pushState: false });
    }

  });

  new app.AppView().start();

})(this);
