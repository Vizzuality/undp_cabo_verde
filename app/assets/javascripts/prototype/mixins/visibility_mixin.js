(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.Mixin = root.app.Mixin || {};

  root.app.Mixin.visibility = {

    toggle: function(e) {
      if(e) { e.preventDefault(); }
      var isHidden = this.el.classList.toggle('-hidden');
      this.el.setAttribute('aria-hidden', isHidden);
      this.status.set('isHidden', isHidden);
    },

    show: function() {
      if(this.status.get('isHidden')) {
        this.toggle();
      }
    },

    hide: function() {
      if(!this.status.get('isHidden')) {
        this.toggle();
      }
    }

  };

})(this);
