//= require i18n
//= require i18n.js
//= require i18n/translations
//= require jquery2
//= require jquery_ujs
//= require jquery.ui.datepicker
//= require underscore
//= require backbone
//= require handlebars
//= require d3
//= require LeafletTextPath/leaflet.textpath

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
      Backbone.history.start({ pushState: false });

      this.mapView = new root.app.View.mapView({
        router: this.router
      });
      this.sidebarView = new root.app.View.sidebarView({
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
      this.searchesView = new root.app.View.sidebarSearchesView({
        router: this.router
      });

      this.setListeners();
    },

    /* Application-wide listeners which are not binded to any UI component */
    setListeners: function() {
      document.addEventListener('click', this.triggerDocumentClick);
    },

    triggerDocumentClick: function() {
      root.app.pubsub.trigger('click:document');
    }

  });

  new app.AppView();

})(this);
