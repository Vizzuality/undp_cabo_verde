(function(root) {

  'use strict';

  root.app = root.app || {};

  root.app.Router = Backbone.Router.extend({

    routes: {
      '(/)': 'welcome',
      'about(/)': 'about'
    }

  });

})(this);
