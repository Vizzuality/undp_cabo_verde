Handlebars.registerHelper('t', function(value) {
  return I18n.translate(value);
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
