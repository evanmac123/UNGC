function drawCopDifferentationByYear(data) {

  data.forEach(function(d) {
    d["count"] = +d["count"];
    d["year"] = +d["year"];
  });

  var margin = {top: 20, right: 20, bottom: 30, left: 100};

  var width = 900 - margin.left - margin.right,
  height = 500 - margin.top - margin.bottom;

  var xScale = d3.scaleBand()
  .range([0,width]);

  var yScale = d3.scaleLinear()
  .range([height, 0]);

  var colorScale = d3.scaleOrdinal(d3.schemeCategory10);

  var legendRectSize = 18;
  var legendSpacing = 4;

  var svg = d3.select("#differentiation-year").append("svg")
  .attr("width", width + margin.left + margin.right)
  .attr("height", height + margin.top + margin.bottom)
  .append("g")
  .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  var filteredData = data.filter(function(d) {
    return d["differentiation"] == "advanced" ||
    d["differentiation"] == "active" ||
    d["differentiation"] == "learner" ||
    d["differentiation"] == "blueprint";
  })
  .filter(function(d) { return d["year"] > 2010; })
  .sort(function(a, b) { return a["year"] - b["year"]; });

  var valueLookup = d3.nest()
  .key(function(d) { return d["year"]; })
  .key(function(d) { return d["differentiation"]; })
  .map(data);

  var differentiations = d3.set(filteredData.map(function(d) { return d["differentiation"]; })).values(),
  years = d3.set(filteredData.map(function(d) { return d["year"]; })).values();

  pivotData = [];
  years.forEach(function(year) {
    var eachYear = {};
    differentiations.forEach(function(differentiation) {
      eachYear["year"] = year;
      var differentiationArray = valueLookup["$"+ year];
      var differentiationName = differentiationArray["$" + differentiation];
      if (differentiationName) {
        var getCountPosition = differentiationName[0];
        var theCount = getCountPosition["count"];
        eachYear[differentiation] = theCount;
      } else {
        eachYear[differentiation] = 0;
      }

    });
    pivotData.push(eachYear);
  });

  var stack = d3.stack()
  .keys(differentiations)
  .order(d3.stackOrderDescending)
  .offset(d3.stackOffsetNone);

  var series = stack(pivotData);
  xScale.domain(years);

  var allMaxValues = [];
  series.forEach(function(d) {
    d.forEach(function(d) {
      allMaxValues.push(d[1]);
    });
  });

  var maxValue = d3.max(allMaxValues, function(d) { return d; });
  yScale.domain([0, maxValue]);

  // x axis
  svg.append("g")
  .attr("class", "x axis")
  .attr("transform", "translate(0," + height + ")")
  .call(d3.axisBottom(xScale));

  // y axis
  svg.append("g")
  .attr("class", "y axis")
  .call(d3.axisLeft(yScale));

  // appends the rect
  svg.selectAll(".bar-group")
  .data(series)
  .enter().append("g")
  .attr("class", "bar-group")
  .style("fill", function(d) { return colorScale(d.key); })
  .selectAll(".bar")
  .data(function(d) { return d; })
  .enter().append("rect")
  .attr("class", "bar")
  .attr("x", function(d) { return xScale(d.data.year) + 10; })
  .attr("y", function(d) { return yScale(d[1]); })
  .attr("height", function(d) { return yScale(d[0]) - yScale(d[1]); })
  .attr("width", xScale.bandwidth() - 10)

  var legend = svg.selectAll('.legend')
  .data(colorScale.domain())
  .enter()
  .append('g')
  .attr('class', 'legend')
  .attr('transform', function(d, i) {
    var height = legendRectSize + legendSpacing;
    var offset =  height * colorScale.domain().length / 4;
    var horz = 39 * legendRectSize;
    var vert = i * height + offset;
    return 'translate(' + horz + ',' + vert + ' )';
  });

  legend.append('rect')
  .attr('width', legendRectSize)
  .attr('height', legendRectSize)
  .style('fill', colorScale)
  .style('stroke', colorScale);

  legend.append('text')
  .attr('x', legendRectSize + legendSpacing)
  .attr('y', legendRectSize - legendSpacing)
  .text(function(d) { return d.toUpperCase(); });




}
