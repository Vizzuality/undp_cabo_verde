(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.Mixin = root.app.Mixin || {};

  root.app.Mixin.showEntity = {

    /* Show the actor/action corresponding with the parameters */
    showEntity: function(type, id) {
      var model;
      if(type === 'actors') {
        model = new root.app.Model.actorModel(null, { router: this.router });
      } else {
        model = new root.app.Model.actionModel(null, { router: this.router });
      }

      /* We need to fetch the information to know the entity's main location */
      model.setId(id);
      model.fetch()
        .done(function() {
          /* We broadcast the model of the actor/action to not have to fetch it
           * again once we show its information whether in this view or another
           * one */
          root.app.pubsub.trigger('sync:' +
            (type === 'actors' ? 'actor' : 'action') + 'Model', model);

          /* We determine the main location */
          var locations = model.get('locations');
          if(!locations.length) {
            console.warn('Unable to retrieve the location of /' + type +
              '/' + id);
          } else {
            var mainLocation = _.findWhere(locations, { main: true });
            if(!mainLocation) { mainLocation = locations[0]; }

            /* We update the URL */
            this.router.navigate([ '/' + type, id, mainLocation.id ].join('/'),
              { trigger: true });
          }
        }.bind(this))
        .fail(function() {
          console.warn('Unable to retrieve the information about /' + type +
            '/' + id);
        });
    }

  };

})(this);
