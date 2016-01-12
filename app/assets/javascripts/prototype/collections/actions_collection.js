(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.Collection = root.app.Collection || {};

  root.app.Collection.actionsCollection = Backbone.Collection.extend({

    url: root.app.Helper.globals.apiUrl + 'actions',

    parse: function(data) { return data.actions; }

  });

})(this);
