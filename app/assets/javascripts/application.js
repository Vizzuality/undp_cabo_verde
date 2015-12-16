//= require jquery2
//= require jquery_ujs
//= require jquery.ui.datepicker
//= require chosen-jquery
//= require_tree .

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
};

/* Display a mini map into the container and return it */
var createPreviewMap = function(container) {
  /* We show the map */
  var layer = L.tileLayer('http://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, &copy; <a href="http://cartodb.com/attributions">CartoDB</a>'
  });

  var map = L.map(container, {
    center: [16.77, -23.70],
    zoom: 1
  });

  map.addLayer(layer);
  return map;
};

/* Add a marker to a map at the given coordinates and return it */
var dropMarkerOn = function(map, lat, lng) {
  var marker = L.marker(L.latLng(lat, lng));
  marker.addTo(map);
  return marker;
};

/* Remove a given marker from the map passed as argument */
var removeMarkerFrom = function(map, marker) {
  map.removeLayer(marker);
};

/* Return the address associated to coordinates with the Nominatim service. It
 * uses the promise architecture to execute code when the information is
 * available. */
var retrieveAddressFrom = function(lat, lng) {
  var deferred = $.Deferred();

  var ajax = $.ajax({
    url: 'http://nominatim.openstreetmap.org/reverse',
    data: {
      format: 'json',
      lat: lat,
      lon: lng
    }
  });

  ajax.done(function(data) {
    var res = data.address || {};
    res.lat = lat;
    res.lng = lng;
    deferred.resolve(res);
  }).fail(function() {
      console.warn('Unable to retrieve the address from the Nominatim service');
    });

  return deferred.promise();
};

/* Initialize a mini map into the container and connects the inputs to the map
 * so when the user clicks on it, the fields are autocompleted and when the
 * fields are modified, the map displays a marker */
var initPreviewMap = function(container) {
  var map = createPreviewMap(container.querySelector('.map-preview'));

  /* Cache for the form fields related to a location */
  var latField     = container.querySelector('.localization_lat');
  var lngField     = container.querySelector('.localization_long');
  var cityField    = container.querySelector('.localization_city');
  var countryField = container.querySelector('.localization_country');
  var zipcodeField = container.querySelector('.localization_zip_code');

  /* Method to fill the inputs with the address contained in the param */
  var autocompleteInputs = function(address, options) {
    /* If true, force means that all the inputs should have their value updated,
     * otherwise just the ones that are blank */
    var force = options && options.force;

    latField.value     = force || latField.value.length === 0 ?
      address.lat : latField.value;
    lngField.value     = force || lngField.value.length === 0 ?
      address.lng : lngField.value;
    cityField.value    = force || cityField.value.length === 0 ?
      address.city || address.town || address.village || '' : cityField.value;
    zipcodeField.value = force || zipcodeField.value.length === 0 ?
      address.postcode || '' : zipcodeField.value;

    if(address.country_code) {
      countryField.options[countryField.selectedIndex].selected = false;
      countryField.querySelector('option[value="' +
        address.country_code.toUpperCase() + '"]').selected = true;
    }
  };

  /* If the form already stores coordinates, we add the marker on the map */
  var marker; /* The current marker on the map */
  if(latField.value.length > 0 && lngField.value.length > 0) {
    marker = dropMarkerOn(map, latField.value, lngField.value);
  }

  /* When the user click on the map, we display a marker and updates the inputs
   * accordingly */
  map.on('click', function(e) {
    var lat = e.latlng.lat,
        lng = e.latlng.lng;
    if(marker) { removeMarkerFrom(map, marker); }
    marker = dropMarkerOn(map, lat, lng);
    retrieveAddressFrom(lat, lng).done(function(address) {
      autocompleteInputs(address, { force: true });
    });
  });

  /* When the user fills the inputs, we try to autocomplete the others */
  var inputsListener = function() {
    if(latField.value.length === 0 || lngField.value.length === 0) {
      return;
    }
    retrieveAddressFrom(latField.value,
      lngField.value).done(autocompleteInputs);
    /* We add a marker to the location */
    if(marker) { removeMarkerFrom(map, marker); }
    marker = dropMarkerOn(map, latField.value, lngField.value);
  };
  $(latField).on('change', inputsListener);
  $(lngField).on('change', inputsListener);
};

/* Polyfill for Element.matches
 * Source: https://developer.mozilla.org/en/docs/Web/API/Element/matches */
var matches = function(elm, selector) {
    var matches = (elm.document || elm.ownerDocument).querySelectorAll(selector),
        i = matches.length;
    while (--i >= 0 && matches.item(i) !== elm) ;
    return i > -1;
};

/* Return the closest parent to an element that matches the selector */
var getClosestParent = function(element, selector) {
  var res = null;
  var currentElement = element;
  while(currentElement !== document) {
    currentElement = currentElement.parentNode;
    if(currentElement.matches && currentElement.matches(selector) ||
      !currentElement.matches && matches(currentElement, selector)) {
      res = currentElement;
      break;
    }
  }
  return res;
};

function onReady() {
  filterForms();
  dropdown();
  showMultiselect();
  showDatepicker();
  /* Initialize the mini maps attached to the location forms */
  var previewMaps = document.querySelectorAll('.map-preview');
  for(var i = 0, j = previewMaps.length; i < j; i++) {
    initPreviewMap(getClosestParent(previewMaps[i], '.form-inputs'));
  }
}

document.addEventListener('DOMContentLoaded', onReady);
