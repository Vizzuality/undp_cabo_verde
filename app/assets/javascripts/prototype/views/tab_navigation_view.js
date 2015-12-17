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
      'click li': 'tabChangeListener'
    },

    initialize: function(options) {
      this.status = new Status();
      this.router = options.router;
      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(this.status, 'change:activeTab', this.triggerTabChange);
      this.listenTo(this.router, 'route', this.updateActiveTabFromRoute);
    },

    /* Show the active tab in the DOM and modify the activeTab property of the
     * status model */
    tabChangeListener: function(e) {
      e.preventDefault();
      var selectedTab     = e.currentTarget,
          selectedTabName = selectedTab.getAttribute('data-tab');
      this.setActiveTab(selectedTabName);
    },

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

    /* Set the active tab depending on the route passed as argument */
    updateActiveTabFromRoute: function(route) {
      switch(route) {
        case 'actor':
          this.setActiveTab('overall');
          break;
      }
    }

  });

})(this);
