function countCops(data) {
  var format = d3.format(",d");

  d3.selectAll("#cop-counter")
        .transition()
        .duration(5000)
        .on("start", function repeat(d) {
        d3.active(this)
            .tween("text", function() {
              var that = d3.select(this),
                  i = d3.interpolateNumber(that.text().replace(/,/g, ""), data);
              return function(t) { that.text(format(i(t))); };
            })
          .transition()
            .delay(1500)
            .on("start", repeat);
      });
}
