(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};
  root.app.Mixin = root.app.Mixin || {};
  root.app.Helper = root.app.Helper || {};

  var Status = Backbone.Model.extend({
    defaults: { isHidden: false }
  });

  root.app.View.rangesliderView = Backbone.View.extend({

    el: '#map-rangeslider',

    events: {
      'click .sliderlink': 'confirm'
    },

    _moveValueLabels: function(leftLabel, rightLabel) {
      var pos_first_handle = $('.ui-slider-handle:first').position();
      var pos_last_handle = $('.ui-slider-handle:last').position();

      console.log('pfl left         ' + pos_first_handle.left);
      console.log('leftLabel.width()/2 ' + leftLabel.width()/2);

      leftLabel.css('left', (pos_first_handle.left));
      rightLabel.css('left', (pos_last_handle.left));
    },

    initialize: function(options) {
      var self = this;

      this.router = options.router;
      this.status = new Status();

      this.$slider = $('#slider');
      this.$leftLabel = $('#leftLabel');
      this.$rightLabel = $('#rightLabel');


      var minValue = 1991;
      var maxValue = 2010;

      this.$leftLabel.text(minValue);
      this.$rightLabel.text(maxValue);

      this.$slider.slider({
        animate: "fast",
        min: minValue,
        max: maxValue,
        range: true,
        step: 1,
        values: [minValue, maxValue],
        slide: function(event, ui) {
          self.$leftLabel.text(ui.values[0]);
          self.$rightLabel.text(ui.values[1]);

          self._moveValueLabels(self.$leftLabel, self.$rightLabel);
        }
      });

      this._moveValueLabels(self.$leftLabel, self.$rightLabel);

    }


  });

})(this);
