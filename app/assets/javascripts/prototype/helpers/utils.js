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
      while(currentElement !== document && currentElement !== null) {
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
    })(),

    /* Return true if the date is between startDate and endDate. In case
     * startDate is omitted, return true if date is before endDate. In case
     * endDate is omitted, return true if date is after startDate.
     * The params must be strings parseable by the Date object, Date objects or
     * timestamps. */
    isDateBetween: function(date, startDate, endDate) {
      /* We parse the date param */
      if(typeof date === 'string') {
        date = (new Date(date)).getTime();
      } else if(_.isDate(date)) {
        date = date.getTime();
      }
      /* We parse the startDate param */
      if(typeof startDate === 'string') {
        startDate = (new Date(startDate)).getTime();
      } else if(_.isDate(startDate)) {
        startDate = startDate.getTime();
      }
      /* We parse the endDate param */
      if(typeof endDate === 'string') {
        endDate = (new Date(endDate)).getTime();
      } else if(_.isDate(endDate)) {
        endDate = endDate.getTime();
      }

      return startDate && endDate && date >= startDate && date <= endDate ||
        startDate && !endDate && date >= startDate ||
        !startDate && endDate && date <= endDate;
    },

    /* Return a string date with the format MM/DD/YYYY from a string with format
     * YYYY-MM-DD */
    formatDate: function(date) {
      var res = null;

      if(date) {
        res = [date.split('-')[1], date.split('-')[2], date.split('-')[0]].join('/');
      }

      return res;
    }

  };

})(this);
