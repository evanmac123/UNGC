function countOrganization(data) {
  //forked from http://bl.ocks.org/micahstubbs/8fc2a6477f5d731dc97887a958f6826d
  // configuration
  var colorVariable = 'count';

  // Set tooltips
  var tip = d3.tip()
  .attr('class', 'd3-tip')
  .offset([5, 0])
  .html(function(d) {
    if (d.properties.name == "Antarctica") {
      return "<strong>Continent: </strong><span class='details'>" + d.properties.name + "<br></span>";
    } else {
      return "<strong>Country: </strong><span class='details'>" + d.properties.name + "<br></span><strong>Active Participants: </strong><span class='details'>" + (d[colorVariable] || 0) + "</span>";
    }
  });

  var margin = {top: 0, right: 0, bottom: 0, left: 0};
  var width = 960 - margin.left - margin.right;
  var height = 500 - margin.top - margin.bottom;

  var color = d3.scaleQuantile()
    //primary blue >> tone 3
    .range([ 'rgb(163,200,226)','rgb(141,185,217)','rgb(119,168,207)','rgb(101,151,194)','rgb(93,139,180)','rgb(86,125,162)','rgb(78,110,142)','rgb(63,89,120)','rgb(42,64,95)','rgb(30,50,80)']);
    //primary tone 3 >> white
    //.range(['#ffffff','#f3f7fa','#e6eef6','#dae6f1','#cddeec','#c1d6e7','#b4cee3','#a7c5de','#9bbdd9','#8eb5d4','#82add0','#75a4cb','#699cc6']);
    //.range(['#B5C7E3','#89A6D2','#5C85C1','#3E66A3', '#2D4A76', '#1C2E4A']);


  var svg = d3.select('#worldmap')
    .append('svg')
    .attr('width', width)
    .attr('height', height)
    .append('g')
    .attr('class', 'map');

  var projection = d3.geoRobinson()
    .scale(148)
    .rotate([352, 0, 0])
    .translate( [width / 2, height / 2]);

  var path = d3.geoPath().projection(projection);

  svg.call(tip);

  queue()
    .defer(d3.json, '/worldmap.json')
    .defer(d3.json, '/interactive.json')
    .await(ready);

  function ready(error, geography, orgCountsByCountry) {

    orgCountsByCountry.forEach(function(orgCount) {
      // find the matching country in the worldmap
      var feature = geography.features.find(function(f) {
        return f.properties.name == orgCount.name;
      });

      if(feature) {
        feature.count = orgCount.count;
      } else {
        console.warn("Worldmap doesn't have: " + orgCount.name);
      }
    });

    // calculate jenks natural breaks
    var numberOfClasses = color.range().length - 1;
    var jenksNaturalBreaks = jenks(data.map(function(d) {
      return d[colorVariable];
    }), numberOfClasses);

    // set the domain of the color scale based on our data
    color
      .domain(jenksNaturalBreaks);

    svg.append('g')
      .attr('class', 'countries')
      .selectAll('path')
      .data(geography.features)
      .enter().append('path')
        .attr('d', path)
        .style('fill', function(d) {
          var count = d.count;
          if(count) {
            return  color(count);
          } else {
            return '#ccc';
          }
        })
        .style('fill-opacity',1)
        .style('stroke', function(d) {
            if (d[colorVariable] !== 0) {
            return 'rgb(30,50,80)';
          }
          return 'lightgray';
        })
        .style('stroke-width', 0.25)
        .style('stroke-opacity', 0.5)
        // tooltips
        .on('mouseover',function(d){
          tip.show(d);
          d3.select(this)
            .style('fill-opacity', 0.8)
            .style('stroke-opacity', 0.8)
            .style('stroke-width', 0.25)
        })
        .on('mouseout', function(d){
          tip.hide(d);
          d3.select(this)
            .style('fill-opacity', 1)
            .style('stroke-opacity', 1)
            .style('stroke-width', 0.25)
        });

    svg.append('path')
      .datum(topojson.mesh(geography.features, function(a, b) {
        return a.id !== b.id;
      }))
      .attr('class', 'names')
      .attr('d', path);
  }

  window.addEventListener("resize", resizeChart);

  resizeChart();

  function resizeChart() {
    //width = parseInt(d3.select('#worldmap').style('width'));
    var width = parseInt(d3.select(".wrapper").style("width")) - margin.left - margin.right,
    //width = $(window).width() * .97;
    height = width/1.5;

    projection
      .scale([width/6.5])
      .translate([width/2.5, height/2]);


      d3.select("#worldmap").attr("width",width).attr("height",height);
      d3.select("svg").attr("width",width).attr("height",height);

      d3.selectAll("path").attr('d', path)
  }


}
