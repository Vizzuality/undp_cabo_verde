(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};
  root.app.Model = root.app.Model || {};
  root.app.Collection = root.app.Collection || {};
  root.app.Mixin = root.app.Mixin || {};
  root.app.Helper = root.app.Helper || {};
  root.app.pubsub = root.app.pubsub || {};

  var Status = Backbone.Model.extend({
    defaults: { isHidden: true}
  });

  root.app.View.sidebarSearchesView = Backbone.View.extend({
    el: '#sidebar-searches-view',

    events: {
      'click .js-apply': 'onApply',
      'blur .js-edit': 'onEdit',
      'keypress .js-edit': 'onEditing',
      'click .js-delete': 'onDelete'
    },

    template: HandlebarsTemplates['sidebar/sidebar_searches_template'],

    initialize: function(options) {
      this.status = new Status();
      this.collection = new root.app.Collection.searchCollection();
    },

    onApply: function(e) {
      var searchId = e.currentTarget.getAttribute('data-id');
      this.applySearch(searchId);
    },

    onEditing: function(e) {
      if(e.keyCode === 13) {
        e.preventDefault();
        e.currentTarget.blur(); /* Will save the change */
      }
    },

    onEdit: function(e) {
      var el = e.currentTarget;
      var searchId = el.getAttribute('data-id');
      this.updateSearch(searchId, el);
    },

    onDelete: function(e) {
      var searchId = e.currentTarget.getAttribute('data-id');
      this.deleteSearch(searchId);
    },

    /* Method called right before the pane is toggled to a visible state */
    beforeShow: function(route, params) {
      var deferred = $.Deferred();

      if(!_.isEmpty(this.collection.models)) {
        this.render();
        this.setElement(this.$el);
        deferred.resolve();
      } else {
        this.fetchData()
          .done(function() {
            this.render();
            /* We reset the event handlers to take into account the new DOM
             * elements */
            this.setElement(this.$el);
            deferred.resolve();
          }.bind(this))
          .fail(deferred.reject);
      }

      return deferred;
    },

    /* Retrieve the list of searches, return a deferred object */
    fetchData: function() {
      var deferred = $.Deferred();

      this.collection.fetch()
        .done(deferred.resolve)
        .error(function(err) {
          if(err.status === 422) {
            this.trigger('show:error', I18n.translate('front.session_expired'));
            this.trigger('expire:session');
          } else {
            console.warn('Unable to retrieved the saved searches');
          }
          deferred.reject();
        }.bind(this));

      return deferred;
    },

    render: function() {
      this.$el.html(this.template({
        searches: this.collection.toJSON()
      }));
    },

    /* Apply the search by updating the URL */
    applySearch: function(searchId) {
      var model = this.collection.where({ id: parseInt(searchId) });
      if(model.length) {
        model = model[0];
        var queryParams = model.get('uri');
        this.trigger('apply:searches', { queryParams: queryParams });
      } else {
        console.warn('Unable to apply the search ' + searchId + 'because it ' +
          'couldn\'t be found in the collection');
      }
    },

    /* Delete a saved search and renders the view again */
    deleteSearch: function(searchId) {
      var model = this.collection.where({ id: parseInt(searchId) });
      if(model.length) {
        model = model[0];
        var queryParams = model.get('queryParams');
        model.destroy({
          url: root.app.Helper.globals.apiUrl + 'favourites/' +
            model.get('id') + '?token=' + gon.userToken
        });
        this.render();
      } else {
        console.warn('Unable to delete the search ' + searchId + 'because it ' +
          'couldn\'t be found in the collection');
      }
    },

    /* Update the name of search whose id and DOM element are passed as
     * arguments */
    updateSearch: function(searchId, el) {
      /* We retrieve the model to update it */
      var model = this.collection.where({ id: parseInt(searchId) });
      if(model.length) {
        model = model[0];
        model.set('name', el.textContent.trim());
        model.save(null, {
            url: root.app.Helper.globals.apiUrl + 'favourites/' +
              model.get('id') + '?token=' + gon.userToken
          })
          .fail(function() {
            console.warn('Unable to change the name of the search ' + searchId);
          });
      } else {
        console.warn('Unable to edit the search\'s name ' + searchId +
          'because the model associated to it couldn\'t be found in the ' +
          'collection');
      }
    }

  });

  /* We extend the view with method to show, hide and toggle the pane */
  _.extend(root.app.View.sidebarSearchesView.prototype, root.app.Mixin.visibility);

})(this);
