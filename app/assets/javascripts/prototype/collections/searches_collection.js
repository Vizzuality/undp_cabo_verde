(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.Collection = root.app.Collection || {};

  root.app.Collection.searchCollection = Backbone.Collection.extend({

    /* TODO: add the endpoint and return the right object */

    url: function() {
      return root.app.Helper.globals.apiUrl + 'favourites?token=' +
        gon.userToken;
    },

    parse: function(data) { return data.favourites; }

  });

})(this);
