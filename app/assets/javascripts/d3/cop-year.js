function drawCopYearChart(data) {

  var margin = {top: 20, right: 40, bottom: 30, left: 120};

  var width = 960 - margin.left - margin.right,
  height = 450 - margin.top - margin.bottom;

  var yScale = d3.scaleBand()
  .padding([.1])
  .rangeRound([height, 0]);

  var xScale = d3.scaleLinear()
  .range([0, width]);

  var xAxis = d3.axisBottom(xScale)
  .tickPadding(8);

  var yAxis = d3.axisLeft(yScale)
  .tickSize(0)
  .tickPadding(8);

  var tooltip = d3.select("body").append("div").attr("class", "toolTip");

  creatChart(data);

  function creatChart(data) {
    var maxValue = d3.max(data, function(d)  { return d.count })

    var colorScale = d3.scaleQuantile()
    .domain([1, maxValue])
    .range(['#B5C7E3','#89A6D2','#5C85C1','#3E66A3', '#2D4A76', '#1C2E4A']);
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


    xScale.domain([0, maxValue > 10 ? maxValue : 10]).nice();
    yScale.domain(data.map(function(d) { return d.year; }).sort());

    var svg = d3.select("#cop-year").append("svg")
    .data(data)
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    svg.append("g")
    .attr("class","x axis")
    .attr("transform","translate(0," + height + ")")
    .call(xAxis);

    svg.append("text")
    .attr("class", "title")
    .attr("x", width/3)
    .attr("dy", -5)
    .text(function(d) { return "Total yearly COP submissions in " + d.country; })

    svg.selectAll(".copYear")
    .data(data)
    .enter().append("rect")
    .attr("class", "copYear")
    .attr("x", 0)
    .attr("width" , function(d) { return xScale(d.count) })
    .attr("y", function(d) { return yScale(d.year) })
    .attr("height", yScale.bandwidth())
    .style("fill", function(d) { return colorScale(d.count); })
    .on("mousemove", function(d){
      tooltip
      .style("left", d3.event.pageX - 90 + "px")
      .style("top", d3.event.pageY - 50 + "px")
      .style("display", "inline-block")
      .html((d.year) + "<br>" + "Submitted COPs: " + (d.count))
      //d3.select(this).style("fill", "#004d65");
    })
    .on("mouseout", function(d){ tooltip.style("display", "none");
    d3.select(this).style("fill", function(d) { return colorScale(d.count); })});
    svg.append("g")
    .attr("class","y axis")
    .call(yAxis);

  }

  window.addEventListener("resize", resizeChart);

  resizeChart();

  function resizeChart() {

    var margin = {top: 20, right: 60, bottom: 100, left: 60};
    //var width = window.innerWidth - margin.left - margin.right,
    //height = window.innerHeight - margin.top - margin.bottom;
    width = parseInt(d3.select("#cop-year").style("width")) - margin.left - margin.right,

    xScale.range([0,width]);
    yScale.rangeRound([height, 0]);
    xAxis.tickSize(0);

    var svg = d3.select("#cop-year").select("svg"),
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
    g.selectAll(".copYear")
    .transition()
    .attr("width" , function(d) { return xScale(d.count) })
    .attr("y", function(d) { return yScale(d.year) })
    .attr("height", yScale.bandwidth())

    // updating the position of the title
    g.select(".title")
    .transition()
    .attr("x", width/10)
    .attr("dy", -4)
    .style("white-space", "normal")


  }

}
