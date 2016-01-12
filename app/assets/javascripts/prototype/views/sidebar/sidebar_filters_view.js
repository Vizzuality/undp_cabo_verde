(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};
  root.app.Mixin = root.app.Mixin || {};
  root.app.Helper = root.app.Helper || {};

  var Status = Backbone.Model.extend({
    defaults: { isHidden: false }
  });

  root.app.View.sidebarFiltersView = Backbone.View.extend({

    el: '#sidebar-filters-view',

    events: {
      'click .js-reset': 'resetForm',
      'click .js-apply': 'applyFilters'
    },

    initialize: function(options) {
      this.router = options.router;
      this.status = new Status();
      this.$inputFields = this.$el.find('form .input');
      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(this.router, 'route', this.toggleVisibilityFromRoute);
      this.listenTo(this.status, 'change', this.applySearch);
    },

    /* According to the route broadcast by the router show or hide the pane */
    toggleVisibilityFromRoute: function(route) {
      if(route !== 'welcome') {
        this.hide();
      } else {
        this.show();
      }
    },

    /* Reset the form to its original state and sets the default query
     * parameters in the URL */
    resetForm: function(e) {
      e.preventDefault();

      var field;
      for(var i = 0, j = this.$inputFields.length; i < j; i++) {
        field = this.$inputFields[i];
        if(root.app.Helper.utils.matches(field, 'select')) {
          field.selectedIndex = 0;
        } else if(root.app.Helper.utils.matches(field, 'input[type="date"]')) {
          var date = new Date();
          field.value = [ ('0' + (date.getMonth() + 1)).slice(-2),
            ('0' + date.getDate()).slice(-2), date.getFullYear() ].join('/');
        } else {
          field.value = '';
        }
      }
      this.applyFilters();
    },

    /* Save the form state into the status model */
    applyFilters: function(e) {
      if(e) { e.preventDefault(); }

      console.warn('The feature is only partially implemented');

      var field, value, summary = {};
      for(var i = 0, j = this.$inputFields.length; i < j; i++) {
        field = this.$inputFields[i];
        /* If the field is a select element, we retrieve the value of the
         * selected option */
        if(root.app.Helper.utils.matches(field, 'select')) {
          var selectedIndex = field.selectedIndex;
          summary[field.name] = field.options[selectedIndex].value;
        } else {
          summary[field.name] = field.value;
        }
      }
      this.router.setQueryParams(summary);
    }

  });

  /* We extend the view with method to show, hide and toggle the pane */
  _.extend(root.app.View.sidebarFiltersView.prototype,
    root.app.Mixin.visibility);

})(this);
