(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.Model = root.app.Model || {};

  root.app.Model.actionModel = Backbone.Model.extend({

    url: function() {
      return root.app.Helper.globals.apiUrl + 'actions/' + this.id;
    },

    setId: function(id) {
      this.id = id;
    },

    parse: function(data) { return data.action; }

  });

})(this);
