//= require jquery2
//= require jquery_ujs
//= require jquery-ui/datepicker
//= require chosen-jquery
//= require_tree .
//= require chosen-jquery

/* Dynamically filter the forms that are shown for the actors and actions pages
 */
var filterForms = function() {
  var forms = document.querySelectorAll('#form-actor, #form-action');
  var level = document.querySelector('#actor_type, #act_type, #actor_micro_type');

  /* If the page doesn't have the necessary filter, we exit the function */
  if(!level) { return; }

  /* When level has a new value, we update the list of visible forms */
  level.addEventListener('change', function(e) {
    var value = e.currentTarget.value.toLowerCase();
    value = value.replace('actor', '').replace('act', '');

    /* We first add the _hidden class to all the elements */
    for(var i = 0, j = forms.length; i < j; i++) {
      forms[i].classList.add('_hidden');
    }

    if(value.length > 0) {
      /* Then the forms which are targeted by the filter loose it */
      var filteredForms = [].filter.call(forms, function(form) {
        return form.classList.contains(value);
      });

      for(var i = 0, j = filteredForms.length; i < j; i++) {
        filteredForms[i].classList.remove('_hidden');
      }
    }
  });
};

var toggleDropdown = function(target) {
  target.classList.toggle('dropdown-active');
};

var disableDropdown = function(target) {
  target.classList.remove('dropdown-active');
};

var dropdown = function() {
  var account =  document.querySelector('#js-dropdown-acc');
  var settings = document.querySelector('#js-dropdown-set');

  if(account) {
    account.addEventListener('click', function() {
      toggleDropdown(account);
      // hide the other dropdown
      if(settings.classList.contains('dropdown-active')) {
        disableDropdown(settings);
      }
    });
  }

  if(settings) {
    settings.addEventListener('click', function() {
      toggleDropdown(settings);
      // hide the other dropdown
      if(settings.classList.contains('dropdown-active')) {
        disableDropdown(account);
      }
    });
  }
};


var showDatepicker = function() {
  var dateFields = document.querySelectorAll('.js-datepicker');
  var minDate, startDate;
  for(var i = 0, j = dateFields.length; i < j; i++) {
    minDate = new Date(dateFields[i].getAttribute('data-min-date').split('-'));
    maxDate = new Date(dateFields[i].getAttribute('data-max-date').split('-'));
    if(dateFields[i].value.length > 0) {
      /* We remove the time from the value */
      dateFields[i].value = dateFields[i].value.split(' ')[0];
    }
    $(dateFields[i]).datepicker({
      minDate: minDate,
      maxDate: maxDate,
      dateFormat: 'yy-mm-dd',
      yearRange: dateFields[i].getAttribute('data-min-date').split('-')[0] + ':' +
        dateFields[i].getAttribute('data-max-date').split('-')[0],
      changeMonth: true,
      changeYear: true
    });
  }
};


var showMultiselect = function() {
  var multiselects = $('.js-mselect');

  for(var i = 0; i < multiselects.length; i++) {
    multiselects[i].classList.add('chosen');
    multiselects[i].classList.add('chosen-select');
  }

  multiselects.chosen();
}

function onReady() {
  filterForms();
  dropdown();
  showMultiselect();
  showDatepicker();
};

document.addEventListener('DOMContentLoaded', onReady);
