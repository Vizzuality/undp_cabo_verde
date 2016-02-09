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
        if(this.matches(currentElement, selector)) {
          res = currentElement;
          break;
        }
        currentElement = currentElement.parentNode;
      }
      return res;
    },

    /* Return true if the cursor hovers the element passed as argument
     * NOTE: take into account the cursor's position and not if the element is
     * actually hovering the element (the element could be hidden by another
     * one) */
    cursorHovers: (function() {
      /* Internal variable to save the cursor position */
      var cursorPosition = { x: null, y: null };

      document.body.addEventListener('mousemove', function(e) {
        cursorPosition = {
          x: e.clientX,
          y: e.clientY
        };
      });

      return function(el) {
        var cursorX = cursorPosition.x,
            cursorY = cursorPosition.y,
            elInfo  = el.getBoundingClientRect();

        return cursorX >= elInfo.left &&
          cursorX <= elInfo.left + elInfo.width && cursorY >= elInfo.top &&
          cursorY <= elInfo.top + elInfo.height;
      };
    })()

  };

})(this);
