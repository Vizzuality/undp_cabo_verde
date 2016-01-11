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

    initialize: function(options) {
      this.router = options.router;
      this.status = new Status();

      this._cacheVars();

      this._slider();

    },

    _cacheVars: function() {
      this.$slider = $('#slider');
      this.$leftLabel = $('#leftLabel');
      this.$rightLabel = $('#rightLabel');
    },

    _slider: function() {
      var self = this;
      var minValue = 1991;
      var maxValue = 2010;

      //initial setup of labels
      this.$leftLabel.text(minValue);
      this.$rightLabel.text(maxValue);
      self.$leftLabel.css('left', 0);     //TODO: position labels without pixel values
      self.$rightLabel.css('left', 330);  //TODO: position labels without pixel values

      this.$slider.slider({
        min: minValue,
        max: maxValue,
        range: true,
        step: 1,
        values: [minValue, maxValue],
        slide: function(event, ui) {
          // console.log(event, ui);
          setTimeout(function() {
            self.$leftLabel.text(ui.values[0]);
            self.$rightLabel.text(ui.values[1]);

            //position of handle: position of label
            var pos_leftHandle = $('.ui-slider-handle:first').position().left;
            var pos_rightHandle = $('.ui-slider-handle:last').position().left;
            self.$leftLabel.css('left', pos_leftHandle);
            self.$rightLabel.css('left', pos_rightHandle);

          }, 0);
        }
      });
    }

  });

})(this);
