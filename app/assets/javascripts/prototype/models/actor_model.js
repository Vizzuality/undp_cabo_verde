(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.Model = root.app.Model || {};
  root.app.pubsub = root.app.pubsub || {}; /* Used by the mixin */

  root.app.Model.actorModel = Backbone.Model.extend({

    /* *************************
     *        WARNING
     * *************************
     *
     * the initialize and setListeners methods are already defined in the mixin
     */

    url: function() {
      return root.app.Helper.globals.apiUrl + 'actors/' + this.id;
    },

    setId: function(id) {
      this.id = id;
    },

    parse: function(data) { return data.actor; },

  });

  /* We extend the model with a mixin that adds methods to get the visible
   * relations */
  _.extend(root.app.Model.actorModel.prototype, root.app.Mixin.modelsRelations);

})(this);
