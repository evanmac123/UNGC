function drawCopMonthlyCharts(data, startYear) {
  //startYear is not set yet, it will be set below or the first existing year will be set

  var margin = {top: 20, right: 40, bottom: 30, left: 120};

  var width = 960 - margin.left - margin.right,
  height = 350 - margin.top - margin.bottom;

  var months = [
    'January', 'February', 'March', 'April', 'May',
    'June', 'July', 'August', 'September',
    'October', 'November', 'December'
  ];

  var yScale = d3.scaleBand()
  .padding([.1])
  .rangeRound([height, 0]);

  var xScale = d3.scaleLinear()
  .range([0, width]);

  var xAxis = d3.axisBottom(xScale)
  .tickPadding(8);

  var yAxis = d3.axisLeft(yScale)
  .tickSize(0)
  .tickPadding(8)
  .tickFormat(function(d) {
    return months[d - 1];
  });

  var tooltip = d3.select("#chart-area").append("div").attr("class", "toolTip");

  var svg = d3.select("#chart-area").append("svg")
  .attr("width", width + margin.left + margin.right)
  .attr("height", height + margin.top + margin.bottom)
  .append("g")
  .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  // draw the axes
  svg.append("g")
  .attr("class", "y axis")
  .call(yAxis);

  svg.append("g")
  .attr("class","x axis")
  .attr("transform","translate(0," + height + ")")
  .call(xAxis);

  var copTitle = svg.append("text");

  var updateChart = function(data) {
    copTitle
        .attr("class", "cop-title")
        .attr("x", width/4)
        .attr("dy", -5)
        .text("Communication on Progress Submissions in " + data[0].year);

    // count the total entries for the year
    var countVals = [];
    data.forEach(function(month) {
      countVals.push(month.count);
    });

    // Set the X & Y domains, with a minimum of 10 in the X
    var maxValue = Math.max(10, d3.max(countVals, function(d)  { return d; }));
    xScale.domain([0, maxValue]).nice();
    yScale.domain(data.map(function(d) { return d.month; }).sort(d3.descending));

    var colorScale = d3.scaleQuantile()
    .domain([1, maxValue])
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
    .range(['#B5C7E3','#89A6D2','#5C85C1','#3E66A3', '#2D4A76', '#1C2E4A']);


    // re-draw the x axis
    svg.select(".x")
    .call(xAxis);

    // re-draw the y axis
    svg.select(".y")
    .call(yAxis);

    // reload the data for the new month
    var bars = svg.selectAll("rect")
    .data(data, function(d) {
      return d.month;
    });

    var t = d3.transition()
    .duration(2000);

    // remove months that don't exist in this set.
    bars.exit().remove();

    // add new bar for incoming months
    var existingBars = bars.enter().append("rect")
    .style("fill", function(d) { return colorScale(d.count); })
    .on("mouseenter", function(d) {
      tooltip
      .style("left", d3.event.pageX - 50 + "px")
      .style("top", d3.event.pageY - 70 + "px")
      .style("display", "inline-block")
      .html((d.year) + "<br>" + "Monthly COP Submission: " + (d.count))
      //d3.select(this).style("fill", "#004d65");
    })
    //.on("mouseout", function(d) {
      //tooltip.style("display", "none")
      //d3.select(this).style("fill", function(d) { return colorScale(d.count); })
    //});

    // update existing bars with their new values
    bars.merge(existingBars)
    .transition(t)
    .attr("x", 1)
    .attr("y", function(d) { return yScale(d.month); })
    .attr("width" , function(d) { return xScale(d.count); })
    .attr("height", yScale.bandwidth())
    .style("fill", function(d,i) { return colorScale(d.count)});
  };

  var getYearData = function(data, year) {
    if(year == null) {
      year = data[0].year
    }
    return data.filter(function(d) {
      return d.year == year;
    });
  };

  var drawYearButtons = function(data) {
    var years = d3.set(data.map(function(d) { return d.year; })).values();

    var buttons = d3.select("#yearButtons").selectAll(".year-button")
    .data(years)
    .enter().append("button")
    .attr("class", "year-button")
    .attr("value", function(d) { return d; })
    .text(function(d) { return d; });

    buttons.on("click", function(year) {
      var yearData = getYearData(data, year);
      updateChart(yearData);
    });
  };

  // Draw the buttons and the initial chart
  drawYearButtons(data);
  var defaultYearData = getYearData(data, startYear);
  updateChart(defaultYearData);

  window.addEventListener("resize", resizeChart);

  resizeChart();

  function resizeChart() {

    var margin = {top: 20, right: 75, bottom: 100, left: 60};
    //var width = window.innerWidth - margin.left - margin.right,
    width = parseInt(d3.select("#chart-area").style("width")) - margin.left - margin.right,
    //height = window.innerHeight - margin.top - margin.bottom;

    xScale.range([0,width]);
    yScale.rangeRound([height, 0]);
    xAxis.tickSize(0);

    var svg = d3.select("#chart-area").select("svg"),
    g = svg.select("g");

    svg.transition()
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)

    g.transition()
    .attr("transform", "translate(" + margin.right + "," + margin.top + ")");

    // updates the y axis since its different for each sector
    g.select(".y")
    .transition()
    .call(yAxis)

    // updates the x axis since its different for each sector
    g.select(".x")
    .transition()
    .attr("transform","translate(0," + height + ")")
    .call(xAxis)

    // updating the positions of the existing bars
    g.selectAll("rect")
    .transition()
    .attr("width" , function(d) { return xScale(d.count) })
    .attr("y", function(d) { return yScale(d.month) })
    .attr("height", yScale.bandwidth())

    // updating the position of the title
    g.select(".cop-title")
    .transition()
    .attr("x", width/10)
    .attr("dy", -4)
    .style("font-size", "10px")


  }





}
