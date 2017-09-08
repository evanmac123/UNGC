function drawSdgSectorCharts(data, sdgOne) {
  //sdgOne is not set yet, it will be set below or the first existing sdg will be set
  var goals = {
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
    "SDG 17: Strengthen the means of implementation and revitalize the global partnership for sustainable development" : "Goal 17: Partnership for the Goals",
  };

  var titleGoals = {
    "SDG 1: End poverty in all its forms everywhere" : "No Poverty",
    "SDG 2: End hunger, achieve food security and improved nutrition and promote sustainable agriculture" : "Zero Hunger",
    "SDG 3: Ensure healthy lives and promote well-being for all at all ages" : "Good Health and Well-Being",
    "SDG 4: Ensure inclusive and equitable quality education and promote lifelong learning opportunities for all" : "Quality Education",
    "SDG 5: Achieve gender equality and empower all women and girls" : "Gender Equality",
    "SDG 6: Ensure availability and sustainable management of water and sanitation for all" :   "Clean Water and Sanitation",
    "SDG 7: Ensure access to affordable, reliable, sustainable and modern energy for all" : "Affordable and Clean Energy",
    "SDG 8: Promote sustained, inclusive and sustainable economic growth, full and productive employment and decent work for all" : "Decent Work and Economic Growth",
    "SDG 9: Build resilient infrastructure, promote inclusive and sustainable industrialization and foster innovation" : "Industry, Innovation and Infrastructure",
    "SDG 10: Reduce inequality within and among countries" : "Reduced Inequalities",
    "SDG 11: Make cities and human settlements inclusive, safe, resilient and sustainable" : "Sustainable Cities and Communities",
    "SDG 12: Ensure sustainable consumption and production patterns" : "Responsible Consumption and Production",
    "SDG 13: Take urgent action to combat climate change and its impacts" : "Climate Action",
    "SDG 14: Conserve and sustainably use the oceans, seas and marine resources for sustainable development" : "Life Below Water",
    "SDG 15: Protect, restore and promote sustainable use of terrestrial ecosystems, sustainably manage forests, combat desertification, and halt and reverse land degradation and halt biodiversity loss" : "Life on Land",
    "SDG 16: Promote peaceful and inclusive societies for sustainable development, provide access to justice for all and build effective, accountable and inclusive institutions at all levels" : "Peace, Justice and Strong Institutions",
    "SDG 17: Strengthen the means of implementation and revitalize the global partnership for sustainable development" : "Partnership for the Goals"
  };

  sdgs = Object.keys(goals);

  var margin = {top: 40, right: 40, bottom: 30, left: 221};

  //var width = 700 - margin.left - margin.right,
  width = parseInt(d3.select("#sdg-country-sector").style("width")) - margin.left - margin.right,
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

    var tooltip = d3.select("#sdg-country-sector").append("div").attr("class", "sdg-sector toolTip");

    var colorScale = d3.scaleOrdinal()
    .domain(sdgs)
    .range(["#e6162d", "#cfa41e", "#2c9f44", "#bf1a33", "#ea3f29", "#31abda", "#f8bc00", "#8c1238", "#ee6f1f", "#dd0085", "#f4a119", "#cb9022", "#487a3c", "#2878bd", "#41b443", "#1c508c", "#203169"]);

    var svg = d3.select("#sdg-country-sector").append("svg")
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

    var sdgTitle = svg.append("text");

    var sdgTitle2 = svg.append("text");

    var updateChart = function(data) {
      //update title of chart
      sdgTitle
          .attr("class", "sdg-title")
          .attr("x", 0)
          .attr("dy", -25)
          .text("Sectors in " + data[0].country);
      sdgTitle2
          .attr("class", "sdg-title")
          .attr("x", 0)
          .attr("dy", -7)
          .text(" are reporting on " + titleGoals[data[0].sdg]);


      sortedData = data.sort(function(x, y){
        return d3.ascending(x.count, y.count);
      });

      // count the total entries for the year
      var countVals = [];
      sortedData.forEach(function(sector) {
        countVals.push(sector.count);
      });

      // Set the X & Y domains, with a minimum of 10 in the X
      var maxValue = Math.max(10, d3.max(countVals, function(d)  { return d; }));
      xScale.domain([0, maxValue]).nice();
      yScale.domain(sortedData.map(function(d) { return d.sector; }));

      // re-draw the x axis
      svg.select(".x")
        .call(xAxis);

      // re-draw the y axis
      svg.select(".y")
        .call(yAxis);

      // reload the data for the new sector
      var bars = svg.selectAll("rect")
          .data(sortedData, function(d) {
            return d.sector;
          });

      var t = d3.transition()
          .duration(1500);

      // remove sectors that don't exist in this set.
      bars.exit().remove();

      // add new bar for incoming sectors
      var existingBars = bars.enter().append("rect")
          .style("fill", function(d) { return colorScale(d.sdg); })
          .on("mouseenter", function(d) {
            tooltip
              .style("display", "inline-block")
              .style("top", 200 + "px")
              .style("left", 60 + "%")
              .html((d.sector) + ": " + (d.count))
              //d3.select(this).style("fill", "#004d65");
          })
          .on("mouseout", function(d) {
            tooltip
            .style("display", "none")
            d3.select(this).style("fill", function(d) { return colorScale(d.sdg); })
          });

      // update existing bars with their new values
      bars.merge(existingBars)
        .transition(t)
        .attr("x", 1)
        .attr("y", function(d) { return yScale(d.sector); })
        .attr("width" , function(d) { return xScale(d.count); })
        .attr("height", yScale.bandwidth())
        .style("fill", function(d,i) { return colorScale(d.sdg); });

    };

    var getSdgData = function(data, sdg) {
      if(sdg == null) {
        sdg = data[0].sdg;
      }
      return data.filter(function(d) {
        return d.sdg == sdg;
      });
    };

    var drawSdgButtons = function(data) {
      var sdgs = d3.set(data.map(function(d) { return d.sdg; })).values();

      var buttons = d3.select("#sdgButtons").selectAll(".sdg-button")
          .data(sdgs)
          .enter().append("button")
          .attr("class", function(d) {
            var sdg = d.toLowerCase()
                .slice(0, 16)
                .replace(" ", "")
                .replace(":", "");
            return "sdg-button " + sdg;
          })
          .attr("value", function(d) { return d; });

      buttons.on("click", function(sdg) {

        var sdgData = getSdgData(data, sdg);
        updateChart(sdgData);
      });
    };

    // Draw the buttons and the initial chart
    drawSdgButtons(data);
    var defaultSdgData = getSdgData(data, sdgOne);
    updateChart(defaultSdgData);

    d3.select(window).on("resize", resizeChart);

    function resizeChart() {

      var margin = {top: 40, right: 220, bottom: 100, left: 50};
      width = parseInt(d3.select("#sdg-country-sector").style("width")) - margin.left - margin.right,
      //var width = window.innerWidth - margin.left - margin.right,
      //height = window.innerHeight - margin.top - margin.bottom;
      //width = 200 - margin.left - margin.right,
      //height = 450 - margin.top - margin.bottom;

      xScale.range([0,width]);
      yScale.rangeRound([height, 0]);
      xAxis.tickSize(0);

      var svg = d3.select("#sdg-country-sector").select("svg"),
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
      .attr("y", function(d) { return yScale(d.sector) })
      .attr("height", yScale.bandwidth())

      // updating the position of the title
      //g.select(".sdg-title")
      //.transition()
      //.attr("x", width/40)
      //.attr("dy", -4)
      //.style("white-space", "normal")


  }

  // sdg buttons active/select state
  $( document ).ready(function() {
      $(".sdg-button:nth-of-type(1)").addClass("active");
  });

  $('.sdg-button').on('click', function (e) {
      $(".sdg-button").removeClass("active");
      $(this).toggleClass("active");
  });

}
