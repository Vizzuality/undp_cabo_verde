(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.Collection = root.app.Collection || {};
  root.app.Helper = root.app.Helper || {};

  root.app.Collection.relationshipsCollection = Backbone.Collection.extend({

    url: root.app.Helper.globals.apiUrl + 'relations',

    parse: function(data) { return data.relations; }

  });

})(this);
