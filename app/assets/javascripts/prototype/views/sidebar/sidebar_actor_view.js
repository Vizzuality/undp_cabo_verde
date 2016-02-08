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

      this.init();
    },

    setListeners: function() {
      this.listenTo(root.app.pubsub, 'click:goBack', this.hide);
      this.listenTo(root.app.pubsub, 'show:action', this.hide);
      this.listenTo(root.app.pubsub, 'show:actor', this.fetchDataAndRender);
      this.listenTo(root.app.pubsub, 'relationships:visibility',
        this.toggleRelationshipsVisibility);
      this.listenTo(root.app.pubsub, 'sync:actorModel', this.populateModelFrom);
      this.listenTo(this.model, 'sync', this.triggerModelSync);
    },

    /* Initialize the pane state (ie visibility and content) */
    init: function() {
      var route = this.router.getCurrentRoute();
      if(route.name === 'actors') {
        this.fetchDataAndRender(route.params[0]);
      }
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

    /* Set the content of this.model with the content of the passed model
     * NOTE: as the view itself can trigger this method by the sync event of its
      * own model, we make the comprobation that the id of the passed model is
     * different from the one stored in the current model */
    populateModelFrom: function(model) {
      if(!_.isEmpty(this.model.attributes) &&
        this.model.get('id') === model.get('id')) {
        return;
      }

      this.model.clear({ silent: true });
      this.model.set(model.toJSON());
    },

    /* Check if this.model has data. If so, call the render function, otherwise,
     * fetch the data and then call render */
    fetchDataAndRender: function() {
      if(!_.isEmpty(this.model.attributes)) {
        this.render();
      } else {
        this.model.setId(arguments[0]);
        this.model.fetch()
          .done(this.render.bind(this));
      }
    },

    /* Trigger an event through the pubsub object to inform about the new state
     * of the actor model */
    triggerModelSync: function() {
      root.app.pubsub.trigger('sync:actorModel', this.model);
    },

    render: function() {
      var relations = {
        actors: _.union(this.model.get('actors').parents,
          this.model.get('actors').children),
        actions: _.union(this.model.get('actions').parents,
          this.model.get('actions').children)
      };

      this.$el.html(this.template(_.extend(_.extend(this.model.toJSON(),
        this.status.toJSON()), { relations: relations })));
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
