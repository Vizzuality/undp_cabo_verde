(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.Mixin = root.app.Mixin || {};

  root.app.Mixin.modelsRelations = {

    initialize: function(options) {
      this.router = arguments.length > 1 && arguments[1].router;
      /* We keep the date the user selected within the timeline view */
      this.selectedDate = null;

      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(root.app.pubsub, 'change:timeline', this.onTimelineChange);
    },

    onTimelineChange: function(options) {
      this.selectedDate = options.date;
    },

    /* Return the relations */
    extractRelations: function() {
      var collections = [
        {
          relations: this.get('actors').parents,
          type:       'actors',
          hierarchy:  'parents'
        },
        {
          relations: this.get('actors').children,
          type:       'actors',
          hierarchy:  'children'
        },
        {
          relations: this.get('actions').parents,
          type:       'actions',
          hierarchy:  'parents'
        },
        {
          relations: this.get('actions').children,
          type:       'actions',
          hierarchy:  'children'
        }
      ];

      return _.compact(_.flatten(_.map(collections, function(collection) {
        return _.each(_.clone(collection.relations), function(relation) {
          relation.type = collection.type;
          relation.hierarchy = collection.hierarchy;
        });
      })));
    },

    /* Return the model's relations whose dates are compatible with the query
     * params and the timeline's picked date */
    getVisibleRelations: function() {
      var relations = this.extractRelations();

      var queryParams = this.router.getQueryParams();

      return _.filter(relations, function(relation) {
        /* If the user selected a concrete date, we filter the relations
         * depending on it */
        if(this.selectedDate) {

          /* In case the relation is done with an action, we need to perform a
           * additional verification as it can own start and end dates */
          if(relation.type === 'actions') {
            /* The helper needs at least or the start date or the end date */
            if(relation.start_date || relation.end_date) {
              if(!root.app.Helper.utils.isDateBetween(this.selectedDate,
                relation.start_date, relation.endDate)) {
                return false;
              }
            }
          }

          /* We check that the relation's start and end dates encapsulate the
           * selected dates */
          if(relation.info &&
            (relation.info.start_date || relation.info.end_date)) {
            if(!root.app.Helper.utils.isDateBetween(this.selectedDate,
              relation.info.start_date, relation.info.end_date)) {
              return false;
            }
          }

        }
        /* Otherwise, we check the date range the user searched for */
        else if(queryParams.start_date || queryParams.end_date) {

          /* In case the relation is done with an action, we need to perform a
           * additional verification as it can own start and end dates */
          if(relation.type === 'actions') {
            if(relation.start_date || relation.end_date) {
              if(queryParams.start_date &&
                !root.app.Helper.utils.isDateBetween(queryParams.start_date,
                relation.start_date, relation.endDate) ||
                queryParams.end_date &&
                !root.app.Helper.utils.isDateBetween(queryParams.end_date,
                relation.start_date, relation.endDate)) {
                return false;
              }
            }
          }

          /* We check that the relation's start and end dates encapsulate within
           * the date range stored in the query params */
          if(relation.info &&
            (relation.info.start_date || relation.info.end_date)) {
            if(queryParams.start_date &&
              !root.app.Helper.utils.isDateBetween(queryParams.start_date,
              relation.info.start_date, relation.info.end_date) ||
              queryParams.end_date &&
              !root.app.Helper.utils.isDateBetween(queryParams.end_date,
              relation.info.start_date, relation.info.end_date)) {
              return false;
            }
          }

        }

        /* If we reach this point, it's because the relation hasn't been
         * dismissed, we can then return it*/
        return true;
      }, this);
    }

  };

})(this);
