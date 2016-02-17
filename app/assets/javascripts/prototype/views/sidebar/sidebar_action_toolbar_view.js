(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View   = root.app.View || {};
  root.app.Model  = root.app.Model || {};
  root.app.Mixin  = root.app.Mixin || {};
  root.app.Helper = root.app.Helper || {};

  root.app.View.sidebarActionToolbarView = Backbone.View.extend({
    el: '#sidebar-action-toolbar-view',

    events: {
      'click .js-back': 'goBack',
      'click .js-account': 'onAccountClick',
      'click .js-searches': 'onSearchesClick'
    },

    initialize: function(options) {
      this.router = options.router;
      this.$goBackButton = this.$el.find('.js-back');
      this.accountPopover = this.el.querySelector('.js-account-popover');

      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(root.app.pubsub, 'click:document', this.hideAccountPopover);
    },

    onAccountClick: function(e) {
      e.stopPropagation();
      /* When clicking within the popover, if we don't catch the event, it
       * bubbles until the account button which toggles it. We then need to
       * check if the user actually wanted it. */
      if(root.app.Helper.utils.matches(e.target, '.js-account')) {
        this.toggleAccountPopover();
      }
    },

    onSearchesClick: function() {
      this.hideAccountPopover();
      this.goBack();
      this.trigger('click:searches');
    },

    /* Reset the URL to its original state */
    goBack: function() {
      this.trigger('click:goBack');
      this.hideGoBackButton();
    },

    showGoBackButton: function() {
      this.$goBackButton.removeClass('_hidden');
      this.$goBackButton.attr('aria-hidden', 'false');
    },

    hideGoBackButton: function() {
      this.$goBackButton.addClass('_hidden');
      this.$goBackButton.attr('aria-hidden', 'true');
    },

    /* Toggle the visibility of the accounr popover, accept a boolean to force
     * the popover to be visible or hidden */
    toggleAccountPopover: function(isVisible) {
      if(typeof isVisible === 'undefined') {
        this.accountPopover.classList.toggle('_hidden');
      } else {
        this.accountPopover.classList.toggle('_hidden', !isVisible);
      }
    },

    /* Show the account popover */
    showAccountPopover: function() {
      this.toggleAccountPopover(true);
    },

    /* Hide the account popover */
    hideAccountPopover: function() {
      this.toggleAccountPopover(false);
    }

  });

})(this);
