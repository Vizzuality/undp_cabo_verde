(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};
  root.app.Model = root.app.Model || {};
  root.app.Mixin = root.app.Mixin || {};

  root.app.View.sidebarActionToolbarView = Backbone.View.extend({
    el: '#sidebar-action-toolbar-view',

    events: {
      'click .js-back': 'goBack'
    },

    initialize: function(options) {
      this.router = options.router;
      this.$goBackButton = this.$el.find('.js-back');
      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(this.router, 'route', this.updateFromRoute);
    },

    /* According to the route broadcast by the router show or hide options from
     * the toolbar */
    updateFromRoute: function(route) {
      switch(route) {
        case 'actor':
          this.showGoBackButton();
          break;

        default:
          this.hideGoBackButton();
          break;
      }
    },

    /* Reset the URL to its original state */
    goBack: function() {
      this.router.navigate('/', { trigger: true });
    },

    showGoBackButton: function() {
      this.$goBackButton.removeClass('_hidden');
      this.$goBackButton.attr('aria-hidden', 'false');
    },

    hideGoBackButton: function() {
      this.$goBackButton.addClass('_hidden');
      this.$goBackButton.attr('aria-hidden', 'true');
    }
  });

})(this);
