//= require i18n
//= require i18n.js
//= require i18n/translations
//= require jquery2
//= require jquery_ujs
//= require jquery.ui.slider
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
      this.rangesliderView = new root.app.View.rangesliderView({
        router: this.router
      });

      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(this.router, 'route:welcome',
        this.fetchFilteredCollections);
      this.listenTo(this.router, 'route:actor', this.fetchFilteredCollections);
      this.listenTo(this.router, 'route:action', this.fetchFilteredCollections);
      this.listenTo(this.router, 'route:about', this.aboutPage);
      this.listenTo(this.router, 'change:queryParams',
        this.fetchFilteredCollections);
    },

    aboutPage: function() {

    },

    /* Fetch only the collections that are not filtered out */
    fetchFilteredCollections: function() {
      var queryParams = this.router.getQueryParams();

      /* If one of the required filter doesn't have any value, we just don't
       * fetch the collections, the user will see a warning in the sidebar
       * anyway */
      if(queryParams.types && queryParams.types.length === 0 ||
        queryParams.levels && queryParams.levels.length === 0 ||
        queryParams.domains_ids && queryParams.domains_ids.length === 0) {
        return;
      }

      if(!queryParams.types || queryParams.types.length === 2) {
        this.fetchCollections({ force: true });
      } else {
        this.fetchCollections({ force: true, only: queryParams.types[0] });
      }
    },

    /* Fetch the actor and actions collections if empty
     * Options:
     *  - force (boolean): force the collections to be fetched
     *  - only ("actors" or "actions"): restrict the fetch to only one
     *    collection */
    fetchCollections: function(options) {
      if((this.actorsCollection.length === 0 || options && options.force) &&
        (!(options && options.only) || options && options.only === 'actors')) {
        this.actorsCollection.fetch();
      }
      if((this.actionsCollection.length === 0 || options && options.force) &&
        (!(options && options.only) || options && options.only === 'actions')) {
        this.actionsCollection.fetch();
      }
    },

    start: function() {
      Backbone.history.start({ pushState: false });
    }

  });

  new app.AppView().start();

})(this);
