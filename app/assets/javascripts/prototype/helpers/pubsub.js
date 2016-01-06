(function(root) {

  'use strict';

  root.app = root.app || {};

  root.app.pubsub = {};
  _.extend(root.app.pubsub, Backbone.Events);

})(this);
