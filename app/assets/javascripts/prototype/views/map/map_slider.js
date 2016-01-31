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
      this.listenTo(this.router, 'change:queryParams',
        this.onQueryParamsChange);
      this.listenTo(this.status, 'change:isPlaying',
        this.onAnimationStatusChange);
    },

    /* EVENT HANDLERS */

    onQueryParamsChange: function(options) {
      this.pause();
      this.updateTimeline(options);
    },

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

      var translatePosition = 'translate(' + position + 'px)';
      /* We bound the handle to the timeline */
      this.timelineHandle[0][0].style.transform = translatePosition;
      this.timelineHandle[0][0].style.webkitTransform = translatePosition;
      this.timelineTooltip.textContent = this.dateFormat(this.timelineScale.invert(position));

      /* We give the position to the tooltip */
      this.timelineTooltip.style.transform       = translatePosition;
      this.timelineTooltip.style.webkitTransform = translatePosition;

      /* We make sure the tooltip is visible when the user moves the handle */
      if(d3.mouse(this.timeline)[0]) {
        this.timelineTooltip.classList.toggle('-hidden', false);
      }

      /* We update the map */
      if(d3.mouse(this.timeline)[0]) {
        root.app.pubsub.trigger('change:timeline',
          { date: this.timelineScale.invert(position) });
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

      /* Use the selected dates from the URL for the timeline's range */
      this.updateTimeline(this.router.getQueryParams());
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

      /* TODO: save in a variable the position instead of accessing the DOM */
      var handlePosition = parseFloat((this.timelineHandle[0][0].style.transform ||
        this.timelineHandle[0][0].style.webkitTransform).match(/translate(X)?\((.*)px\)/)[2]);
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
        this.pause();
        this.resetTimelineState();
        return;
      }

      var relativePercentage = this.animationFrameCounter /
        this.animationRemainingFrames;

      var position = this.animationInitialPosition +
        relativePercentage * this.animationRemainingDistance;

      /* Caches for performance improvements */
      var translatePosition = 'translateX(' + position + 'px)';
      var date = this.timelineScale.invert(position);

      /* We update the position of the handle */
      this.timelineHandle[0][0].style.transform = translatePosition;
      this.timelineHandle[0][0].style.webkitTransform = translatePosition;

      /* We update the position and the content of the tooltip */
      this.timelineTooltip.style.transform = translatePosition;
      this.timelineTooltip.style.webkitTransform = translatePosition;
      this.timelineTooltip.textContent = this.dateFormat(date);

      this.animationFrameCounter++;

      if(this.animationFrameCounter < this.animationRemainingFrames) {
        /* We update the map */
        root.app.pubsub.trigger('change:timeline', { date: date });

        this.currentAnimationID = requestAnimationFrame(this.animate.bind(this));
      } else {
        /* We make sure that when we reach the end, we go back to the beginning
         */
        this.pause();
        this.resetTimelineState();

        /* We reset the map */
        root.app.pubsub.trigger('change:timeline', {});
      }
    },

    /* Switch the control button's icon depending on the state of the animation
     */
    updateControls: function() {
      this.playbutton.classList.toggle('-paused', this.status.get('isPlaying'));
    },

    /* Update the date range of the timeline and resets its state */
    updateTimeline: function(options) {
      var minDate = options.start_date && new Date(options.start_date) || this.minDate,
          maxDate = options.end_date && new Date(options.end_date)   || this.maxDate;

      this.timelineScale.domain([minDate, maxDate]);
      this.timelineBrush.extent([minDate, maxDate]);

      this.resetTimelineState();
    },

    /* Move the timeline's handle and tooltip to the beginning, hide the tooltip
     * and reset its content */
    resetTimelineState: function() {
      this.timelineHandle[0][0].style.transform       = 'translateX(0)';
      this.timelineHandle[0][0].style.webkitTransform = 'translateX(0)';
      this.timelineTooltip.style.transform       = 'translateX(0)';
      this.timelineTooltip.style.webkitTransform = 'translateX(0)';

      this.timelineTooltip.classList.toggle('-hidden', true);
      this.timelineTooltip.textContent = this.dateFormat(this.timelineScale.domain()[0]);
    }

  });


})(this);
