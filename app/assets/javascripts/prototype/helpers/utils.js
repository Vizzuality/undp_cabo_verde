(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.Helper = root.app.Helper || {};

  root.app.Helper.utils = {

    /* Polyfill for the matches DOM API method (IE 9+)
     * Source: http://youmightnotneedjquery.com*/
    matches: function(el, selector) {
      return (el.matches || el.matchesSelector || el.msMatchesSelector || el.mozMatchesSelector || el.webkitMatchesSelector || el.oMatchesSelector).call(el, selector);
    },

    /* Return the element's closest parent which matches the given selector or
     * null if can't find it */
    getClosestParent: function(el, selector) {
      var res = null;
      var currentElement = el;
      while(currentElement !== document) {
        currentElement = currentElement.parentNode;
        if(this.matches(currentElement, selector)) {
          res = currentElement;
          break;
        }
      }
      return res;
    }

  };

})(this);
