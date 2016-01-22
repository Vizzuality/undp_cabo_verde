(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.pubsub  = root.app.pubsub || {};

  var QueryParams = Backbone.Model.extend({});

  root.app.Router = Backbone.Router.extend({

    routes: {
      '(/)': 'welcome',
      'about(/)': 'about',
      'actors/:id/:locationId(/)': 'actors',
      'actions/:id/:locationId(/)': 'actions'
    },

    initialize: function() {
      this.queryParams = new QueryParams();
      this.currentRoute = { name: null, params: [] };

      this.retrieveQueryParams();
      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(this.queryParams, 'change', this.queryParamsOnChange);
      this.listenTo(this, 'route', this.saveCurrentRoute);
    },

    /* Save the current route and its parameters */
    saveCurrentRoute: function() {
      this.currentRoute = {
        name: arguments[0],
        params: [].slice.call(arguments, 1)[0]
      };
    },

    /* Return the current route */
    getCurrentRoute: function() {
      return this.currentRoute;
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
          if(_.isArray(value)) {
            /* If the array is empty, we don't add anything to the URL */
            if(value.length === 0) return str;

            return str + (str.length === 0 ? '?' : '&') + key + '[]=' +
              value.join(',');
          }
          return str + (str.length === 0 ? '?' : '&') + key + '=' + value;
        } else {
          return str;
        }
      }, '');

      history.replaceState(null, null, serializedParams);
    },

    /* Get the query params from the URL and save them to the model
     * NOTE: when this method is called from initialize, the change events won't
     * be caught by queryParamsOnChange because it's called before the listeners
     * are initialized */
    retrieveQueryParams: function() {
      var query = location.search.replace('?', '');
      /* If we don't have query params, we exit the method */
      if(query.length === 0) {
        return;
      }

      var pairs = query.split('&');
      _.each(pairs, function(pair) {
        if(pair.split('=').length !== 2) {
          console.warn('Invalid query parameter: ' + pair);
        } else {
          var key   = pair.split('=')[0],
              value = pair.split('=')[1];

          var isArray = /\[\]$/.test(key);
          if(isArray) {
            value = value.length === 0 ? [] : value.split(',');
            key = key.replace('[]', '');
          }

          this.queryParams.set(key, value);
        }
      }, this);
    }

  });

})(this);
