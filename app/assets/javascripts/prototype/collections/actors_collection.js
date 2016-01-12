(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.Collection = root.app.Collection || {};

  root.app.Collection.actorsCollection = Backbone.Collection.extend({

    initialize: function() {
      /* The first argument of a collection is a list of models */
      this.router = arguments.length > 1 && arguments[1].router;
    },

    url: function() {
      var baseUrl = root.app.Helper.globals.apiUrl + 'actors';
      var queryParams = _.omit(this.router.getQueryParams(), 'types');

      if(!_.isEmpty(queryParams)) {
        return _.reduce(_.map(queryParams, function(value, key) {
          if(key === 'levels' || key === 'domains_ids') {
            return _.map(value, function(v) { return key + '[]=' + v; })
              .join('&');
          }
          if(key === 'start_date' || key === 'end_date') {
            return key + '=' + value.split('/')[2] + '-' + value.split('/')[0] +
              '-' + value.split('/')[1];
          }
        }), function(memo, value) {
          return memo + value + '&';
        }, baseUrl + '?').slice(0, -1);
      }

      return baseUrl;
    },

    parse: function(data) { return data.actors; }

  });

})(this);
