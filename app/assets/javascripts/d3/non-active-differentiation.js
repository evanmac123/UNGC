function drawNonActiveDifferentationCount(data) {
  console.log(data);
  var margin = {top: 20, right: 40, bottom: 30, left: 120};

  var width = 960 - margin.left - margin.right,
  height = 500 - margin.top - margin.bottom;

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

  var colorScale = d3.scaleOrdinal(d3.schemeCategory20c);

  var svg = d3.select("body").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  var filteredData = data.filter(function(d) { return d["differentiation"] == "advanced"  || d["differentiation"] == "learner" || d["differentiation"] == "blueprint"})

  creatChart(filteredData);

  function creatChart(data) {
    var maxValue = d3.max(data, function(d)  { return d.count })

    xScale.domain([0, maxValue > 10 ? maxValue : 10]).nice();
    yScale.domain(data.map(function(d) { return d.differentiation; }));

    var svg = d3.select("#non-active").append("svg")
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
          .attr("x", width/5)
          .attr("dy", -5)
          .text(function(d) { return "Historical Non-Active Differentiation breakdown for " + d.country; })

      svg.selectAll(".nonActive")
       .data(data)
       .enter().append("rect")
       .attr("class", "nonActive")
       .attr("x", 0)
       .attr("width" , function(d) { return xScale(d.count) })
       .attr("y", function(d) { return yScale(d.differentiation) })
       .attr("height", yScale.bandwidth())
       .style("fill", function(d) { return colorScale(d.differentiation); })
       .on("mousemove", function(d){
                tooltip
                  .style("left", d3.event.pageX - 50 + "px")
                  .style("top", d3.event.pageY - 70 + "px")
                  .style("display", "inline-block")
                  .html((d.differentiation) + "<br>" + "Number submitted: " + (d.count))
                  d3.select(this).style("fill", "#1e3250");
            })
            .on("mouseout", function(d){ tooltip.style("display", "none");
            d3.select(this).style("fill", function(d) { return colorScale(d.differentiation); })});
        svg.append("g")
             .attr("class","y axis")
             .call(yAxis);
  }

}
