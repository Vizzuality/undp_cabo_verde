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
      'click .stepnext': 'onNextStep',
      'click .stepprev': 'onPrevStep',
      'click .play': 'onPlay'
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
      this.steps = false;
    },

    _cacheVars2: function() {
      this.$handles = $('.ui-slider-handle');
      this.leftHandle = this.$handles[0];
      this.rightHandle = this.$handles[1];
      this.$sliderRange = $('.ui-slider-range');
      this.$slider = $(".ui-slider");
      this.maxStepRange = this.maxYear - this.minYear; // will be overwritten as soon as handles change position

    },

    onNextStep: function() {
      this.ballCount++;

      if(this.steps != true){
        this.createBall();
      }
      this.steps = true;

      this.prepareStep();
      this.step();

    },

    onPrevStep: function() {
      this.ballCount--;

      if(this.steps != true){
        this.createBall();
      }

      this.steps = true;

      this.prepareStep();
      this.step();

    },

    onPlay: function() {
      var self = this;
      var play = $('.play')[0];
      play.classList.toggle('paused');

      var isPlaying = !play.classList.contains('paused');

      if (isPlaying) {
        this.timer = window.setInterval(function(){
          self.onNextStep();
        }, 500);
      } else {
        window.clearInterval(this.timer);
      }

      // if (!play.classList.contains('paused')) {
      //   this.timer = window.setInterval(function(){
      //     self.onNextStep();
      //   }, 500);
      // } else {
      //   console.log(this.ballCount);
      //   console.log('stop steps');
      //   window.clearInterval(this.timer);
      // }
    },

    activateSteps: function() {
      this.leftHandle.style.background = "#cfcfcf";
      this.rightHandle.style.background = "#cfcfcf";
      this.$sliderRange[0].style.background = "#cfcfcf";
    },

    deactivateSteps: function() {
      this.leftHandle.style.background = "#175ca0";
      this.rightHandle.style.background = "#175ca0";
      this.$sliderRange[0].style.background = "#175ca0";
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
      this.ballCount = 0;
    },

    deleteBall: function() {
      var range = this.$sliderRange[0];
      var ball = $('#ball')[0];
      range.removeChild(ball);
    },

    calcStepWidth: function() {
      var numberOfSteps = this.maxStepRange;
      var widthOfRange = window.getComputedStyle(this.$sliderRange[0]).width;

      widthOfRange = parseInt(widthOfRange); //subtract width of border
      var stepWidth = widthOfRange/numberOfSteps; //get pixel amount
      return stepWidth; // e.g. 17.375
    },

    // sets "global" variable this.maxStepRange to the number of steps between selected range
    calcStepRange: function() {
      var leftHandle = this.$sliderSource.slider("option", "values")[0];
      var rightHandle = this.$sliderSource.slider("option", "values")[1];

      this.maxStepRange = rightHandle - leftHandle;
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

    prepareStep: function() {
      this.activateSteps(); // makes handles and range background grey
      this.calcStepRange(); // calculates maximum number of steps currently set
      this.stepWidth = this.calcStepWidth(); //width of step in px
    },

    step: function(e) {
      var range = this.$sliderRange[0];

      // if first child is ball
      if(range.childNodes[0].getAttribute("id") == "ball") {
        var ball = range.childNodes[0];

        //get position of ball
        var currPosition = window.getComputedStyle(ball).left;

        //calculate new position of ball
        if (currPosition.length != 0) {


          var newPositionInt = this.getNewPosition();
          var newPosition = newPositionInt.toString() + "px";

          this.setDate();

        } else {
          var newPosition = "0px"; // security step in case the position is not set
        }

        //apply calculated new position to ball
        ball.style.left = newPosition;
      }


    },

    setDate: function() {
      if (this.steps == true) {
        var year = parseInt(this.$leftLabel.text()) + this.ballCount;
        var currMin = year;
        var currMax = year;
      } else {
        var currMin = this.$leftLabel.text();
        var currMax = this.$rightLabel.text();
      }
      this.router.setQueryParams(this.makeDate(currMin, currMax));
    },

    makeDate: function(year1, year2) {
      var startDate = "01/01/" + year1;
      var endDate = "12/31/" + year2;
      var dates = {
        start_date: startDate,
        end_date: endDate
      };
      return dates;
    },

    _slider: function() {
      var self = this;

      //initial setup of labels: text and position
      this.$leftLabel.text(this.minYear);
      this.$rightLabel.text(this.maxYear);
      self.$leftLabel.css('left', this.posLeftHandle);     //TODO: position labels without pixel values
      self.$rightLabel.css('left', this.posRightHandle);  //TODO: position labels without pixel values

      this.$sliderSource.slider({
        min: this.minYear,
        max: this.maxYear,
        range: true,
        step: 1,
        values: [this.minYear, this.maxYear],
        slide: function(event, ui) {
          if (self.steps == true) {
            self.deactivateSteps();
            self.deleteBall();
            self.ballCount = 0;
            self.steps = false;
          }
          setTimeout(function() {
            //sets label text
            self.$leftLabel.text(ui.values[0]);
            self.$rightLabel.text(ui.values[1]);

            //sets position of handle (== position of label)
            self.posLeftHandle = $('.ui-slider-handle:first').position().left;
            self.posRightHandle = $('.ui-slider-handle:last').position().left;
            self.$leftLabel.css('left', self.posLeftHandle);
            self.$rightLabel.css('left', self.posRightHandle);
          }, 0);

          // updates URL with current values of range
          self.router.setQueryParams(self.makeDate(ui.values[0], ui.values[1]));
        }
      });
    }

  });

})(this);
