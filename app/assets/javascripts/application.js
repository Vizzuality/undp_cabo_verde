//= require jquery2
//= require jquery_ujs
//= require_tree .

/* Dynamically filter the forms that are shown for the actors and actions pages
 */
var filterForms = function() {
  var forms = document.querySelectorAll('#form-actor, #form-action');
  var level = document.querySelector('#actor_type, #act_type');

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


function onReady() {
  filterForms();
}

document.addEventListener('DOMContentLoaded', onReady);
