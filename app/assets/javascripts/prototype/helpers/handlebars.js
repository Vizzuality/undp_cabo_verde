Handlebars.registerHelper('t', function(value) {
  return I18n.translate(value);
});

Handlebars.registerHelper('date', function(format, value) {
  /* Function to pad the numbers to X digits */
  var pad = function(number, digits) {
    var padding = digits - ('' + number).length;
    return (padding > 0 ? Array(padding + 1).join('0') : '') + number;
  };

  if(format === 'long') {
    var date = new Date(value);
    var day     = pad(date.getDate(), 2),
        month   = pad(date.getMonth() + 1, 2),
        year    = pad(date.getFullYear(), 4),
        hours   = pad(date.getHours(), 2),
        minutes = pad(date.getMinutes(), 2)
        amPm    = (+hours < 12 || +hours === 12 && +minutes === 0) ? 'AM' :
          'PM';

    return [ month, day, year ].join('/') + ' ' + [ hours, minutes ].join(':') +
      ' ' + amPm;
  } else {
    return value;
  }
});

Handlebars.registerHelper('trunc', function(value) {
  var split = value.split(',');
  if(split.length > 1) return split[0] + '...';
  else return value;
});

Handlebars.registerHelper('compare', function(lvalue, operator, rvalue,
  options) {
  if(arguments.length < 4) {
    throw new Error('Handlerbars Helper "compare" needs 3 parameters');
  }

  var operators = {
    '==':     function (l, r) { return l        ==  r; },
    '===':    function (l, r) { return l        === r; },
    '!=':     function (l, r) { return l        !=  r; },
    '!==':    function (l, r) { return l        !== r; },
    '<':      function (l, r) { return l        <   r; },
    '>':      function (l, r) { return l        >   r; },
    '<=':     function (l, r) { return l        <=  r; },
    '>=':     function (l, r) { return l        >=  r; },
    'typeof': function (l, r) { return typeof l ==  r; }
  };

  if (!operators[operator]) {
    throw new Error('Handlerbars Helper "compare" doesn\'t know the operator ' +
      operator);
  }

  var res = operators[operator](lvalue, rvalue);

  if (res) {
      return options.fn(this);
  }

  return options.inverse(this);
});
