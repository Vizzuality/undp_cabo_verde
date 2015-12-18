(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};
  root.app.Model = root.app.Model || {};
  root.app.Mixin = root.app.Mixin || {};

  var Status = Backbone.Model.extend({
    defaults: { isHidden: true }
  });

  root.app.View.sidebarActorView = Backbone.View.extend({
    el: '#sidebar-actor-view',

    events: {
      'click .js-back': 'goBack'
    },

    initialize: function(options) {
      this.router = options.router;
      this.status = new Status();
      this.model = new root.app.Model.actorModel();
      this.$title = this.$el.find('.js-title');
      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(this.router, 'route', this.toggleVisibilityFromRoute);
      this.listenTo(this.router, 'route:actor', this.loadActor);
      this.listenTo(this.model, 'sync change', this.render);
    },

    /* According to the route broadcast by the router show or hide the pane */
    toggleVisibilityFromRoute: function(route) {
      if(route === 'actor') {
        this.show();
      } else {
        this.hide();
      }
    },

    /* Reset the URL to its original state */
    goBack: function() {
      this.hide();
      this.router.navigate('/', { trigger: true });
    },

    /* Fetch the data for the actor designated by its id */
    loadActor: function(id) {
      this.model.setId(id);
      this.model.fetch();
    },

    render: function() {
      this.$title.text(this.model.get('name'));
    }
  });

  /* We extend the view with method to show, hide and toggle the pane */
  _.extend(root.app.View.sidebarActorView.prototype, root.app.Mixin.visibility);

})(this);
