(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};

  var Status = Backbone.Model.extend({
    defaults: { activeTab: 'overall' }
  });

  root.app.View.tabNavigationView = Backbone.View.extend({

    el: document.querySelector('.tab-navigation'),

    events: {
      'click li': 'onTabChange'
    },

    initialize: function(options) {
      this.status = new Status();
      this.router = options.router;
      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(this.status, 'change:activeTab', this.triggerTabChange);
      this.listenTo(root.app.pubsub, 'show:actor', this.onActorShow);
      this.listenTo(root.app.pubsub, 'show:action', this.onActionShow);
    },

    /* EVENTS HANDLERS */

    onActorShow: function() {
      this.setActiveTab('overall');
    },

    onActionShow: function() {
      this.setActiveTab('overall');
    },

    onTabChange: function(e) {
      e.preventDefault();
      var selectedTab     = e.currentTarget,
          selectedTabName = selectedTab.getAttribute('data-tab');
      this.setActiveTab(selectedTabName);
    },

    /* LOGIC */

    /* Switch the active tab to the one passed as argument */
    setActiveTab: function(selectedTabName) {
      var selectedTab   = this.el.querySelector('li[data-tab="' + selectedTabName + '"]'),
          activeTabName = this.status.get('activeTab'),
          activeTab     = this.el.querySelector('li[data-tab="' + activeTabName + '"]');

      if(activeTabName !== selectedTabName) {
        activeTab.classList.remove('-active');
        selectedTab.classList.add('-active');
        this.status.set('activeTab', selectedTabName);
      }
    },

    /* Trigger an event to notify the tab change. Send the atrributes:
     * - previousTab: {String}
     * - newTab: {String}
     */
    triggerTabChange: function() {
      this.trigger('tab:change', {
        previousTab: this.status.previousAttributes().activeTab,
        newTab:      this.status.get('activeTab')
      });
    },

  });

})(this);
