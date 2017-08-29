function drawCopPercentage(data) {
  data.forEach(function(d) {
    d.count = +d.count;
    d.year = +d.year
    d.enabled = true;
  });

  var year = d3.set(data.map(function(d) { return d.year; }))

  var width = 1000;
  var height = 350;

  var radius = 150;

  var donutWidth = 45;

  var legendRectSize = 18;
  var legendSpacing = 1;

  var colorScale = d3.scaleOrdinal(d3.schemeCategory20c)

  //var colorScale = d3.scaleQuantile()
  //.domain([1, maxValue])
  //.range([
    //'rgb(163,200,226)',
    //'rgb(141,185,217)',
    //'rgb(119,168,207)',
    //'rgb(101,151,194)',
    //'rgb(93,139,180)',
    //'rgb(86,125,162)',
    //'rgb(78,110,142)',
    //'rgb(63,89,120)',
    //'rgb(42,64,95)',
    //'rgb(30,50,80)'
  //]);

  var svg = d3.select('#dount-chart')
    .append('svg')
    .attr('width', width)
    .attr('height', height)
    .append('g')
    .attr('transform', 'translate(' + (width / 3) +
      ',' + (height / 2) + ')');

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
    .attr('class', 'year');
  tooltip.append('div')
    .attr('class', 'count');
  tooltip.append('div')
    .attr('class', 'percent');

  var path = svg.selectAll('path')
    .data(pie(data))
    .enter()
    .append('path')
    .attr('d', arc)
    .attr('fill', function(d, i) {
      return colorScale(d.data.year);
    })
    .each(function(d) { this._current = d; });
  path.on('mouseover', function(d) {
      var total = d3.sum(data.map(function(d) {
        return (d.enabled) ? d.count : 0;
      }));
      var percent = Math.round(1000 * d.data.count / total) / 10;
      tooltip.select('.year').html(d.data.year);
      tooltip.select('.count').html(d.data.count);
      tooltip.select('.percent').html(percent + '%');
      tooltip.style('display', 'block');
    });
    path.on('mouseout', function() {
      tooltip.style('display', 'none');
    });

    var legend = d3.select("svg").append("g")
      .attr("transform","translate(" +0+"," +160 + ")" )
      .selectAll('.legend')
      .data(colorScale.domain())
      .enter().append('g')
      .attr('class', 'legend')
      .attr('transform', function(d, i) {
        var height = legendRectSize - legendSpacing;
        var offset =  height * colorScale.domain().length / 2.1;
        var horz = 35 * legendRectSize;
        var vert = i * height - offset;
        return 'translate(' + horz + ',' + vert + ')';
      });

  legend.append('rect')
    .attr('width', legendRectSize)
    .attr('height', legendRectSize)
    .style('fill', colorScale)
    .style('stroke', colorScale)
    .on('click', function(year) {
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
      if (d.year === year) d.enabled = enabled;
      return (d.enabled) ? d.count : 0;
    });
    path = path.data(pie(data));
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
