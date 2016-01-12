(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.Model = root.app.Model || {};

  root.app.Model.actorModel = Backbone.Model.extend({

    url: function() {
      return root.app.Helper.globals.apiUrl + 'actors/' + this.id;
    },

    setId: function(id) {
      this.id = id;
    },

    parse: function(data) { return data.actor; }

  });

})(this);
