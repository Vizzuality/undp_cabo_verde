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

      this.cacheVars();
      this.slider();
    },

    cacheVars: function() {
      this.currentDay = new Date('01/01/1991');
    },

    convertDate: function(date) {
      var months = new Array("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec");

      var day = date.getDate();
      var month = date.getMonth(); // -> Jan is 0
      var year = date.getFullYear() // getYear not recommended

      var dateString = (day + " " + months[month] + " " + year);
      return dateString;
    },

    slider: function() {
      var sliderBox = this.$el.find('#slider');

      var startDate = new Date('05/24/1992');
      var endDate = new Date('01/26/2015');

      var margin = 12;

      this.outerWidth = sliderBox.width();
      this.innerWidth = sliderBox.width() - 2 * margin;

      this.outerHeight = sliderBox.height();
      this.innerHeight = 3;

      this.maxDays = 365;

      var x = d3.time.scale()
        .range([0, this.innerWidth])
        .clamp(true)
        .domain([startDate, endDate])

      // var x = d3.scale.linear()
      //   .range([0, this.innerWidth])
      //   .clamp(true)
      //   .domain([0, this.maxDays]);

      var progress, trail;
      var circle;
      var tooltip = $('.slider-tooltip');

      var self = this;

      var brush = this.brush = d3.svg.brush()
        .x(x)
        .extent([0,0])
        .clamp(true)
        .on('brush', function() {
          var value = brush.extent()[1];
          if (d3.event.sourceEvent) {
            value = x.invert(d3.mouse(this)[0]);
            brush.extent([value, value]);
            self.currentDay = value;
            tooltip
              .css({left: x(brush.extent()[0])})
              .html(self.convertDate(self.currentDay));
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
        .style('fill', 'white')
        .call(brush);

      trail.selectAll('.background')
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
        .html(self.convertDate(self.currentDay));

      this.tooltip = tooltip;
      this.svg = svg;
      this.progress = progress;
      this.circle = circle;
      this.x = x;

    }

  });

})(this);
