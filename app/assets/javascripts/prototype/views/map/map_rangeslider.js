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
      this.posLeftHandle = 0;
      this.posRightHandle = 330; //set when first
    },

    _cacheVars2: function() {
      this.$handles = $('.ui-slider-handle');
      this.leftHandle = this.$handles[0];
      this.rightHandle = this.$handles[1];
      this.$sliderRange = $('.ui-slider-range');
      this.$slider = $(".ui-slider");
      this.maxStepRange = this.maxYear - this.minYear; // will be overwritten as soon as handles change position

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

      this.makeGrey(); // makes handles and range background grey

      this.calcStepRange(); //maximum number of steps
      console.log('maxStepRange is ' + this.maxStepRange);

      this.stepWidth = this.calcStepWidth(); //width of step in px

      console.log("posLeftHandle: " + this.posLeftHandle);

      // if range has child:
      if(range.childNodes.length !== 0) {

        // if first child is ball
        if(range.childNodes[0].getAttribute("id") == "ball") {
          var ball = range.childNodes[0];

          //get position of ball
          var currPosition = window.getComputedStyle(ball).left;

          //calculate new position of ball
          if (currPosition.length != 0) {
            // move left or move right -> adapt ballCount
            if (e.currentTarget.className === "stepnext") {
              this.ballCount++;
            } else if (e.currentTarget.className === "stepprev") {
              this.ballCount--;
            }

            var newPositionInt = this.getNewPosition();
            var newPosition = newPositionInt.toString() + "px";
            console.log('calculated new position: ' + newPosition);

          } else {
            var newPosition = "0px"; // security step in case the position is not set
          }

          //apply calculated new position to ball
          ball.style.left = newPosition;
          console.log('moved ball');
        }
      } else {
        //if no ball exists
        this.createBall();
        console.log('created ball');
      }

    },

    getNewPosition: function() {
      //limit or wrap the ballCount
      if (this.ballCount > this.maxStepRange) {
        this.ballCount = 0;
      }
      if (this.ballCount < 0) {
        this.ballCount = this.maxStepRange;
      }
      var newPosition = (this.ballCount * this.stepWidth);
      return newPosition;
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
      self.$leftLabel.css('left', this.posLeftHandle);     //TODO: position labels without pixel values
      self.$rightLabel.css('left', this.posRightHandle);  //TODO: position labels without pixel values

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
            self.posLeftHandle = $('.ui-slider-handle:first').position().left;
            self.posRightHandle = $('.ui-slider-handle:last').position().left;
            if (self.ballCount > 0) {
              //reset (TODO: make better)
              $('#ball')[0].style.left = "0px";
              self.ballCount = 0;
            }
            self.$leftLabel.css('left', self.posLeftHandle);
            self.$rightLabel.css('left', self.posRightHandle);
          }, 0);

        }
      });
    }

  });

})(this);
