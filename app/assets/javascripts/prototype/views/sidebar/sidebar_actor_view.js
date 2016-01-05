(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};
  root.app.Model = root.app.Model || {};
  root.app.Mixin = root.app.Mixin || {};
  root.app.pubsub = root.app.pubsub || {};

  var Status = Backbone.Model.extend({
    defaults: { isHidden: true, toggleRelationshipsActive: true }
  });

  root.app.View.sidebarActorView = Backbone.View.extend({
    el: '#sidebar-actor-view',

    events: {
      'click .js-back': 'goBack',
      'change .js-relationships-checkbox': 'triggerRelationshipsVisibility'
    },

    template: HandlebarsTemplates['sidebar/sidebar_actor_template'],

    initialize: function(options) {
      this.router = options.router;
      this.status = new Status();
      this.model = new root.app.Model.actorModel();
      /* The DOM element to receive the Handlbars template */
      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(this.router, 'route', this.toggleVisibilityFromRoute);
      this.listenTo(this.router, 'route:actor', this.loadActor);
      this.listenTo(this.model, 'sync change', this.render);
      this.listenTo(root.app.pubsub, 'relationships:visibility',
        this.toggleRelationshipsVisibility);
    },

    /* According to the route broadcast by the router show or hide the pane */
    toggleVisibilityFromRoute: function(route) {
      if(route === 'actor') {
        /* We don't do anything because we want the view to render before the
         * content to by slided. The call to this.show() is made in the render
         * method. */
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
    triggerRelationshipsVisibility: function(e) {
      root.app.pubsub.trigger('relationships:visibility',
        { visible: e.currentTarget.checked });
    },

    /* Toggle the relationships switch button
     * options can be null/undefined or { visible: [boolean] } */
    toggleRelationshipsVisibility: function(options) {
      var isVisible = options.visible;
      this.status.set('toggleRelationshipsActive', isVisible);
      /* This method could be called even if the view hasn't been rendered yet
       */
      if(this.$relationshipsToggle) {
        this.$relationshipsToggle.prop('checked', isVisible);
      }
    },

    render: function() {
      this.$el.html(this.template(_.extend(this.model.toJSON(),
        this.status.toJSON())));
      /* We need to set again the listeners because some of them depends on the
       * elements that have just been rendered */
      this.$relationshipsToggle = this.$el.find('.js-relationships-checkbox');
      /* We finally slide the pane to display the information */
      this.show();
    }
  });

  /* We extend the view with method to show, hide and toggle the pane */
  _.extend(root.app.View.sidebarActorView.prototype, root.app.Mixin.visibility);

})(this);
