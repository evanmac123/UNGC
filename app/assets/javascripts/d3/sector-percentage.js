function drawSectorPercentage(data) {
  data.forEach(function(d) {
    d.count = +d.count;
    d.enabled = true;
  });

  var sector = d3.set(data.map(function(d) { return d.sector_name; }))

  var width = 960;
  var height = 750;

  var radius = 150;

  var donutWidth = 45;

  var legendRectSize = 18;
  var legendSpacing = .5;

  var margin = {top: 0, right: 0, bottom: 30, left: 2000};

  //var colorScale = d3.scaleOrdinal(d3.schemeCategory20);
  var colorScale = d3.scaleOrdinal(d3.schemeCategory20c)

  var svg = d3.select('#dount-chart')
    .append('svg')
    .attr('width', width)
    .attr('height', height)
    .append('g')
    .attr('transform', 'translate(' + (width / 2.3) +
      ',' + (height / 4) + ')');
    //.attr("transform", "translate(" + margin.left + "," + margin.top + ")");  

  var arc = d3.arc()
    .innerRadius(radius - donutWidth)
    .outerRadius(radius);

  var pie = d3.pie()
    .value(function(d) { return d.count; })
    .sort(null);

    var tooltip = d3.select('#dount-chart')
      .append('div')
      .attr('class', 'tooltip');
    tooltip.append('div')
      .attr('class', 'sector');
    tooltip.append('div')
      .attr('class', 'count');
    tooltip.append('div')
      .attr('class', 'percent');

    var sortedData = data.sort(function(x, y){
        return d3.ascending(x.count, y.count);
      });

    var path = svg.selectAll('path')
      .data(pie(sortedData))
      .enter()
      .append('path')
      .attr('d', arc)
      .attr('fill', function(d, i) {
        return colorScale(d.data.sector_name);
      })
      .each(function(d) { this._current = d; });
    path.on('mouseover', function(d) {
        var total = d3.sum(data.map(function(d) {
          return (d.enabled) ? d.count : 0;
        }));
        var percent = Math.round(1000 * d.data.count / total) / 10;
        tooltip.select('.sector').html(d.data.sector_name);
        tooltip.select('.count').html(d.data.count);
        tooltip.select('.percent').html(percent + '%');
        tooltip.style('display', 'block');
      });
      path.on('mouseout', function() {
        tooltip.style('display', 'none');
      });
          // path.on('mousemove', function(d) {
          //   tooltip.style('top', (d3.event.layerY + 10) + 'px')
          //     .style('left', (d3.event.layerX + 10) + 'px');
          // });

// legend
  var legend = d3.select("svg").append("g")
    .attr("transform","translate(" +0+"," +350 + ")" )
    .selectAll('.legend')
    .data(colorScale.domain())
    .enter().append('g')
    .attr('class', 'legend')
    .attr('transform', function(d, i) {
      var height = legendRectSize - legendSpacing;
      var offset =  height * colorScale.domain().length / 1.8;
      var horz = 35 * legendRectSize;
      var vert = i * height - offset;
      return 'translate(' + horz + ',' + vert + ')';
    });

    legend.append('rect')
    .attr('width', legendRectSize)
    .attr('height', legendRectSize)
    .style('fill', colorScale)
    .style('stroke', colorScale)
    .on('click', function(sector) {
      var rect = d3.select(this);
      var enabled = true;
      var totalEnabled = d3.sum(data.map(function(d) {
        return (d.enabled) ? 1 : 0;
      }));

      if (rect.attr('class') === 'disabled') {
        rect.attr('class', '');
      } else {
        if (totalEnabled < 2) return;
        rect.attr('class', 'disabled');
        enabled = false;
      }

      pie.value(function(d) {
        if (d.sector_name === sector) d.enabled = enabled;
        return (d.enabled) ? d.count : 0;
      });

      path = path.data(pie(sortedData));

      path.transition()
        .duration(750)
        .attrTween('d', function(d) {
          var interpolate = d3.interpolate(this._current, d);
          this._current = interpolate(0);
          return function(t) {
            return arc(interpolate(t));
          };
        });
    });

    legend.append('text')
  .attr('x', legendRectSize + legendSpacing + 5)
  .attr('y', legendRectSize - legendSpacing - 5)
  .text(function(d) { return d; });


}
