(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};
  root.app.Mixin = root.app.Mixin || {};
  root.app.Helper = root.app.Helper || {};

  var Status = Backbone.Model.extend({
    defaults: { isHidden: false }
  });

  root.app.View.sidebarFiltersView = Backbone.View.extend({

    el: '#sidebar-filters-view',

    events: {
      'click .js-reset': 'resetForm',
      'click .js-apply': 'applyFilters',
      'change .toggle-button': 'toggleContent',
      'change input[type=checkbox]:not(.toggle-button)': 'updateHiddenInput'
    },

    initialize: function(options) {
      this.router = options.router;
      this.status = new Status();
      this.$inputFields = this.$el.find('.js-input');
      this.syncHiddenInputsWithQueryParams();
      this.syncCheckboxesWithHiddenInputs();
      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(this.router, 'route', this.toggleVisibilityFromRoute);
      this.listenTo(this.status, 'change', this.applySearch);
    },

    /* According to the route broadcast by the router show or hide the pane */
    toggleVisibilityFromRoute: function(route) {
      if(route !== 'welcome') {
        this.hide();
      } else {
        this.show();
      }
    },

    /* Reset the form to its original state and sets the default query
     * parameters in the URL */
    resetForm: function(e) {
      e.preventDefault();

      var field;
      for(var i = 0, j = this.$inputFields.length; i < j; i++) {
        field = this.$inputFields[i];
        /* If the field is a select element, we select all the options */
        if(root.app.Helper.utils.matches(field, 'select')) {
          var options = field.options;
          for(var k = 0, l = options.length; k < l; k++) {
            options[k].selected = true;
          }
        } else if(root.app.Helper.utils.matches(field, 'input[type="date"]')) {
          var date = new Date();
          field.value = [ ('0' + (date.getMonth() + 1)).slice(-2),
            ('0' + date.getDate()).slice(-2), date.getFullYear() ].join('/');
        } else {
          field.value = '';
        }
      }
      this.syncCheckboxesWithHiddenInputs();
      this.applyFilters();
    },

    /* Save the form state into the status model */
    applyFilters: function(e) {
      if(e) { e.preventDefault(); }

      console.warn('The feature is only partially implemented');

      var field, value, summary = {};
      for(var i = 0, j = this.$inputFields.length; i < j; i++) {
        field = this.$inputFields[i];
        /* If the field is a select element, we retrieve the value of the
         * selected option */
        if(root.app.Helper.utils.matches(field, 'select')) {
          var selectedOptions = field.selectedOptions;
          /* If there's no option selected, we use a special value */
          if(selectedOptions.length === 0) {
            summary[field.name] = '[]';
          }
          /* Otherwise we join each value with a comma */
          else {
            summary[field.name] = [];
            for(var k = 0, l = selectedOptions.length; k < l; k++) {
               summary[field.name].push(field.options[selectedOptions[k].index].value);
            }
          }
        } else {
          summary[field.name] = field.value;
        }
      }
      this.router.setQueryParams(summary);
    },

    /* Toggle the aria-hidden attribute's value according to the visibility of
     * the section */
    toggleContent: function(e) {
      $(e.currentTarget).parent().find('.js-content').attr('aria-hidden',
        !e.currentTarget.checked);
    },

    /* Inside each section, the checkboxes are linked to a hidden select input
     * which summarizes their values. This method updates the hidden input When
     * a checkbox's value changed. */
    updateHiddenInput: function(e) {
      var hiddenInput = e.currentTarget.parentNode.parentNode
        .querySelector('.js-input');
      hiddenInput.querySelector('option[value="' +
        e.currentTarget.value + '"]').selected = e.currentTarget.checked;
    },

    /* Apply the state of each hidden input to the associated checkboxes (the
     * reverse action is done by default) */
    syncCheckboxesWithHiddenInputs: function() {
      var hiddenInputs = this.$el.find('.js-input[disabled="disabled"]');
      for(var i = 0, j = hiddenInputs.length; i < j; i++) {
        var options = hiddenInputs[i].options;
        var checkbox, selector;
        for(var k = 0, l = options.length; k < l; k++) {
          selector = 'input[type="checkbox"][value="' + options[k].value + '"]';
          checkbox = hiddenInputs[i].parentNode.querySelector(selector);
          checkbox.checked = options[k].selected;
        }
      }
    },

    /* Get the query params stored in the URL and apply their values to the
     * hidden inputs */
    syncHiddenInputsWithQueryParams: function() {
      var queryParams = this.router.getQueryParams();
      var hiddenInput;
      _.each(queryParams, function(value, key) {
        hiddenInput = this.$inputFields.filter('[name="' + key + '"]');
        if(hiddenInput.length === 0) {
          console.warn('Unable to sync the query param "' + key +
            '" with its associated hidden input');
        } else {
          /* In case we need to update a multi-option select input */
          if(root.app.Helper.utils.matches(hiddenInput[0], 'select')) {
            /* We deselect all the options */
            _.each(hiddenInput[0].options,
                function(option) { option.selected = false; });

            var option;
            if(!_.isArray(value)) { value = [ value ]; }

            /* Then, for each value of the array "value", we select the option
             * whose value matches it */
            for(var i = 0, j = value.length; i < j; i++) {
              option = hiddenInput[0].querySelector('option[value="' +
                value[i] + '"]');
              if(option) {
                option.selected = true;
              } else if(value[i] !== '[]') {
                console.warn('Unable to find the option "' + value[i] +
                  '" in the hidden input "' + key + '"');
              }
            }
          }

          /* In case the field is a standard input, we update its value */
          else { hiddenInput[0].value = value; }
        }
      }, this);
    }

  });

  /* We extend the view with method to show, hide and toggle the pane */
  _.extend(root.app.View.sidebarFiltersView.prototype,
    root.app.Mixin.visibility);

})(this);
