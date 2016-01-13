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
      'click .stepnext': 'step',
      'click .stepprev': 'step'
    },

    initialize: function(options) {
      this.router = options.router;
      this.status = new Status();

      this._cacheVars();

      this._slider();

      this._cacheVars2();

    },

    _cacheVars: function() {
      this.$sliderSource = $('#slider');
      this.$leftLabel = $('#leftLabel');
      this.$rightLabel = $('#rightLabel');
      this.minYear = 1991;
      this.maxYear = 2010;
      this.ballCount = 0;
    },

    _cacheVars2: function() {
      this.$handles = $('.ui-slider-handle');
      this.leftHandle = this.$handles[0];
      this.rightHandle = this.$handles[1];
      this.$sliderRange = $('.ui-slider-range');
      this.$slider = $(".ui-slider");
      this.maxStepValue = this.maxYear - this.minYear; // will be overwritten as soon as handles change position
    },

    makeGrey: function() {
      this.leftHandle.style.background = "#cfcfcf";
      this.rightHandle.style.background = "#cfcfcf";
      this.$sliderRange[0].style.background = "#cfcfcf";

    },


    create: function(htmlStr) {
      var frag = document.createDocumentFragment(),
          temp = document.createElement('div');
      temp.innerHTML = htmlStr;
      while (temp.firstChild) {
        frag.appendChild(temp.firstChild);
      }
      return frag;
    },

    createBall: function() {
      var range = this.$sliderRange[0];
      var ball = this.create('<div id="ball"></div>');
      range.insertBefore(ball, range.childNodes[0]);
    },

    calcStepWidth: function() {
      var numberOfSteps = this.maxStepRange;
      var widthOfRange = window.getComputedStyle(this.$sliderRange[0]).width;

      widthOfRange = parseInt(widthOfRange); //subtract width of border
      console.log('widthOfRange: ' + widthOfRange);

      var stepWidth = widthOfRange/numberOfSteps;
      console.log('stepWidth: ' + stepWidth);
      return stepWidth;
    },

    // sets "global" variable this.maxStepRange to the number of steps between selected range
    calcStepRange: function() {
      var leftHandle = this.$sliderSource.slider("option", "values")[0];
      var rightHandle = this.$sliderSource.slider("option", "values")[1];

      this.maxStepRange = rightHandle - leftHandle;
    },

    step: function(e) {

      var range = this.$sliderRange[0];

      // makes handles and range background grey
      this.makeGrey();

      this.calcStepRange();

      this.stepWidth = this.calcStepWidth();


      // if range has child:
      if(range.childNodes.length !== 0) {

        // if first child is ball
        if(range.childNodes[0].getAttribute("id") == "ball") {
          var ball = range.childNodes[0];

          //get position of ball
          var currPosition = window.getComputedStyle(ball).left;

          //set new position of ball
          if (currPosition.length != 0) {

            if (e.currentTarget.className === "stepnext") {
              var newPosition = (parseFloat(currPosition) + this.stepWidth).toString() + "px"; // move right
              console.log('calculated new position 1');

              console.log('maxStepRange is ' + this.maxStepRange);
              // limit possible positions: wrap ->
              // if < 0 set to maxStepRange*stepWidth
              // if < maxStepRange*stepWidth

            } else if (e.currentTarget.className === "stepprev") {
              var newPosition = (parseFloat(currPosition) - this.stepWidth).toString() + "px"; // move left
              console.log('calculated new position 2');
            }

          } else {
            var newPosition = "0px"; // security step in case the position is not set
          }

          //move ball
          ball.style.left = newPosition;

          console.log(this.movedForward(newPosition, currPosition));

          if (this.movedForward(newPosition, currPosition)) {
            this.ballCount++;
          }else {
            this.ballCount--;
          }
          console.log('ballCount ' + this.ballCount);

          console.log('moved ball');
        }
      } else {
        //if no ball exists
        this.createBall();
        console.log('created ball');
      }

    },

    movedForward: function(newPosition, currPosition) {
      var positionA = parseFloat(currPosition);
      var positionB = parseFloat(newPosition);

      if (positionA > positionB) {
        return false;
      } else {
        return true;
      }
    },

    _slider: function() {
      var self = this;
      var minYear = this.minYear;
      var maxYear = this.maxYear;

      //initial setup of labels
      this.$leftLabel.text(minYear);
      this.$rightLabel.text(maxYear);
      self.$leftLabel.css('left', 0);     //TODO: position labels without pixel values
      self.$rightLabel.css('left', 330);  //TODO: position labels without pixel values

      this.$sliderSource.slider({
        min: minYear,
        max: maxYear,
        range: true,
        step: 1,
        values: [minYear, maxYear],
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
