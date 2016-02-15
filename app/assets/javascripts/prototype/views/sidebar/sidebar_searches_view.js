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
      'click .js-delete': 'onDelete'
    },

    template: HandlebarsTemplates['sidebar/sidebar_searches_template'],

    initialize: function(options) {
      this.status = new Status();
      this.collection = new root.app.Collection.searchCollection();
      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(root.app.pubsub, 'click:goBack', this.hide);
      this.listenTo(root.app.pubsub, 'show:searches', this.fetchDataAndRender);
    },

    onApply: function(e) {
      var searchId = e.currentTarget.getAttribute('data-id');
      this.applySearch(searchId);
    },

    onEdit: function(e) {
      var el = e.currentTarget;
      var searchId = el.getAttribute('data-id');

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
    },

    onDelete: function(e) {
      var searchId = e.currentTarget.getAttribute('data-id');
      this.deleteSearch(searchId);
    },

    fetchDataAndRender: function() {
      if(!this.collection.length) {
        this.collection.fetch()
          .done(this.render.bind(this))
          .error(function() {
            console.warn('Unable to retrieved the saved searches');
          });
      } else {
        this.render();
      }
    },

    render: function() {
      this.$el.html(this.template({
        searches: this.collection.toJSON()
      }));

      /* We finally slide the pane to display the information */
      this.show();

      /* We reset the event handlers to take into account the new DOM elements
       */
      this.setElement(this.$el);
    },

    /* Apply the search by updating the URL */
    applySearch: function(searchId) {
      var model = this.collection.where({ id: parseInt(searchId) });
      if(model.length) {
        model = model[0];
        var queryParams = model.get('queryParams');
        root.app.pubsub.trigger('apply:searches', { queryParams: queryParams });
        /* Now we need to close the pane, for that we could use this.hide(), but
         * the go back button would stay present in the action toolbar. We then
         * use an event to do so. */
        root.app.pubsub.trigger('click:goBack');
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
    }

  });

  /* We extend the view with method to show, hide and toggle the pane */
  _.extend(root.app.View.sidebarSearchesView.prototype, root.app.Mixin.visibility);

})(this);
