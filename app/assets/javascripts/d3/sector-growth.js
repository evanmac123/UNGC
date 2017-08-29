function drawSectorGrowthChart(data) {
  if(data.length > 0) {
    var margin = {top: 20, right: 40, bottom: 30, left: 0};

    var width = 960 - margin.left - margin.right,
    height = 450 - margin.top - margin.bottom;

    var parseDate = d3.utcParse("%Y");

    var xScale = d3.scaleUtc()
    .range([0,width]);

    var yScale = d3.scaleLinear()
    .rangeRound([height, 0]);

    var xAxis = d3.axisBottom(xScale)
    .ticks(5)
    .tickSize(-height)
    .tickPadding(8);

    var yAxis = d3.axisRight(yScale)
    .ticks(10)
    .tickSize(-width)
    .tickPadding(8);

    var tooltip = d3.select("#sector-growth").append("div").attr("class", "sector-growth toolTip");

    var sectorLine = d3.line()
    .x(function(d) { return xScale(d.year); })
    .y(function(d) { return yScale(d.count); })

    var svg = d3.select("#sector-growth").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    svg.append("rect")
    .attr("class", "background")
    .attr("height", height)
    .attr("width", width)

    data.forEach(function (d) {
      d.count = +d.count;
      d.year = parseDate(d.year);
    });

    var nestedSectorData = d3.nest()
    .key(function(d) { return d.sector_name; })
    .entries(data)

    var initialSector = nestedSectorData.filter(function(d) {
      if(d.key == 'Support Services') {
        return 'Support Services'
      } else {
        return d.values[0].sector_name;
      }
    });
    var initialSectorData = initialSector[0].values

    xScale.domain(d3.extent(initialSectorData, function(d) { return d.year; }))
    yScale.domain([0, d3.max(initialSectorData, function(d) { return d.count; })])

    svg.selectAll(".dots")
    .data(initialSectorData, function(d) { return d.year })
    .enter().append("circle")
    .attr("class","dots")
    .attr("cx", function(d) { return xScale(d.year); })
    .attr("cy", function(d) { return yScale(d.count); })
    .attr("r", 5)
    .on("mouseover", function(d) {
            var formatYear =  d3.utcFormat("%Y")
            tooltip.html("(" + formatYear(d.year) + ", " + d.count + ")")
                 .style("left", (d3.event.pageX + 5) + "px")
                 .style("top", (d3.event.pageY - 28) + "px")
                 .style("display", "inline-block");
            tooltip.transition()
                 .duration(200)
                 .style("opacity", 1);
        })
        .on("mouseleave", function(d) {
            tooltip.transition()
                 .duration(500)
                 .style("opacity", 0);
        });

    svg.append("path")
    .datum(initialSectorData)
    .attr("class", "sectorLine")
    .attr("d", sectorLine)

    svg.append("g")
    .attr("class", "y axis")
    .attr("transform","translate(" + width + ",0)")
    .call(yAxis)

    svg.append("g")
    .attr("class", "x axis")
    .attr("transform","translate(0," + height + ")")
    .call(xAxis)

    var select = d3.select("#sector-dropdown").append('select').on("change", updateChart);
    var options = select.selectAll("option").data(nestedSectorData);

    var sectorTitle = svg.append("text");

    options.enter().append("option")
    .attr("value", function(d) { return d.key; })
    .text(function(d) { return d.key; })

    // function that updates the chart when a dropdown selected (invoked right above!)
    function updateChart(data) {
      var selectedValue = d3.select('select').property('value');
      function findSector(element) {
        return element["key"] == selectedValue;
      }
      var sector = nestedSectorData.find(findSector);
      var sectorData = sector.values

      sectorTitle
          .attr("class", "sector-title")
          .attr("x", width/4)
          .attr("dy", -5)
          .text("Change in " + sectorData[0].sector_name +  " in " + sectorData[0].country_name + " over time");

      //updating the x-scale domain
      xScale.domain(d3.extent(sectorData, function(d) { return d.year; }))

      // updating the y-scale domain
      yScale.domain([0, d3.max(sectorData, function(d) { return d.count; })])

      // updates the path, our curvy line
      svg.select(".sectorLine")
      .datum(sectorData)
      .transition()
      .duration(1000)
      .attr("d", sectorLine)

      // updates the y axis since its different for each sector
      svg.select(".y")
      .transition()
      .duration(1000)
      .call(yAxis)

      // updates the y axis since its different for each sector
      svg.select(".x")
      .transition()
      .duration(1000)
      .call(xAxis)

      // selecting all the dots and binding the new dataset
      var dotUpdate = svg.selectAll(".dots")
      .data(sectorData, function(d) { return d.year });

      // updating the positions of the existing dots
      dotUpdate.transition()
      .attr("cx", function(d) { return xScale(d.year); })
      .attr("cy", function(d) { return yScale(d.count); })

      // appending the new dots
      dotUpdate.enter().append("circle")
      .attr("class","dots")
      .transition()
      .attr("cx", function(d) { return xScale(d.year); })
      .attr("cy", function(d) { return yScale(d.count); })
      .attr("r", 5)

      // handles old dots that no longer have data bound to it
      dotUpdate.exit()
      .transition()
      .duration(150)
      .remove();

    }

    d3.select(window).on("resize", resizeChart);

    function resizeChart() {

      var margin = {top: 20, right: 60, bottom: 100, left: 60};
      width = parseInt(d3.select("#data-vis").style("width")) - margin.left - margin.right,
      //var width = window.innerWidth - margin.left - margin.right,
      //height = window.innerHeight - margin.top - margin.bottom;

      xScale.range([0,width])
      yScale.range([height, 0])
      xAxis.tickSize(-height);
      yAxis.tickSize(-width);

      var svg = d3.select("#sector-growth").select("svg"),
      g = svg.select("g");

      svg.transition()
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)

      g.transition()
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

      g.select(".background")
      .transition()
      .attr("height", height)
      .attr("width", width)

      // updates the path, our curvy line
      g.select(".sectorLine")
      .transition()
      .attr("d", sectorLine)

      // updates the y axis since its different for each sector
      g.select(".y")
      .transition()
      .attr("transform","translate(" + width + ",0)")
      .call(yAxis)

      // updates the x axis since its different for each sector
      g.select(".x")
      .transition()
      .attr("transform","translate(0," + height + ")")
      .call(xAxis)

      // updating the positions of the existing dots
      g.selectAll(".dots")
      .transition()
      .attr("cx", function(d) { return xScale(d.year); })
      .attr("cy", function(d) { return yScale(d.count); })

    }

  } else {

    d3.select("#sector-growth").append("h1").text("There is no sector change data for this country")

  }

}
