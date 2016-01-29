(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};

  var Status = Backbone.Model.extend({
    defaults: { isPlaying: false }
  });

  root.app.View.mapSliderView = Backbone.View.extend({

    el: '#map-slider',

    events: {
      'click .js-play-button': 'onControlsClick'
    },

    initialize: function(options) {
      this.router = options.router;
      this.status = new Status();

      this.playbutton = this.el.querySelector('.js-play-button');
      this.svgSlider = this.el.querySelector('.slider svg');
      this.timeline = this.el.querySelector('.slider .js-timeline');
      this.timelineTooltip = this.el.querySelector('.js-timeline-tooltip');

      /* We set the default params */
      this.minDate = new Date(gon.min_date);
      this.maxDate = new Date(gon.max_date);
      this.dateFormat = d3.time.format('%d %b %Y');

      this.initSlider();
      this.setListeners();
    },

    setListeners: function() {
      this.listenTo(this.router, 'change:queryParams', this.onDatesChange);
      this.listenTo(this.status, 'change:isPlaying',
        this.onAnimationStatusChange);
    },

    /* EVENT HANDLERS */

    // /* Destroys current slider, creates mockup slider. Gets selected dates from
    //  * router, sets them as global params. */
    // onDatesChange: function() {
    //   this.isPlaying = false; // slider idle
    //   this.makeSliderInactive();
    //   this.setStartDate();
    //   this.setEndDate();
    // },

    onAnimationStatusChange: function() {
      this.updateControls();
    },

    onControlsClick: function() {
      if(!this.status.get('isPlaying')) {
        this.play();
      } else {
        this.pause();
      }
    },

    onTimelineBrush: function() {
      /* We pause the animation whenever the user moves the handle */
      this.pause();

      /* We update the position of the handle */
      var position = d3.mouse(this.timeline)[0] || 0;
      position = this.timelineScale(this.timelineScale.invert(position));
      /* We bound the handle to the timeline */
      this.timelineHandle.attr('cx', position);
      this.timelineTooltip.textContent = this.dateFormat(this.timelineScale.invert(position));

      /* We give the position to the tooltip */
      this.timelineTooltip.style.left = this.timelineScale(this.timelineScale.invert(position)) +
        'px';

      /* We make sure the tooltip is visible when the user moves the handle */
      if(d3.mouse(this.timeline)[0]) {
        this.timelineTooltip.classList.toggle('-hidden', false);
      }
    },

    /* LOGIC */

    /* Init the slider's features */
    initSlider: function() {
      /* Params to be used to render the slider */
      var margin = 12;

      var svgSliderBoundingRect = this.svgSlider.getBoundingClientRect();
      var svgSliderOuterWidth = svgSliderBoundingRect.width,
          svgSliderInnerWidth = svgSliderOuterWidth - 2 * margin;
      var svgSliderOuterHeight = svgSliderBoundingRect.height,
          svgSliderInnerHeight = 3;

      /* We define the timeline's scale */
      this.timelineScale = d3.time.scale()
        .domain([this.minDate, this.maxDate])
        .range([0, svgSliderInnerWidth])
        .clamp([true, false]);

      this.timelineHandle = d3.select(this.svgSlider)
        .select('.handle');

      this.timelineBrush = d3.svg.brush()
        .x(this.timelineScale)
        .extent([this.minDate, this.minDate])
        .clamp([true, false])
        .on('brush', this.onTimelineBrush.bind(this));

      d3.select(this.svgSlider)
        .select('.handle-container')
        .call(this.timelineBrush)
        .call(this.timelineBrush.event)
        .selectAll('.extent, .resize, .background')
        .remove();
    },

    /* Pause the animation */
    pause: function() {
      this.status.set({ isPlaying: false });
      if(this.currentAnimationID) cancelAnimationFrame(this.currentAnimationID);
    },

    /* Play the animation */
    play: function() {
      if(this.status.get('isPlaying')) return;
      this.status.set({ isPlaying: true });

      /* Constants for the animation */
      var duration = 10000;
      var fps      = 60;

      var handlePosition = parseInt(this.timelineHandle.attr('cx'));
      var percentageLeft = 1 - handlePosition / this.timelineScale.range()[1];
      /* These values won't be updated during the animation. We use at as
       * references for the percentage computed in the animate method. */
      this.animationInitialPosition = handlePosition;
      this.animationRemainingDistance = percentageLeft *
        this.timelineScale.range()[1];
      /* Once the animation is started, this number isn't updated. What's
       * happening is that we increment a counter until reaching that number. */
      this.animationRemainingFrames =  Math.ceil(percentageLeft * duration *
        (fps / 1000));
      this.animationFrameCounter = 0;

      /* We display the tooltip */
      this.timelineTooltip.classList.toggle('-hidden', false);

      /* We start the animation */
      if(this.currentAnimationID) cancelAnimationFrame(this.currentAnimationID);
      this.currentAnimationID = requestAnimationFrame(this.animate.bind(this));
    },

    animate: function() {
      /* In case the user puts the handle directly at the end, we move it to the
       * beginning */
      if(this.animationRemainingFrames === 0) {
        this.timelineHandle.attr('cx', 0);
        this.timelineTooltip.style.left = 0;
        this.pause();
        return;
      }

      var relativePercentage = this.animationFrameCounter /
        this.animationRemainingFrames;

      var position = this.animationInitialPosition +
        relativePercentage * this.animationRemainingDistance;

      /* We update the position of the handle */
      this.timelineHandle.attr('cx', position);

      /* We update the position and the content of the tooltip */
      this.timelineTooltip.style.left = position + 'px';
      this.timelineTooltip.textContent = this.dateFormat(this.timelineScale.invert(position));

      this.animationFrameCounter++;

      if(this.animationFrameCounter < this.animationRemainingFrames) {
        this.currentAnimationID = requestAnimationFrame(this.animate.bind(this));
      } else {
        /* We make sure that when we reach the end, we go back to the beginning
         */
        this.timelineHandle.attr('cx', 0);
        this.timelineTooltip.classList.toggle('-hidden', true);
        this.timelineTooltip.style.left = 0;
        this.timelineTooltip.textContent = this.dateFormat(this.timelineScale.domain()[0]);
        this.pause();
      }
    },

    updateControls: function() {
      this.playbutton.classList.toggle('-paused', this.status.get('isPlaying'));
    }

  });


})(this);
