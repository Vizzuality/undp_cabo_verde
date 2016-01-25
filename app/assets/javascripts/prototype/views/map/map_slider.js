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

      this.slider();
    },

    onPlay: function() {
      var play = $('.play')[0];
      play.classList.toggle('paused');
    },

    slider: function() {
      var sliderBox = this.$el.find('#slider');

      var margin = 12;

      var outerWidth = sliderBox.width();
      var innerWidth = sliderBox.width() - 2 * margin;
      var height = sliderBox.height();

      this.maxDays = 365;

      var x = d3.scale.linear()
        .range([0, innerWidth])
        .domain([0, this.maxDays]);

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
              .html('Day ' + Math.ceil(self.currentDay));
            circle
              .attr('cx', x(brush.extent()[0]));
          }
          progress.attr('width', x(value));
        })
        .on('brushend', this.onBrushEnd);

      var svg = d3.select('#slider')
        .append('svg')
        .attr('class', 'svg-timeline')
        .attr('width', outerWidth)
        .attr('height', height);

      trail = svg.append('g')
        .attr('class', 'trail')
        .attr('transform', 'translate(12 11)')
        .style('fill', 'white')
        .call(brush);

      trail.selectAll('.background')
        .attr('height', height); //remove -> progress does not appear

      trail.selectAll('.extent, .resize').remove();

      progress = trail.append('rect')
        .attr('class', 'progress')
        .style('fill', '#175ca0')
        .attr('width', 0)
        .attr('height', 3);

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
        .html('Day ' + this.currentDay);

      this.tooltip = tooltip;
      this.svg = svg;
      this.progress = progress;
      this.circle = circle;
      this.x = x;

    }

  });

})(this);
