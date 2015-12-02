(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};

  var Status = Backbone.Model.extend({
    defaults: { isHidden: false }
  });

  root.app.View.sidebarView = Backbone.View.extend({

    el: document.querySelector('.l-sidebar'),

    initialize: function(options) {
      this.status = new Status();
      this.tabNavigationView = new root.app.View.tabNavigationView();
      this.$toggleSwitch = this.$el.find('.toggleswitch');
      this.actorsCollection = options.actorsCollection;
      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(this.status, 'change:isHidden', this.triggerVisibility);
      this.listenTo(this.tabNavigationView, 'tab:change', this.switchContent);
      this.$toggleSwitch.on('click', this.toggleSidebar.bind(this));
    },

    /* Switch the content of the sidebar by the one that have been asked by
     * tabNavigationView. Params contains the previous' and new tab's name
     * (see tabNavigationView) */
    switchContent: function(params) {
      var previousContent = this.el.querySelector('[data-content="' + params.previousTab + '"]'),
          newContent      = this.el.querySelector('[data-content="' + params.newTab + '"]');

      previousContent.classList.add('_hidden');
      previousContent.setAttribute('aria-hidden', 'true');
      newContent.classList.remove('_hidden');
      newContent.setAttribute('aria-hidden', 'false');
    },

    /* Toggle the sidebar by using a CSS transform translateX property and
     * update the model's attribute isHidden */
    toggleSidebar: function(e) {
      e.preventDefault();
      var isHidden = this.el.classList.toggle('-hidden');
      this.el.setAttribute('aria-hidden', isHidden);
      this.$toggleSwitch[0].setAttribute('aria-expanded', !isHidden);
      this.status.set('isHidden', isHidden);
    },

    /* Trigger the sidebar's visibility with the object:
     * {
     *    isHidden: {boolean}
     * }
     */
    triggerVisibility: function() {
      this.trigger('sidebar:visibility', {
        isHidden: this.status.get('isHidden')
      });
    }

  });

})(this);
