(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.Collection = root.app.Collection || {};

  root.app.Collection.actorsCollection = Backbone.Collection.extend({

    url: root.app.Helper.globals.apiUrl + 'actors',

    parse: function(data) { return data.actors; }

  });

})(this);
