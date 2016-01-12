(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.pubsub  = root.app.pubsub || {};

  var QueryParams = Backbone.Model.extend({});

  root.app.Router = Backbone.Router.extend({

    routes: {
      '(/)': 'welcome',
      'about(/)': 'about',
      'actors/:id/:locationId(/)': 'actor',
      'actions/:id/:locationId(/)': 'action'
    },

    initialize: function() {
      this.queryParams = new QueryParams();
      this.retrieveQueryParams();
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
          if(_.isArray(value)) {
            return str + (str.length === 0 ? '?' : '&') + key + '=' +
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
      var pairs = query.split('&');
      _.each(pairs, function(pair) {
        if(pair.split('=').length !== 2) {
          console.warn('Invalid query parameter: ' + pair);
        } else {
          var key   = pair.split('=')[0],
              value = pair.split('=')[1];
          /* If the value contains ",", then we save it as an array */
          if(value.split(',').length > 1) {
            value = value.split(',');
          }
          this.queryParams.set(key, value);
        }
      }, this);
    }

  });

})(this);
