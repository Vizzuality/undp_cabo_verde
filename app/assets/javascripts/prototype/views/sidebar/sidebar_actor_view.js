(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};
  root.app.Model = root.app.Model || {};
  root.app.Mixin = root.app.Mixin || {};
  root.app.pubsub = root.app.pubsub || {};

  var Status = Backbone.Model.extend({
    defaults: { isHidden: true  }
  });

  root.app.View.sidebarActorView = Backbone.View.extend({
    el: '#sidebar-actor-view',

    events: {
      'click .js-relation': 'onRelationClick',
      'mouseenter .js-relation': 'onRelationHover',
      'mouseleave .js-relation': 'onRelationBlur'
    },

    template: HandlebarsTemplates['sidebar/sidebar_actor_template'],

    initialize: function(options) {
      this.router = options.router;
      this.status = new Status();
      this.model = new root.app.Model.actorModel(null, {
        router: this.router
      });

      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(root.app.pubsub, 'sync:actorModel', this.populateModelFrom);
      this.listenTo(this.model, 'sync', this.triggerModelSync);
    },

    onRelationClick: function(e) {
      var id   = +e.currentTarget.getAttribute('data-id'),
          type =  e.currentTarget.getAttribute('data-type');
      this.showEntity(type, id);
    },

    onRelationHover: function(e) {
      var id   = +e.currentTarget.getAttribute('data-id'),
          type =  e.currentTarget.getAttribute('data-type');

      /* We make sure that the model has the information about the opened marker
       * and not another one the user could have hovered */
      this.fetchData(+this.router.getCurrentRoute().params[0])
        .then(function() {
          root.app.pubsub.trigger('filter:relations', {
            only: { type: type, id: id }
          });
        });
    },

    onRelationBlur: function() {
      root.app.pubsub.trigger('filter:relations', {
        only: null
      });
    },

    /* Sets the model id to the one passed as argument and fetches it, if not
     * containing the right information already. Return a deferred object. */
    fetchData: function(id) {
      var deferred = $.Deferred();

      if(!_.isEmpty(this.model.attributes) && this.model.get('id') === id) {
        deferred.resolve();
      } else {
        this.model.setId(id);
        this.model.fetch()
          .done(deferred.resolve)
          .fail(function() {
            console.warn('Unable to fetch the model /actors/' + params[0]);
            deferred.reject();
          });
      }

      return deferred;
    },

    /* Method called right before the pane is toggled to a visible state */
    beforeShow: function(route, params) {
      var deferred = $.Deferred();

      this.fetchData(+params[0])
        .then(function() {
          this.render();
          deferred.resolve();
        }.bind(this))
        .fail(function() {
          deferred.reject();
        });

      return deferred;
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

    /* Trigger an event through the pubsub object to inform about the new state
     * of the actor model */
    triggerModelSync: function() {
      root.app.pubsub.trigger('sync:actorModel', this.model);
    },

    render: function() {
      var visibleRelations = this.model.getVisibleRelations();
      var relations = _.groupBy(visibleRelations, function(relation) {
        return relation.type;
      });

      /* If there's no relation, we set the variable to null so the Handlebars
       * template understands it */
      relations = _.isEmpty(relations) ? null : relations;

      this.$el.html(this.template(_.extend(_.extend(this.model.toJSON(),
        this.status.toJSON()), { relations: relations })));
    }

  });

  /* We extend the view with method to show, hide and toggle the pane */
  _.extend(root.app.View.sidebarActorView.prototype, root.app.Mixin.visibility);
  /* We extend the view the method showEntity */
  _.extend(root.app.View.sidebarActorView.prototype, root.app.Mixin.showEntity);

})(this);
