(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};
  root.app.Mixin = root.app.Mixin || {};
  root.app.pubsub = root.app.pubsub || {};

  var Status = Backbone.Model.extend({
    defaults: { isHidden: false }
  });

  root.app.View.sidebarView = Backbone.View.extend({

    el: document.querySelector('.l-sidebar'),

    initialize: function(options) {
      this.status = new Status();
      this.router = options.router;

      this.actionToolbarView = new root.app.View.sidebarActionToolbarView({
        router: this.router
      });
      this.tabNavigationView = new root.app.View.tabNavigationView({
        router: options.router
      });
      this.filtersView = new root.app.View.sidebarFiltersView({
        router: this.router
      });
      this.actorView = new root.app.View.sidebarActorView({
        router: this.router
      });
      this.actionView = new root.app.View.sidebarActionView({
        router: this.router
      });
      this.searchesView = new root.app.View.sidebarSearchesView({
        router: this.router
      });

      /* List of all the sidebar's panes */
      this.panes = [ this.filtersView, this.actorView, this.actionView,
        this.searchesView ];

      /* Cache */
      this.$toggleSwitch = this.$el.find('.toggleswitch');
      this.globalError = this.el.querySelector('.js-global-error');

      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(this.status, 'change:isHidden', this.triggerVisibility);
      this.listenTo(this.tabNavigationView, 'tab:change', this.switchContent);
      this.$toggleSwitch.on('click', this.toggle.bind(this));
      // this.listenTo(root.app.pubsub, 'show:actor', this.show);
      // this.listenTo(root.app.pubsub, 'show:action', this.show);
      this.listenTo(this.router, 'route', this.onRoute);
      this.listenTo(this.actionToolbarView, 'click:searches',
        this.onSearchesClick);
      this.listenTo(this.actionToolbarView, 'click:goBack', this.onClickGoBack);
      this.listenTo(this.searchesView, 'apply:searches', this.onApplySearches);
      this.listenTo(this.filtersView, 'save:filters', this.onSaveFilters);
      this.listenTo(this.searchesView, 'show:error', this.onErrorShow);
      this.listenTo(this.filtersView,  'show:error', this.onErrorShow);
      this.listenTo(this.searchesView, 'expire:session', this.onSessionExpire);
      this.listenTo(this.filtersView,  'expire:session', this.onSessionExpire);
    },

    onRoute: function(route, params) {
      var selectedPane     = null,
          showGoBackButton = false;

      switch(route) {
        case 'actors':
          selectedPane = this.actorView;
          showGoBackButton = true;
          break;

        case 'actions':
          selectedPane = this.actionView;
          showGoBackButton = true;
          break;

        default:
          selectedPane = this.filtersView;
          break;
      }

      /* We hide all the panes except the one selected */
      this.onlyShowPane(selectedPane, route, params)
        .done(function() {
          /* We toggle the "go back" button depending on the pane that is shown
           */
          this.actionToolbarView[ (showGoBackButton ? 'show' : 'hide') +
            'GoBackButton' ]();
        }.bind(this));
    },

    onSearchesClick: function() {
      this.onlyShowPane(this.searchesView)
        .done(this.actionToolbarView.showGoBackButton.bind(this.actionToolbarView));
    },

    onClickGoBack: function() {
      /* If we actually update the route, do it */
      if(this.router.getCurrentRoute().name !== 'welcome') {
        this.router.navigate('/', { trigger: true });
      }
      /* If we already have the default route, we force all the pane to reset,
       * except the default one */
      else {
        this.onlyShowPane(this.filtersView);
      }
    },

    onSaveFilters: function() {
      this.searchesView.fetchData();
    },

    /* Hide all the panes except the one passed as argument. If it's hidden,
     * make it visible. route and params are URL route and URL params.
     * Return a deferred object. */
    onlyShowPane: function(pane, route, params) {
      var deferred = $.Deferred();

      /* We hide all the panes except the one selected */
      _.invoke(_.without(this.panes, pane), 'hide');
      /* We show the pane after making sure it's ready */
      pane.beforeShow(route, params)
        .done(function() {
          pane.show();
          deferred.resolve();
        })
        .fail(deferred.reject);

      return deferred;
    },

    onApplySearches: function(options) {
      this.filtersView.onSetSearch(options);
    },

    onErrorShow: function(message) {
      this.displayError(message);
    },

    onSessionExpire: function() {
      this.actionToolbarView.logOut();
    },

    /* Switch the content of the sidebar by the one that have been asked by
     * tabNavigationView. Params contains the previous' and new tab's name
     * (see tabNavigationView) */
    switchContent: function(params) {
      var previousContent = this.el.querySelector('[data-content="' + params.previousTab + '"]'),
          newContent      = this.el.querySelector('[data-content="' + params.newTab + '"]');

      previousContent.classList.add('_hidden');
      previousContent.setAttribute('aria-hidden', 'true');
      newContent.classList.remove('_hidden');
      newContent.setAttribute('aria-hidden', 'false');
    },

    /* Toggle the sidebar by using a CSS transform translateX property and
     * update the model's attribute isHidden */
    toggle: function(e) {
      if(e) { e.preventDefault(); }
      var isHidden = this.el.classList.toggle('-hidden');
      this.el.setAttribute('aria-hidden', isHidden);
      this.$toggleSwitch[0].setAttribute('aria-expanded', !isHidden);
      this.status.set('isHidden', isHidden);
    },

    /* Trigger the sidebar's visibility with the object:
     * {
     *    isHidden: {boolean}
     * }
     */
    triggerVisibility: function() {
      root.app.pubsub.trigger('sidebar:visibility', {
        isHidden: this.status.get('isHidden')
      });
    },

    /* Display an error message in the sidebar containing the passed message */
    displayError: function(message) {
      this.globalError.textContent = message;
      this.globalError.classList.remove('_hidden');


      /* We hide it 2s later */
      if(this.errorTimeout) clearTimeout(this.errorTimeout);
      this.errorTimeout = setTimeout(function() {
        this.globalError.classList.add('_hidden');
      }.bind(this), 3000);
    }

  });

  /* We extend the view with method to show, hide and toggle the sidebar */
  _.extend(root.app.View.sidebarView.prototype, root.app.Mixin.visibility);

})(this);
