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
      'click .js-back': 'goBack',
      'change .js-relationships-checkbox': 'toggleRelationships'
    },

    template: HandlebarsTemplates['sidebar/sidebar_actor_template'],

    initialize: function(options) {
      this.router = options.router;
      this.status = new Status();
      this.model = new root.app.Model.actorModel();
      /* The DOM element to receive the Handlbars template */
      this.$content = this.$el.find('.js-content');
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

    /* Fetch the data for the actor designated by its id */
    loadActor: function(id) {
      this.model.setId(id);
      this.model.fetch();
    },

    /* Trigger the visibility of the relationships (ie links) on the map */
    toggleRelationships: function(e) {
      this.trigger('relationships:visibility',
        { visible: e.currentTarget.checked });
    },

    render: function() {
      this.$content.html(this.template(this.model.toJSON()));
    }
  });

  /* We extend the view with method to show, hide and toggle the pane */
  _.extend(root.app.View.sidebarActorView.prototype, root.app.Mixin.visibility);

})(this);
