(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.pubsub  = root.app.pubsub || {};

  var QueryParams = Backbone.Model.extend({
    defaults: { isHidden: false }
  });

  root.app.Router = Backbone.Router.extend({

    routes: {
      '(/)': 'welcome',
      'about(/)': 'about',
      'actors/:id/:locationId(/)': 'actor',
      'actions/:id/:locationId(/)': 'action'
    },

    initialize: function() {
      this.queryParams = new QueryParams();
      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(this.queryParams, 'change', this.queryParamsOnChange);
    },
    
    /* Save the query params passed as argument inside the queryParams model */
    setQueryParams: function(params) {
      this.queryParams.set(params);
    },

    /* Return a JSON representation of the queryParams model */
    getQueryParams: function() {
      return this.queryParams.toJSON();
    },

    /* Called when the query params are updated: call method to updated the URL
     * and trigger the change */
    queryParamsOnChange: function() {
      this.updateUrlFromQueryParams();
      this.triggerQueryParams();
    },

    /* Trigger an event change:queryParams with the attributes from the model
     * queryParams */
    triggerQueryParams: function() {
      this.trigger('change:queryParams', this.getQueryParams());
    },

    /* Update the query part of the URL with the attributes contained in the
     * model queryParams */
    updateUrlFromQueryParams: function() {
      var serializedParams = _.reduce(this.getQueryParams(),
        function(str, value, key) {
        if(value.length > 0) {
          return str + (str.length === 0 ? '?' : '&') + key + '=' + value;
        } else {
          return str;
        }
      }, '');

      history.replaceState(null, null, serializedParams);
    }

  });

})(this);
