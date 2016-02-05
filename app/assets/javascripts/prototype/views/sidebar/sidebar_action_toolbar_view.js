(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};
  root.app.Model = root.app.Model || {};
  root.app.Mixin = root.app.Mixin || {};

  root.app.View.sidebarActionToolbarView = Backbone.View.extend({
    el: '#sidebar-action-toolbar-view',

    events: {
      'click .js-back': 'goBack',
      'click .js-searches': 'showSearches'
    },

    initialize: function(options) {
      this.router = options.router;
      this.$goBackButton = this.$el.find('.js-back');
      this.setListeners();
      this.init();
    },

    setListeners: function() {
      this.listenTo(root.app.pubsub, 'show:actor', this.showGoBackButton);
      this.listenTo(root.app.pubsub, 'show:action', this.showGoBackButton);
      this.listenTo(root.app.pubsub, 'show:searches', this.showGoBackButton);
      this.listenTo(root.app.pubsub, 'click:goBack', this.hideGoBackButton);
    },

    /* Set the initial visibility of the go back button */
    init: function() {
      var route = this.router.getCurrentRoute();
      if(route.name === 'actors' || route.name === 'actions') {
        this.showGoBackButton();
      }
    },

    /* Reset the URL to its original state */
    goBack: function() {
      this.router.navigate('/', { trigger: true });
      root.app.pubsub.trigger('click:goBack');
    },

    showGoBackButton: function() {
      this.$goBackButton.removeClass('_hidden');
      this.$goBackButton.attr('aria-hidden', 'false');
    },

    hideGoBackButton: function() {
      this.$goBackButton.addClass('_hidden');
      this.$goBackButton.attr('aria-hidden', 'true');
    },

    showSearches: function() {
      console.warn('Feature not yet implemented');
    }

  });

})(this);
