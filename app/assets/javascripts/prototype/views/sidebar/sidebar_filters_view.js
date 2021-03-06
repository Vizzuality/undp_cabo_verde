(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};
  root.app.Mixin = root.app.Mixin || {};
  root.app.Helper = root.app.Helper || {};
  root.app.pubsub = root.app.pubsub || {};

  var Status = Backbone.Model.extend({
    defaults: { isHidden: false }
  });

  root.app.View.sidebarFiltersView = Backbone.View.extend({

    el: '#sidebar-filters-view',

    events: {
      'click .js-reset': 'onResetFilters',
      'click .js-apply': 'onApplyFilters',
      'change .toggle-button': 'onExpandFilter',
      'change input[type=checkbox]:not(.toggle-button)': 'onCheckboxChange',
      'click .js-uncheck-all': 'onClickUncheckAll',
      'click .js-check-all': 'onClickCheckAll',
      'click .js-save-search': 'onClickSaveSearch',
      'mouseenter .js-3x5': 'on3x5Hover',
      'mouseleave .js-3x5': 'on3x5Blur',
      'mouseenter .js-3xX': 'on3xXHover',
      'mouseleave .js-3xX': 'on3xXBlur'
    },

    initialize: function(options) {
      this.router = options.router;
      this.status = new Status();
      this.$inputFields = this.$el.find('.js-input');
      this.$dateFields = this.$el.find('.js-date');
      this.applyButton = this.el.querySelector('.js-apply');
      this.errorMessage = this.el.querySelector('.js-error');
      this.inputs = this.el.querySelectorAll('.js-input');
      this.saveButton = this.el.querySelector('.js-save-search');
      this.hiddenInputs =
        this.el.querySelectorAll('.js-input[disabled="disabled"]');
      this.syncInputsWithQueryParams();
      this.syncCheckboxesWithHiddenInputs();
      this.initDateFields();
      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(this.status, 'change', this.applySearch);
    },

    /* GETTERS */

    /* From the element passed as argument, return the filter's root element
     * which contains it (or null if can't find it)
     * NOTE: expect a DOM element as parameter */
    getFilterRootElem: function(childElem) {
      return root.app.Helper.utils.getClosestParent(childElem, '.section');
    },

    /* Get the filter's name from it's DOM element/container */
    getFilterName: function(filterRootElem) {
      var selector = 'label';
      return filterRootElem.querySelector(selector).textContent;
    },

    /* Return the content container of the selected filter */
    getFilterContent: function(filterRootElem) {
      var selector = '.js-content';
      return filterRootElem.querySelector(selector);
    },

    /* Return the options for the filter whose root element is passed as
     * argument */
    getFilterCheckboxes: function(filterRootElem) {
      var selector = '.js-content input[type="checkbox"]';
      return filterRootElem.querySelectorAll(selector);
    },

    /* Return the checkbox matching the value passed as argument which belongs
     * to the filter "named" in the arguments */
    getFilterCheckboxByValue: function(filterRootElem, value) {
      var checkboxes = this.getFilterCheckboxes(filterRootElem);
      var checkbox = _.filter(checkboxes, function(checkbox) {
        return checkbox.value === value;
      });

      if(checkbox.length > 0) { return checkbox[0]; }
      return null;
    },

    /* Return the button to toggle all the options of the filter whose root
     * element is passed as argument */
    getFilterToggleCheckButton: function(filterRootElem) {
      var selector = '.js-toggle-check';
      return filterRootElem.querySelector(selector);
    },

    /* Return the hidden button which summarizes the filter whose root element
     * is passed as argument */
    getFilterHiddenInput: function(filterRootElem) {
      var selector = '.js-input';
      return filterRootElem.querySelector(selector);
    },

    /* Return all the hidden inputs */
    getAllHiddenInputs: function() {
      return this.hiddenInputs;
    },

    /* Return the notification badge of the filter whose root element is passed
     * as argument */
    getFilterNotificationBadge: function(filterRootElem) {
      var selector = '.js-badge';
      return filterRootElem.querySelector(selector);
    },

    /* Return all the inputs */
    getAllInputs: function() {
      return this.inputs;
    },

    /* Return the input which name is passed as argument */
    getInputByName: function(name) {
      var inputs = this.getAllInputs();
      var input = _.filter(inputs, function(input) {
        return input.name === name;
      });

      if(input.length > 0) { return input[0]; }
      return null;
    },

    /* UTILITIES FOR THE CHECKBOXES */

    /* Return all the checked checkboxes of the filter whose root element is
     * passed as argument */
    getFilterCheckedCheckboxes: function(filterRootElem) {
      var checkboxes = this.getFilterCheckboxes(filterRootElem);
      return _.filter(checkboxes, function(checkbox) {
        return checkbox.checked;
      });
    },

    /* Return all the unchecked checkboxes of the filter whose root element is
     * passed as argument */
    getFilterUncheckedCheckboxes: function(filterRootElem) {
      var checkboxes = this.getFilterCheckboxes(filterRootElem);
      var checkedCheckboxes = this.getFilterCheckedCheckboxes(filterRootElem);
      return _.difference(checkboxes, checkedCheckboxes);
    },

    /* Check all the checkboxes of the filter whose root element is passed as
     * argument */
    checkFilterAllCheckboxes: function(filterRootElem) {
      var checkboxes = this.getFilterCheckboxes(filterRootElem);
      _.each(checkboxes, function(checkbox) { checkbox.checked = true; });
    },

    /* Uncheck all the checkboxes of the filter whose root element is passed as
     * argument */
    uncheckFilterAllCheckboxes: function(filterRootElem) {
      var checkboxes = this.getFilterCheckboxes(filterRootElem);
      _.each(checkboxes, function(checkbox) { checkbox.checked = false; });
    },

    /* EVENT HANDLERS */

    onExpandFilter: function(e) {
      var filterRootElem = this.getFilterRootElem(e.currentTarget);
      this.expandFilter(filterRootElem);
    },

    onCheckboxChange: function(e) {
      var filterRootElem = this.getFilterRootElem(e.currentTarget);
      var toggleCheckButton = this.getFilterToggleCheckButton(filterRootElem);

      this.updateFilterNotificationBadge(filterRootElem);
      this.updateFilterToggleCheckButton(filterRootElem);
      this.syncFilterHiddenInputWithCheckboxes(filterRootElem);
      this.updateApplyButtonState();
      this.updateErrorMessageVisibility();
    },

    onClickUncheckAll: function(e) {
      e.preventDefault();
      var filterRootElem = this.getFilterRootElem(e.currentTarget);
      this.uncheckFilterAllCheckboxes(filterRootElem);
      this.syncFilterHiddenInputWithCheckboxes(filterRootElem);
      this.updateFilterToggleCheckButton(filterRootElem);
      this.updateFilterNotificationBadge(filterRootElem);
      this.updateApplyButtonState();
      this.updateErrorMessageVisibility();
    },

    onClickCheckAll: function(e) {
      e.preventDefault();
      var filterRootElem = this.getFilterRootElem(e.currentTarget);
      this.checkFilterAllCheckboxes(filterRootElem);
      this.syncFilterHiddenInputWithCheckboxes(filterRootElem);
      this.updateFilterToggleCheckButton(filterRootElem);
      this.updateFilterNotificationBadge(filterRootElem);
      this.updateApplyButtonState();
      this.updateErrorMessageVisibility();
    },

    onResetFilters: function(e) {
      e.preventDefault();
      this.resetFilters();
    },

    onApplyFilters: function(e) {
      e.preventDefault();

      if(!this.isApplyButtonDisabled()) {
        this.applyFilters();
      }
    },

    onClickSaveSearch: function() {
      this.applyFilters();
      var queryParams = location.search.replace('?', '');

      /* We create and save the model that contains the search information */
      var model = new root.app.Model.searchModel();
      model.set('uri', queryParams);
      model.save()
        .done(function() {
          /* We send an event to tell the searches view that it needs to fetch
           * the collection again */
          this.trigger('save:filters');
          /* We add an animation to tell the user that the search has been
           * successfully saved */
          this.saveButton.classList.add('success');
          setTimeout(function() {
            this.saveButton.classList.remove('success');
          }.bind(this), 3000);
        }.bind(this))
        .fail(function(err) {
          if(err.status === 422) {
            this.trigger('show:error', I18n.translate('front.session_expired'));
            this.trigger('expire:session');
          } else {
            console.warn('Unable to save the search');
          }
        }.bind(this));
    },

    on3x5Hover: function(e) {
      root.app.pubsub.trigger('filter:sidebarFilters', {
        category: 'socio_cultural_domains',
        categoryId: parseInt(e.currentTarget.getAttribute('data-id'))
      });
    },

    on3x5Blur: function() {
      root.app.pubsub.trigger('filter:sidebarFilters', { category: null });
    },

    on3xXHover: function(e) {
      root.app.pubsub.trigger('filter:sidebarFilters', {
        category: 'other_domains',
        categoryId: parseInt(e.currentTarget.getAttribute('data-id'))
      });
    },

    on3xXBlur: function() {
      this.on3x5Blur();
    },

    onSetSearch: function(options) {
      this.router.setRawQueryParams('?' + options.queryParams);
      this.syncInputsWithQueryParams();
      this.syncCheckboxesWithHiddenInputs();
    },

    /* LOGIC */

    /* Method called right before the pane is toggled to a visible state */
    beforeShow: function() {
      var deferred = $.Deferred();
      deferred.resolve();
      return deferred;
    },

    /* Expand or contract a filter depending of its current state */
    expandFilter: function(filterRootElem) {
      var content = this.getFilterContent(filterRootElem);
      var isContracted = content.getAttribute('aria-hidden') === 'true';

      content.setAttribute('aria-hidden', !isContracted);
    },

    /* Update the text of the button used to toggle the check of checkbox of the
     * "current" filter according to their state*/
    updateFilterToggleCheckButton: function(filterRootElem) {
      var toggleCheckButton = this.getFilterToggleCheckButton(filterRootElem);
      var checkedCheckBoxes = this.getFilterCheckedCheckboxes(filterRootElem);

      /* Not all the filters have this element */
      if(!toggleCheckButton) return;

      var toggleCheckButtonContent = toggleCheckButton.querySelector('span'),
          toggleCheckButtonIcon = toggleCheckButton.querySelector('svg use');

      if(checkedCheckBoxes.length > 0) {
        toggleCheckButtonContent.textContent =
          I18n.translate('front.uncheck_all');
        toggleCheckButtonIcon.setAttribute('xlink:href', '#uncheckIcon');
      } else {
        toggleCheckButtonContent.textContent =
          I18n.translate('front.check_all');
        toggleCheckButtonIcon.setAttribute('xlink:href', '#checkIcon');
      }
    },

    /* Update the text of all the toggle check buttons according to their
     * filter's checkboxes */
    updateAllToggleCheckButtons: function() {
      var hiddenInputs = this.getAllHiddenInputs();

      var filterRootElem;
      for(var i = 0, j = hiddenInputs.length; i < j; i++) {
        filterRootElem = this.getFilterRootElem(hiddenInputs[i]);
        this.updateFilterToggleCheckButton(filterRootElem);
      }
    },

    /* Update the text of the notification badget attached to the "current"
     * filter according to the number of checked checkboxes */
    updateFilterNotificationBadge: function(filterRootElem) {
      var notificationBadge = this.getFilterNotificationBadge(filterRootElem);

      /* Some filters don't have any badge */
      if(!notificationBadge) return;

      var uncheckedCheckboxes =
        this.getFilterUncheckedCheckboxes(filterRootElem);
      var uncheckedCheckboxesCount = uncheckedCheckboxes.length;

      if(uncheckedCheckboxesCount > 0) {
        var checkedCheckboxes = this.getFilterCheckedCheckboxes(filterRootElem);
        var checkedCheckboxesCount = checkedCheckboxes.length;

        notificationBadge.textContent = checkedCheckboxesCount;
      } else {
        notificationBadge.textContent = I18n.translate('front.all');
      }
    },

    /* Update all the notification badges according to their filter's checkboxes
     */
    updateAllNotificationBadges: function() {
      var hiddenInputs = this.getAllHiddenInputs();

      var filterRootElem;
      for(var i = 0, j = hiddenInputs.length; i < j; i++) {
        filterRootElem = this.getFilterRootElem(hiddenInputs[i]);
        this.updateFilterNotificationBadge(filterRootElem);
      }
    },

    /* Update the hidden input of the filter section to which it belongs by
     * taking the checkboxes as reference */
    syncFilterHiddenInputWithCheckboxes: function(filterRootElem) {
      var hiddenInput = this.getFilterHiddenInput(filterRootElem);
      var hiddenInputOptions = hiddenInput.querySelectorAll('option');

      var checkboxes = this.getFilterCheckboxes(filterRootElem);

      var checkbox;
      _.each(hiddenInputOptions, function(option) {
        checkbox = _.filter(checkboxes, function(checkbox) {
          return root.app.Helper.utils.matches(checkbox,
            '[value="' + option.value + '"]');
        })[0];
        option.selected = checkbox.checked;
      });
    },

    /* Get the query params stored in the URL and apply their values to the
     * inputs */
    syncInputsWithQueryParams: function() {
      var queryParams = this.router.getQueryParams();

      /* We apply some transformations to the queryParams in order to take into
       * account the specificity of the 3x5 and 3xX fields merged into one param
       * domains_ids in the URL */
      queryParams = _.clone(queryParams);
      if(queryParams.domains_ids) {
        queryParams['3x5_ids'] = queryParams.domains_ids;
        queryParams['3xX_ids'] = queryParams.domains_ids;
        delete queryParams.domains_ids;
      }

      var input;
      _.each(queryParams, function(value, key) {
        input = this.getInputByName(key);
        if(!input) {
          console.warn('Unable to sync the query param "' + key +
            '" with its associated input');
        } else {
          /* In case we need to update a multi-option select input */
          if(root.app.Helper.utils.matches(input, 'select')) {
            /* We deselect all the options */
            _.each(input.options,
              function(option) { option.selected = false; });

            var option;
            if(!_.isArray(value)) { value = [ value ]; }

            /* Then, for each value of the array "value", we select the option
             * whose value matches it */
            for(var i = 0, j = value.length; i < j; i++) {
              option = input.querySelector('option[value="' +
                value[i] + '"]');
              if(option) {
                option.selected = true;
              } else if(value[i] !== '[]' && key !== '3x5_ids' &&
                key !== '3xX_ids') {
                console.warn('Unable to find the option "' + value[i] +
                  '" in the input "' + key + '"');
              }
            }
          }

          /* In case the field is a standard input, we update its value */
          else { input.value = value; }
        }
      }, this);
    },

    /* Apply the state of each hidden input to the associated checkboxes (the
     * reverse action is done by default) */
    syncCheckboxesWithHiddenInputs: function() {
      var hiddenInputs = this.getAllHiddenInputs();

      for(var i = 0, j = hiddenInputs.length; i < j; i++) {
        var filterRootElem = this.getFilterRootElem(hiddenInputs[i]);
        var options = hiddenInputs[i].options;

        var checkbox;
        for(var k = 0, l = options.length; k < l; k++) {
          checkbox = this.getFilterCheckboxByValue(filterRootElem,
              options[k].value);

          if(checkbox) {
            checkbox.checked = options[k].selected;
          } else {
            console.warn('Unable to restore the state of one option of the ' +
              'filter ' + this.getFilterName(filterRootElem));
          }
        }

        this.updateFilterNotificationBadge(filterRootElem);
        this.updateFilterToggleCheckButton(filterRootElem);
        this.updateApplyButtonState();
        this.updateErrorMessageVisibility();
      }
    },


    /* Reset the form to its original state and sets the default query
     * parameters in the URL */
    resetFilters: function() {
      var inputs = this.getAllInputs();

      var field;
      for(var i = 0, j = inputs.length; i < j; i++) {
        field = inputs[i];

        /* If the field is a select element, we select all the options */
        if(root.app.Helper.utils.matches(field, 'select')) {
          var options = field.options;
          for(var k = 0, l = options.length; k < l; k++) {
            options[k].selected = true;
          }
        } else {
          field.value = '';
        }
      }

      this.syncCheckboxesWithHiddenInputs();
      this.updateAllToggleCheckButtons();
      this.updateAllNotificationBadges();
      this.updateApplyButtonState();
      this.updateErrorMessageVisibility();

      this.applyFilters();
    },

    /* Save the form state into the status model
     */
    applyFilters: function() {
      var inputs = this.getAllInputs();

      var field, value, summary = {}, domains_ids = [];
      for(var i = 0, j = inputs.length; i < j; i++) {
        field = inputs[i];

        /* If the field is a select element, we retrieve the value of the
         * selected option */
        if(root.app.Helper.utils.matches(field, 'select')) {
          var selectedOptions = field.selectedOptions;

          if(field.name === '3x5_ids' || field.name === '3xX_ids') {
            for(var k = 0, l = selectedOptions.length; k < l; k++) {
               domains_ids.push(field.options[selectedOptions[k].index].value);
            }
          } else {
            summary[field.name] = [];
            for(var k = 0, l = selectedOptions.length; k < l; k++) {
               summary[field.name].push(field.options[selectedOptions[k].index].value);
            }
          }
        } else {
          summary[field.name] = field.value;
        }
      }

      if(domains_ids.length > 0) summary.domains_ids = domains_ids;

      this.router.setQueryParams(summary);
    },

    /* Return a boolean to tell if the apply button is disabled or not */
    isApplyButtonDisabled: function() {
      var hiddenInputs = this.getAllHiddenInputs();

      /* For the 3x5 and 3xX fields, the validation rule is that at least one
       * of the set of checkboxes is checked (one of 3x5 or one of 3xX) */
      var domainsCheckboxesCount = 0;

      var filterRootElem, checkedCheckboxesCount;
      for(var i = 0, j = hiddenInputs.length; i < j; i++) {
        filterRootElem = this.getFilterRootElem(hiddenInputs[i]);
        checkedCheckboxesCount =
          this.getFilterCheckedCheckboxes(filterRootElem).length;

        if(hiddenInputs[i].name === '3x5_ids' ||
          hiddenInputs[i].name === '3xX_ids') {
          domainsCheckboxesCount += checkedCheckboxesCount;
        } else {
          if(checkedCheckboxesCount === 0) return true;
        }
      }

      return domainsCheckboxesCount === 0;
    },

    /* Disable or enable the apply button depending if there's a filter with all
     * it's checkboxes unchecked */
    updateApplyButtonState: function() {
      this.applyButton.classList.toggle('-disabled',
        this.isApplyButtonDisabled());
    },

    /* Return a true if the error message should be visible */
    isErrorMessageVisible: function() {
      return this.isApplyButtonDisabled();
    },

    /* Show or hide the error message depending on the form's state */
    updateErrorMessageVisibility: function() {
      this.errorMessage.classList.toggle('_hidden',
        !this.isErrorMessageVisible());
      this.errorMessage.setAttribute('aria-hidden',
        !this.isErrorMessageVisible());
    },

    /* Initialize the date fields with datepickers */
    initDateFields: function() {
      var fromField = $(this.$dateFields[0]),
          toField   = $(this.$dateFields[1]);

      /* We modify the inner of jQuery UI in order to bring a custom positioning
       * to the datepicker */
      $.extend($.datepicker, {
        _checkOffset: function(instance) {
          var position = instance.input.position();
          var datepickerWidth = instance.dpDiv.outerWidth();
          var containerWidth = this.$el.width();
          var containerPadding = 25;

          position.top = this.$dateFields.offset().top - this.$el.find('.content').offset().top + 25;
          if(instance.input[0] === fromField[0]) {
            position.left = containerPadding;
          } else {
            position.left = containerWidth - containerPadding - datepickerWidth;
          }

          return position;
        }.bind(this)
      });

      this.$dateFields.datepicker({
        changeMonth: true,
        changeYear: true,
        showOptions: { direction: 'down' },
        /* We automatically update the min/maxDate of the two inputs */
        onClose: function(selectedDate) {
          if(this === fromField[0]) {
            toField.datepicker('option', 'minDate', selectedDate);
          } else {
            fromField.datepicker('option', 'maxDate', selectedDate);
          }
        },
        /* We move the datepicker to the sidebar so we can have an absolute
         * positioning inside of it */
        beforeShow: function() {
          this.$el.append(arguments[1].dpDiv);
        }.bind(this)
      });
    },

    /* Disable the "save this search" button and tell the user to log in */
    disableSaveSearchButton: function() {
      var htmlContent = '<p>' +
        I18n.translate('front.connect_to_save_search_html') + '</p>' +
        '<button class="button -secondary">' +
        I18n.translate('front.save_search') + '</button>';

      this.saveButton.parentNode.innerHTML = htmlContent;
    }

  });

  /* We extend the view with method to show, hide and toggle the pane */
  _.extend(root.app.View.sidebarFiltersView.prototype,
    root.app.Mixin.visibility);

})(this);
