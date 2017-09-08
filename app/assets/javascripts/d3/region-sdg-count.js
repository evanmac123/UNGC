function countSdgsRegions(data) {
  var mapper = {
    "SDG 1: End poverty in all its forms everywhere" : "Goal 1: No Poverty",
    "SDG 2: End hunger, achieve food security and improved nutrition and promote sustainable agriculture" : "Goal 2: Zero Hunger",
    "SDG 3: Ensure healthy lives and promote well-being for all at all ages" : "Goal 3: Good Health and Well-Being",
    "SDG 4: Ensure inclusive and equitable quality education and promote lifelong learning opportunities for all" : "Goal 4: Quality Education",
    "SDG 5: Achieve gender equality and empower all women and girls" : "Goal 5: Gender Equality",
    "SDG 6: Ensure availability and sustainable management of water and sanitation for all" :   "Goal 6: Clean Water and Sanitation",
    "SDG 7: Ensure access to affordable, reliable, sustainable and modern energy for all" : "Goal 7: Affordable and Clean Energy",
    "SDG 8: Promote sustained, inclusive and sustainable economic growth, full and productive employment and decent work for all" : "Goal 8: Decent Work and Economic Growth",
    "SDG 9: Build resilient infrastructure, promote inclusive and sustainable industrialization and foster innovation" : "Goal 9: Industry, Innovation and Infrastructure",
    "SDG 10: Reduce inequality within and among countries" : "Goal 10: Reduced Inequalities",
    "SDG 11: Make cities and human settlements inclusive, safe, resilient and sustainable" : "Goal 11: Sustainable Cities and Communities",
    "SDG 12: Ensure sustainable consumption and production patterns" : "Goal 12: Responsible Consumption and Production",
    "SDG 13: Take urgent action to combat climate change and its impacts" : "Goal 13: Climate Action",
    "SDG 14: Conserve and sustainably use the oceans, seas and marine resources for sustainable development" : "Goal 14: Life Below Water",
    "SDG 15: Protect, restore and promote sustainable use of terrestrial ecosystems, sustainably manage forests, combat desertification, and halt and reverse land degradation and halt biodiversity loss" : "Goal 15: Life on Land",
    "SDG 16: Promote peaceful and inclusive societies for sustainable development, provide access to justice for all and build effective, accountable and inclusive institutions at all levels" : "Goal 16: Peace, Justice and Strong Institutions",
    "SDG 17: Strengthen the means of implementation and revitalize the global partnership for sustainable development" : "Goal 17: Partnership for the Goals"
  };

  var sdgs = Object.keys(mapper);

  var margin = {top: 20, right: 40, bottom: 40, left: 275};

  //var width = 250 - margin.left - margin.right,
  width = parseInt(d3.select("#sdg-region-count").style("width")) - margin.left - margin.right,
  height = 420 - margin.top - margin.bottom;

  var yScale = d3.scaleBand()
  .padding([.2])
  .rangeRound([height, 0]);

  var xScale = d3.scaleLinear()
  .range([0, width]);

  var xAxis = d3.axisBottom(xScale)
  .tickPadding(2);

  var yAxis = d3.axisLeft(yScale)
  .tickSize(0)
  .tickPadding(8)
  .tickFormat(function(d) {
    return mapper[d]
  });

  var tooltip = d3.select("#sdg-region-count").append("div").attr("class", "toolTip");

  var colorScale = d3.scaleOrdinal()
  .domain(sdgs)
  .range(["#e6162d", "#cfa41e", "#2c9f44", "#bf1a33", "#ea3f29", "#31abda", "#f8bc00", "#8c1238", "#ee6f1f", "#dd0085", "#f4a119", "#cb9022", "#487a3c", "#2878bd", "#41b443", "#1c508c", "#203169"]);

  var svg = d3.select("#sdg-region-count").append("svg")
  .attr("width", width + margin.left + margin.right)
  //.attr("height", height + margin.top + margin.bottom)
  .append("g")
  .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  var sdgTitle = svg.append("text");

  var sdgTitle2 = svg.append("text");

  createChart(data);

  function createChart(data) {
    sortedData = data.sort(function(x, y){
      return d3.ascending(x.count, y.count);
    });

    var maxValue = d3.max(sortedData, function(d)  { return d.count })

    xScale.domain([0, maxValue > 10 ? maxValue : 10]).nice();
    yScale.domain(sortedData.map(function(d) { return d.sdg; }));

    svg.append("g")
    .attr("class","x axis")
    .attr("transform","translate(0," + height + ")")
    .call(xAxis);

    svg.append("text")
    .data(sortedData)
    .attr("class", "title")
    .attr("x", 0)
    .attr("dy", -5)
    .text(function(d) { return "Companies are reporting on these SDGs"; })


    svg.selectAll(".sdgSelections")
    .data(sortedData)
    .enter().append("rect")
    .attr("class", "sdgSelections")
    .attr("x", 0)
    .attr("width" , function(d) { return xScale(d.count) })
    .attr("y", function(d) { return yScale(d.sdg) })
    .attr("height", yScale.bandwidth())
    .style("fill", function(d) { return colorScale(d.sdg); })
    .on("mousemove", function(d){
      tooltip
      .text(d3.event.pageX + ", " + d3.event.pageY)
      .style("display", "block")
      .style("left", (d3.event.pageX - 300) + "px")
      .style("top", (d3.event.pageY - 340) + "px")
      .html((d.count) + " companies are reporting activities to advance " + (mapper[d.sdg]))
    })
    .on("mouseout", function(d){ tooltip.style("display", "none");
    d3.select(this).style("fill", function(d) { return colorScale(d.sdg); })});
    svg.append("g")
    .attr("class","y axis")
    .call(yAxis);

  }

  window.addEventListener("resize", resizeChart);
  //document.getElementById("data-vis").addEventListener("resize", resizeChart);

  resizeChart();

  function resizeChart() {

    var margin = {top: 20, right: 280, bottom: 50, left: 10};
    width = parseInt(d3.select("#sdg-region-count").style("width")) - margin.left - margin.right,
    //max-width = 900 - margin.left - margin.right,
    //height = 450 - margin.top - margin.bottom;

    //height = parseInt(d3.select("#data-vis").style("height")) - margin.top - margin.bottom;
    //var margin = {top: 20, right: 250, bottom: 100, left: 60};
    //var width = window.innerWidth - margin.left - margin.right,
    //height = window.innerHeight - margin.top - margin.bottom;

    xScale.range([0,width]);
    yScale.rangeRound([height, 0]);
    xAxis.tickSize(0);

    var svg = d3.select("#data-vis").select("svg"),
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
    g.selectAll(".sdgSelections")
    .transition()
    .attr("width" , function(d) { return xScale(d.count) })
    .attr("y", function(d) { return yScale(d.sdg) })
    .attr("height", yScale.bandwidth())

  }

}
