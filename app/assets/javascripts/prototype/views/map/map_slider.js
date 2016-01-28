(function(root) {

  'use strict';

  root.app = root.app || {};
  root.app.View = root.app.View || {};
  root.app.Mixin = root.app.Mixin || {};
  root.app.Helper = root.app.Helper || {};

  var Status = Backbone.Model.extend({
    defaults: { isHidden: false }
  });

  root.app.View.sliderView = Backbone.View.extend({

    el: '#map-slider',

    events: {
      'click .play': 'onPlay'
    },

    initialize: function(options) {
      this.router = options.router;
      this.status = new Status();

      this.setListeners();

      this.playbutton = $('.play')[0];

      this.setMin();
      this.setMax();

      this.isActive = false;
      this.createMockBackground();
    },

    setListeners: function() {
      this.listenTo(this.router, 'change:queryParams', this.onFiltering);
    },

    /* Destroys current slider, creates mockup slider. Gets selected dates from router, sets them as global Params */
    onFiltering: function() {
      this.isActive = false; // slider idle
      this.makeSliderInactive();

      this.setStart();
      this.setEnd();

    },

    /* Sets Start and Current Date to the dataset's earliest date */
    setMin: function() {
      var minDateString = document.getElementById('startDate').dataset["min"];
      this.startDate = new Date(minDateString);
      this.currentDay = this.startDate;
    },

    /* Sets End Date to the Dataset's latest date */
    setMax: function() {
      var maxDateString = document.getElementById('endDate').dataset["max"];
      this.endDate = new Date(maxDateString);
    },

    /* Sets Start and Current Date to the selected end date */
    setStart: function() {
      var startDateQuery = this.router.getQueryParams()["start_date"];
      if (startDateQuery.length !== 0) {
        this.startDate = new Date(startDateQuery);
        this.currentDay = this.startDate;
      }else{
        this.setMin();
      }
    },

    /* Sets End Date to the selected end date */
    setEnd: function() {
      var endDateQuery = this.router.getQueryParams()["end_date"];
      if (endDateQuery.length !== 0) {
        this.endDate = new Date(this.router.getQueryParams()["end_date"]);
      }else{
        this.setMax();
      }
    },

    /* Destroys the slider by deleting the child nodes of the containing box, #slider */
    destroySlider: function() {
      var sliderBox = this.$el.find('#slider')[0];
      while (sliderBox.firstChild) {
        sliderBox.removeChild(sliderBox.firstChild);
      }
    },

    /* Adds a blue line to the slider box to simulate inactive state */
    createMockBackground: function() {
      var self = this;

      var svg = d3.select('#slider')
        .append('svg')
        .attr('class', 'svg-timeline')
        .attr('width', 284)
        .attr('height', 25);

      var bg = svg.append('rect')
        .attr('class', 'bg')
        .attr('width', 260)
        .attr('height', 3)
        .style('fill', '#175ca0')
        .attr('transform', 'translate(12 11)');
    },

    makeSliderInactive: function() {
      this.destroySlider();
      this.createMockBackground();
    },

    /* Converts a date object to a string like "8 Jan 2013" */
    dateForTooltip: function(date) {
      var months = new Array("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec");

      var day = date.getDate();
      var month = date.getMonth(); // -> Jan is 0
      var year = date.getFullYear() // getYear not recommended

      var dateString = (day + " " + months[month] + " " + year);
      return dateString;
    },

    /* Converts a date object to a string like "01/08/2013" */
    dateForQuery: function(date) {
      var month = (1 + date.getMonth()).toString();
      month = month.length > 1 ? month : '0' + month;

      var day = date.getDate().toString();
      day = day.length > 1 ? day : '0' + day;

      var year = date.getFullYear();

      var dateString = [month, day, year].join("/");
      return dateString;
    },

    /* Initializes the slider incl. tooltip, sets inner and outer width/height variables */
    slider: function() {

      var sliderBox = this.$el.find('#slider');

      var margin = 12;

      this.outerWidth = sliderBox.width();
      this.innerWidth = sliderBox.width() - 2 * margin;

      this.outerHeight = sliderBox.height();
      this.innerHeight = 3;

      var x = d3.time.scale()
        .range([0, this.innerWidth])
        .clamp(true)
        .domain([this.startDate, this.endDate])

      var progress, trail;
      var circle;

      var tooltip = document.createElement('div');
      tooltip.className = "slider-tooltip";
      sliderBox[0].insertBefore(tooltip, null);

      tooltip = $('.slider-tooltip');

      var self = this;

      var brush = this.brush = d3.svg.brush()
        .x(x)
        .extent([0,0])
        .clamp(true)
        .on('brush', function() {
          var value = brush.extent()[1];
          if (d3.event.sourceEvent) {
            self.stopAfterDrag();
            value = x.invert(d3.mouse(this)[0]);
            brush.extent([value, value]);
            self.currentDay = value;

            // TODO: Does not work like this because
            // setting the URL params triggers an event at the same time
            // which resets the slider

            // var summary = {};

            // summary["start_date"] = self.dateForQuery(self.currentDay);
            // summary["end_date"] = self.dateForQuery(self.currentDay);

            // self.router.setQueryParams(summary);

            tooltip
              .css({left: x(brush.extent()[0])})
              .html(self.dateForTooltip(self.currentDay));
            circle
              .attr('cx', x(brush.extent()[0]));
          }
          progress.attr('width', x(value));
        })
        .on('brushend', this.onBrushEnd);

      var svg = d3.select('#slider')
        .append('svg')
        .attr('class', 'svg-timeline')
        .attr('width', this.outerWidth)
        .attr('height', this.outerHeight);

      trail = svg.append('g')
        .attr('class', 'trail')
        .attr('transform', 'translate(12 11)')
        .call(brush);

      trail.selectAll('.background')
        .style('visibility', 'visible')
        .style('fill', '#175ca0')
        .attr('height', this.innerHeight);

      trail.selectAll('.extent, .resize').remove();

      progress = trail.append('rect')
        .attr('class', 'progress')
        .style('fill', '#175ca0')
        .attr('width', 0)
        .attr('height', this.innerHeight);

      circle = trail.append('circle')
        .attr('class', 'circle')
        .attr("cx", 0)
        .attr("cy", 1)
        .attr("r", 7.5)
        .style("fill", "#175ca0");

      progress
        .call(brush.extent([0,0]))
        .call(brush.event);


      tooltip
        .css({left: x(brush.extent()[0])})
        .html(self.dateForTooltip(self.currentDay));

      this.tooltip = tooltip;
      this.svg = svg;
      this.progress = progress;
      this.circle = circle;
      this.x = x;

    },

    /* Decide if to activate the slider (by destroying the mockup and making a new one) or if to enter play/pause mode */
    onPlay: function() {
      if (!this.isActive) {
        this.isActive = true;
        this.destroySlider();
        this.slider();
        this.play();
      }else{
        //if slider is already active, switch between play and pause
        if (this.isPlaying()) {
          this.pause();
        } else {
          this.play();
        }
      }
    },

    /* The animation of the slider */
    play: function() {
      this.playbutton.classList.remove('paused');

      var self = this;

      var duration = 10000; // total trajectory time in ms
      var percentageMoved = Number(this.progress.attr('width')) / this.innerWidth; // percentage: of 1, not 100!
      var percentageLeft = 1 - percentageMoved;
      var durationLeft = duration * percentageLeft;

      this.progress
        .transition()
        .duration(durationLeft)
        .ease('linear')
        .attr('width', this.innerWidth);

      this.circle
        .transition()
        .duration(durationLeft)
        .ease('linear')
        .attr('cx', this.innerWidth);

      if (this.interval) {
        clearInterval(this.interval);
      }

      this.interval = setInterval(function() {
        var width = self.progress.attr('width');

        // Reset to position at zero and pause animation when finished
        if (Number(width) >= self.innerWidth) {
          self.progress.attr('width', 0);
          self.circle.attr('cx', 0);
          if (self.isPlaying()) {
            self.pause();
          }
          return;
        }

        var value = self.x.invert(width);
        self.brush.extent([value, value]);
        self.currentDay = value;
        self.tooltip
          .css({left: self.x(self.brush.extent()[0])})
          .html(self.dateForTooltip(self.currentDay));
        self.trigger('timeline:change', value);
      }, 1);

    },

    /* Stop the animation and change state of the button */
    pause: function() {
      this.playbutton.classList.add('paused');

      this.progress
        .interrupt();
      this.circle
        .interrupt();
    },

    /* When grabbing the handle during the animation, stop the animation */
    stopAfterDrag: function() {
      if (this.isPlaying()) {
        this.pause();
      }
    },

    isPlaying: function() {
      var isPlaying = !this.playbutton.classList.contains('paused');
      return isPlaying;
    }

  });


})(this);
