//= require jquery2
//= require jquery_ujs
//= require jquery.ui.datepicker
//= require chosen-jquery
//= require leaflet
//= require forms

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
  var multiselects_domains = $('.domains-chose')

  for(var i = 0; i < multiselects.length; i++) {
    multiselects[i].classList.add('chosen');
    multiselects[i].classList.add('chosen-select');
  }

  for(var i = 0; i < multiselects_domains.length; i++) {
    multiselects[i].classList.add('chosen');
    multiselects[i].classList.add('chosen-select');
  }

  multiselects.chosen();
  multiselects_domains.chosen({ max_selected_options: 3 });
};

/* Display a mini map into the container and return it */
var createPreviewMap = function(container) {
  /* We show the map */
  var layer = L.tileLayer('http://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, &copy; <a href="http://cartodb.com/attributions">CartoDB</a>'
  });

  var southWest = L.latLng(-85, -720.0),
      northEast = L.latLng(85, 720.0),
      bounds = L.latLngBounds(southWest, northEast);

  var map = L.map(container, {
    center: [16.77, -23.70],
    zoom: 1,
    minZoom: 1,
    maxBounds: bounds
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

  /* We watch the inputs changes and map clicks only if the user is able to
   * modify the form (ie if it's not disabled) */
  if(!container.classList.contains('disabled')) {

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
  }
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

var showHideDomainLink = function() {
  var domainsValues = $('.domains-chose').val();

  if (domainsValues && domainsValues.length < 3 && domainsValues.length > 0) {
    $('.add_other_domain').show();
  } else {
    $('.add_other_domain').hide();
  }

  var toggleDomainLink;

  toggleDomainLink = function(event) {
    var targetVal = $(event.currentTarget).val();

    if (targetVal && targetVal.length > 2) {
      $('.add_other_domain').hide();
      $('.form-inputs-other-domains').remove();
    } else if (targetVal && targetVal.length > 0) {
      if (targetVal.length == 2 && $('.form-inputs-other-domains:visible').length == 2) {
        $('.add_other_domain').hide();
        $('.form-inputs-other-domains:visible:last').remove();
      } else if (targetVal.length > 1 && $('.form-inputs-other-domains:visible').length > 0) {
        $('.add_other_domain').hide();
      } else if (targetVal.length > 0) {
        $('.add_other_domain').show();
      }
    } else {
      $('.add_other_domain').hide();
      $('.form-inputs-other-domains').remove();
    }
  };

  $('.domains-chose').on('change', toggleDomainLink);
};

function onReady() {
  filterForms();
  showMultiselect();
  showDatepicker();
  showHideDomainLink();
  /* Initialize the mini maps attached to the location forms */
  var previewMaps = document.querySelectorAll('.map-preview');
  var form;
  for(var i = 0, j = previewMaps.length; i < j; i++) {
    form = getClosestParent(previewMaps[i], '.form-inputs');
    if(form) {
      initPreviewMap(getClosestParent(previewMaps[i], '.form-inputs'));
    }
  }
}

document.addEventListener('DOMContentLoaded', onReady);
